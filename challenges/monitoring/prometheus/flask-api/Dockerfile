# ============================================================
#  Flask API with Prometheus instrumentation
#  Used in Kadir’s Tech Playground – Monitoring Challenge
# ============================================================

FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY spike.py /usr/local/bin/spike.py
RUN chmod +x /usr/local/bin/spike.py

RUN apt-get update && apt-get install -y cron && rm -rf /var/lib/apt/lists/*

EXPOSE 5000

# Start flask
CMD python3 /usr/local/bin/spike.py > /var/log/spike.log 2>&1 & exec python3 app.py
