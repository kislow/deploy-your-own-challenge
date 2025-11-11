🧠 Kadir’s Tech Playground – Hints
=================================

Hint 1 – Check the Endpoints
----------------------------
Every target that Prometheus scrapes exposes a `/metrics` endpoint.  
Inspect them carefully — one of them changes more frequently than the others.

Hint 2 – The Curious Container
------------------------------
Look closely at the Flask API container.  
It seems to produce regular traffic without any user input.  
Why might that be?

Hint 3 – Follow the Logs
------------------------
There’s something interesting in `/var/log` inside the Flask container.  
One of the log files records when something is happening — it might not be what you expect.

Hint 4 – Time Windows Matter
----------------------------
Prometheus queries like `rate(metric[1m])` or `sum(rate(...))` depend on the time window.  
If you don’t see changes, try a slightly wider window or wait a few minutes.

Hint 5 – Grafana Can Tell Stories
---------------------------------
Build panels for both `api_requests_total` and `api_request_latency_seconds_bucket`.  
When the graph changes, ask yourself: *what triggered this?*

Hint 6 – Think Like an Observer
-------------------------------
Not all activity comes from outside.  
Sometimes, your system generates its own patterns.  
Find out what’s responsible for the recurring spikes.
