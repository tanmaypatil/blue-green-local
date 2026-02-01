"""Prometheus metrics for the backend service."""

from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
from fastapi import Response

# Request counter - tracks total requests by endpoint and status
REQUEST_COUNT = Counter(
    "backend_requests_total",
    "Total number of requests",
    ["endpoint", "method", "status"]
)

# Request latency histogram - tracks response time distribution
REQUEST_LATENCY = Histogram(
    "backend_request_latency_seconds",
    "Request latency in seconds",
    ["endpoint", "method"],
    buckets=[0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0]
)

# Active requests gauge - tracks concurrent requests
ACTIVE_REQUESTS = Gauge(
    "backend_active_requests",
    "Number of active requests"
)

# Calculate endpoint specific metrics
CALCULATE_TOTAL = Counter(
    "backend_calculate_total",
    "Total calculations performed"
)

CALCULATE_AMOUNT_SUM = Counter(
    "backend_calculate_amount_sum",
    "Sum of all amounts calculated"
)


def get_metrics() -> Response:
    """Generate Prometheus metrics response."""
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST
    )
