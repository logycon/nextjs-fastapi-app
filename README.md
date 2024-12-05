<p align="center">
  <a href="https://nextjs-fastapi-starter.vercel.app/">
    <h3 align="center">Next.js FastAPI Starter</h3>
  </a>
</p>

<p align="center">
  Simple Next.j 14 boilerplate that uses FastAPI as the API backend.
</p>

<br/>

## Introduction

This is a hybrid Next.js 14 + Python template. One great use case of this is to write Next.js apps that use Python AI libraries on the backend, while still having the benefits of Next.js Route Handlers and Server Side Rendering.

## How It Works

The Python/FastAPI server is mapped into to Next.js app under `/api/`.

This is implemented using [`next.config.js` rewrites](https://github.com/digitros/nextjs-fastapi/blob/main/next.config.js) to map any request to `/api/py/:path*` to the FastAPI API, which is hosted in the `/api` folder.

Also, the app/api routes are available on the same domain, so you can use NextJs Route Handlers and make requests to `/api/...`.

On localhost, the rewrite will be made to the `127.0.0.1:8000` port, which is where the FastAPI server is running.

In production, both Next.js and FastAPI run in a single container orchestrated by Kubernetes.

## Prerequisites

- Docker
- Kubernetes
- Make

## Environment Variables

You can create a `.env` file by copying the `.env.example` file and filling in the values.

## Dependencies

Install node and python dependencies:

```bash
make install
```

## Developing Locally

You can clone & create this repo with the following command

```bash
make dev
```

## Building 

Build app locally:

```bash
make build
```

## Building and pushing Docker image

```bash
make docker-build
```

## Running Docker image

```bash
make docker-run
```

## Deploying to Kubernetes

```bash
make deploy
```

## Whole 9 yards

```bash
make release
```

## Getting Started

Clone this repo, create `.env` file, install and run:

```bash
make install
make dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

The FastApi server will be running on [http://127.0.0.1:8000](http://127.0.0.1:8000) – feel free to change the port in `package.json` (you'll also need to update it in `next.config.js`).

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.
- [FastAPI Documentation](https://fastapi.tiangolo.com/) - learn about FastAPI features and API.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js/) - your feedback and contributions are welcome!
