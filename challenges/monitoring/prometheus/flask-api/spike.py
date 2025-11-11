import requests, time, random, threading

URL = "http://localhost:5000/api/customers"

def make_request():
    try:
        res = requests.get(URL, timeout=2)
        print(res.json())
    except Exception as e:
        print(f"Error: {e}")

def stress_test(duration=30, rps=10):
    end = time.time() + duration
    while time.time() < end:
        threads = []
        for _ in range(rps):
            t = threading.Thread(target=make_request)
            t.start()
            threads.append(t)
        for t in threads:
            t.join()
        time.sleep(1)

if __name__ == "__main__":
    print("Spiking the Flask API (/api/customers) for 30 seconds...")
    stress_test(duration=30, rps=15)
    print("Done.")
