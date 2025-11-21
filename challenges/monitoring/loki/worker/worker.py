import os
import sys
import time
import logging
import requests
from datetime import datetime

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stdout
)
logger = logging.getLogger('background-worker')

SERVICE_NAME = os.getenv('SERVICE_NAME', 'background-worker')
ORDER_SERVICE_URL = os.getenv('ORDER_SERVICE_URL', 'http://localhost:3001')
PROCESS_INTERVAL = 30

def process_pending_orders():
    """
    Fetches pending orders and processes them
    This simulates background job processing
    """
    try:
        logger.info("Starting order processing cycle")

        # Fetch all orders
        response = requests.get(f"{ORDER_SERVICE_URL}/orders", timeout=5)
        response.raise_for_status()

        orders = response.json().get('orders', [])
        pending_orders = [o for o in orders if o['status'] == 'pending']

        logger.info(f"Found {len(pending_orders)} pending orders to process")

        for order in pending_orders:
            process_order(order)

        if len(pending_orders) == 0:
            logger.info("No pending orders to process")

        logger.info("Order processing cycle completed")

    except requests.exceptions.ConnectionError:
        logger.error(f"Cannot connect to order service at {ORDER_SERVICE_URL}")
    except requests.exceptions.Timeout:
        logger.error("Order service request timed out")
    except Exception as e:
        logger.error(f"Unexpected error during order processing: {str(e)}")

def process_order(order):
    """
    Process a single order
    Simulates payment processing, inventory checks, etc.
    """
    order_id = order['id']
    customer_id = order.get('customerId')
    amount = order.get('amount', 0)

    logger.info(f"Processing order {order_id} for customer {customer_id}, amount ${amount}")

    try:
        # Simulate processing time
        time.sleep(2)

        # Simulate random processing failures (10% chance)
        import random
        if random.random() < 0.10:
            logger.error(f"Payment processing failed for order {order_id} - Payment gateway timeout")
            update_order_status(order_id, 'failed')
            return

        logger.info(f"Order {order_id} processed successfully")
        update_order_status(order_id, 'completed')

    except Exception as e:
        logger.error(f"Failed to process order {order_id}: {str(e)}")
        update_order_status(order_id, 'failed')

def update_order_status(order_id, status):
    """
    Update order status via API
    """
    try:
        response = requests.patch(
            f"{ORDER_SERVICE_URL}/orders/{order_id}/status",
            json={"status": status},
            timeout=5
        )
        response.raise_for_status()
        logger.info(f"Updated order {order_id} status to '{status}'")
    except Exception as e:
        logger.error(f"Failed to update order {order_id} status: {str(e)}")

def health_check():
    """
    Periodic health check
    """
    logger.info(f"{SERVICE_NAME} is healthy and running")

if __name__ == '__main__':
    logger.info(f"Starting {SERVICE_NAME}")
    logger.info(f"Order service URL: {ORDER_SERVICE_URL}")
    logger.info(f"Processing interval: {PROCESS_INTERVAL} seconds")

    cycle_count = 0

    while True:
        try:
            cycle_count += 1

            # Health check every 5 cycles
            if cycle_count % 5 == 0:
                health_check()

            process_pending_orders()

            time.sleep(PROCESS_INTERVAL)

        except KeyboardInterrupt:
            logger.info("Shutting down worker...")
            break
        except Exception as e:
            logger.error(f"Worker loop error: {str(e)}")
            time.sleep(PROCESS_INTERVAL)
