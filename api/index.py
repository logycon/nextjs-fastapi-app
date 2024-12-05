from fastapi import FastAPI, Body
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
import logging
import httpx
from dotenv import load_dotenv
import os
from pydantic import BaseModel

# Load environment variables
load_dotenv()

LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")  # Get log level from environment variable

# Configure logging
logging.basicConfig(
    level= logging.getLevelName(LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),  # Output to console
        # logging.FileHandler("app.log")  # Output to a file
    ]
)

logger = logging.getLogger(__name__)

# Get environment variables with defaults
OLLAMA_HOST = os.getenv("APP_OLLAMA_HOST", "localhost").strip()
OLLAMA_PORT = os.getenv("APP_OLLAMA_PORT", "11434").strip()
OLLAMA_MODEL = os.getenv("APP_OLLAMA_MODEL", "llama3.2").strip()

# Create FastAPI instance with custom docs and openapi url
app = FastAPI(docs_url="/api/py/docs", openapi_url="/api/py/openapi.json")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    message: str

@app.get("/api/py/helloFastApi")
def hello_fast_api():
    return {"message": "Hello from FastAPI"}

@app.post("/api/py/chat")
async def chat(request: ChatRequest):
    try:
        logger.debug(f"Received chat request: {request.message}")
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/generate",
                json={
                    "model": OLLAMA_MODEL,
                    "prompt": request.message,
                    "stream": False
                }
            )
            logger.info(f"Ollama response status: {response.status_code}")
            if response.status_code == 200:
                data = response.json()
                return {"response": data.get("response", "")}
            else:
                logger.error(f"Ollama error: {response.text}")
                return {"error": f"Failed to connect to Ollama: {response.text}"}
    except httpx.RequestError as e:
        logger.error(f"Request error: {str(e)}")
        return {"error": f"Failed to connect to Ollama: {str(e)}"}
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return {"error": f"Unexpected error: {str(e)}"}

@app.get("/api/py/models")
async def list_models():
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/tags")
            if response.status_code == 200:
                return response.json()
            else:
                return {"error": f"Failed to get models: {response.text}"}
        except httpx.RequestError as e:
            return {"error": f"Failed to connect to Ollama: {str(e)}"}