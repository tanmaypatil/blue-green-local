"""Health check endpoints for Kubernetes probes."""

from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/health", tags=["health"])


class HealthResponse(BaseModel):
    status: str
    version: str


# Simulated dependency state (in real app, this would check actual dependencies)
_ready = True


def set_ready(state: bool) -> None:
    """Set readiness state (for testing/simulation)."""
    global _ready
    _ready = state


def is_ready() -> bool:
    """Check if service is ready to accept traffic."""
    return _ready


@router.get("/live", response_model=HealthResponse)
async def liveness():
    """
    Liveness probe endpoint.

    Kubernetes uses this to determine if the pod should be restarted.
    Returns 200 if the process is running.

    This should be a simple check - if this endpoint responds, the app is alive.
    """
    from app import __version__
    return HealthResponse(status="alive", version=__version__)


@router.get("/ready", response_model=HealthResponse)
async def readiness():
    """
    Readiness probe endpoint.

    Kubernetes uses this to determine if traffic should be sent to this pod.
    Returns 200 only if the service can handle requests.

    In a real application, this would check:
    - Database connectivity
    - Cache connectivity
    - Required external services
    """
    from app import __version__
    from fastapi import HTTPException

    if not is_ready():
        raise HTTPException(status_code=503, detail="Service not ready")

    return HealthResponse(status="ready", version=__version__)
