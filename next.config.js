/** @type {import('next').NextConfig} */
require('dotenv').config()

const nextConfig = {
  output: 'standalone',
  experimental: {
    proxyTimeout: 30000,
  },
  logging: {
    fetches: {
      fullUrl: false,
    },
    level: 'debug',
  },
  env: {
    PROJECT_NAME: process.env.APP_PROJECT_NAME,
    OLLAMA_HOST: process.env.APP_OLLAMA_HOST,
    OLLAMA_PORT: process.env.APP_OLLAMA_PORT,
    OLLAMA_MODEL: process.env.APP_OLLAMA_MODEL,
    NEXT_SHARP_PATH: process.env.NEXT_SHARP_PATH,
    NEXT_TELEMETRY_DEBUG: process.env.NEXT_TELEMETRY_DEBUG,
    DEBUG: process.env.DEBUG,
  },
  async rewrites() {
    const backendUrl = 'http://127.0.0.1:8000'; // python backend
    return {
      beforeFiles: [
        {
          source: '/api/py/:path*',
          destination: `${backendUrl}/api/py/:path*`,
        },
        {
          source: '/docs',
          destination: `${backendUrl}/api/py/docs`,
        },
        {
          source: '/openapi.json',
          destination: `${backendUrl}/api/py/openapi.json`,
        },
      ],
    };
  },
};

module.exports = nextConfig;
