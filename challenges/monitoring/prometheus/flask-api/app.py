from flask import Flask, jsonify
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time
import random

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter("api_requests_total", "Total number of API requests", ["method", "endpoint"])
REQUEST_LATENCY = Histogram("api_request_latency_seconds", "Request latency in seconds", ["endpoint"])

CUSTOMERS = [
    {"id": 1, "name": "Alice", "city": "Berlin"},
    {"id": 2, "name": "Omar", "city": "Dubai"},
    {"id": 3, "name": "Sophia", "city": "London"},
    {"id": 4, "name": "Carlos", "city": "Madrid"},
]

@app.route("/api/customers")
def get_customers():
    start_time = time.time()
    time.sleep(random.uniform(0.05, 0.3))  # simulate variable latency
    REQUEST_COUNT.labels(method="GET", endpoint="/api/customers").inc()
    REQUEST_LATENCY.labels(endpoint="/api/customers").observe(time.time() - start_time)
    return jsonify({"customers": CUSTOMERS})

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
