#!/bin/sh
node server.js & 
uvicorn api.index:app --host 0.0.0.0 --port 8000 