"""
Backend API for blue-green deployment learning.

Version 1.0.0 - Basic calculate endpoint
"""

import time
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

from app import __version__
from app.health import router as health_router
from app.metrics import (
    REQUEST_COUNT,
    REQUEST_LATENCY,
    ACTIVE_REQUESTS,
    CALCULATE_TOTAL,
    CALCULATE_AMOUNT_SUM,
    get_metrics,
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler."""
    # Startup
    print(f"Starting backend service v{__version__}")
    yield
    # Shutdown
    print("Shutting down backend service")


app = FastAPI(
    title="Blue-Green Backend API",
    description="Backend service for learning blue-green deployments",
    version=__version__,
    lifespan=lifespan,
)

# Include health check routes
app.include_router(health_router)


# Request/Response models
class CalculateRequest(BaseModel):
    amount: float = Field(..., description="The amount to calculate", gt=0)


class CalculateResponse(BaseModel):
    original_amount: float
    result: float
    version: str


@app.middleware("http")
async def metrics_middleware(request, call_next):
    """Middleware to track request metrics."""
    ACTIVE_REQUESTS.inc()
    start_time = time.time()

    response = await call_next(request)

    # Record metrics
    latency = time.time() - start_time
    endpoint = request.url.path
    method = request.method
    status = response.status_code

    REQUEST_COUNT.labels(endpoint=endpoint, method=method, status=status).inc()
    REQUEST_LATENCY.labels(endpoint=endpoint, method=method).observe(latency)
    ACTIVE_REQUESTS.dec()

    return response


@app.get("/")
async def root():
    """Root endpoint - service info."""
    return {
        "service": "backend",
        "version": __version__,
        "endpoints": ["/calculate", "/health/live", "/health/ready", "/metrics"]
    }


@app.post("/calculate", response_model=CalculateResponse)
async def calculate(request: CalculateRequest):
    """
    Calculate endpoint - doubles the input amount.

    Version 1.0.0: Simple doubling
    Version 2.0.0: Will add optional discount parameter
    """
    # Track business metrics
    CALCULATE_TOTAL.inc()
    CALCULATE_AMOUNT_SUM.inc(request.amount)

    # Business logic: double the amount
    result = request.amount * 2

    return CalculateResponse(
        original_amount=request.amount,
        result=result,
        version=__version__
    )


@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint."""
    return get_metrics()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
