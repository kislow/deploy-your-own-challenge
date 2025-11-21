from flask import Flask, jsonify
import logging, random

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

CUSTOMERS = [
    {"id": 1, "name": "Alice", "status": "active"},
    {"id": 2, "name": "Bob", "status": "active"},
    {"id": 3, "name": "Charlie", "status": "inactive"},
]

@app.route('/customers')
def get_customers():
    app.logger.info("Getting all customers")
    return jsonify({"customers": CUSTOMERS})

@app.route('/customers/<int:customer_id>/validate')
def validate_customer(customer_id):
    customer = next((c for c in CUSTOMERS if c['id'] == customer_id), None)

    if not customer:
        app.logger.error(f"Customer {customer_id} not found")
        return jsonify({"valid": False}), 404

    if customer['status'] != 'active':
        app.logger.warning(f"Customer {customer_id} is {customer['status']}")
        return jsonify({"valid": False}), 403

    if random.random() < 0.25:
        app.logger.error(f"Database timeout for customer {customer_id}")
        return jsonify({"valid": False, "reason": "database_timeout"}), 500

    app.logger.info(f"Customer {customer_id} validated successfully")
    return jsonify({"valid": True})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
