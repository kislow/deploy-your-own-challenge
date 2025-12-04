from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/")
def home():
    return jsonify({"status": "ok", "message": "API is running"})


if __name__ == "__main__":
    # Intentionally incorrect or missing for students to fix IF NEEDED
    app.run(host="0.0.0.0", port=5005)
