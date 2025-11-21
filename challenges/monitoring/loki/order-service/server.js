const express = require('express');
const axios = require('axios');
const winston = require('winston');

const app = express();
app.use(express.json());

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  defaultMeta: { service: 'order-service' },
  transports: [new winston.transports.Console()]
});

const FLASK_API_URL = process.env.FLASK_API_URL || 'http://flask-api:5000';
let orders = [];
let orderIdCounter = 1;

app.get('/orders', (req, res) => {
  logger.info('Fetching all orders', { count: orders.length });
  res.json({ orders });
});

app.post('/orders', async (req, res) => {
  const { customerId, product, amount } = req.body;

  logger.info('Creating new order', { customerId, product, amount });

  try {
    const validationResponse = await axios.get(
      `${FLASK_API_URL}/customers/${customerId}/validate`,
      { timeout: 5000 }
    );

    if (!validationResponse.data.valid) {
      logger.error('Customer validation failed', {
        customerId,
        reason: validationResponse.data.reason
      });
      return res.status(400).json({
        error: 'Customer validation failed',
        reason: validationResponse.data.reason
      });
    }

    const newOrder = {
      id: orderIdCounter++,
      customerId,
      product,
      amount,
      status: 'pending'
    };

    orders.push(newOrder);
    logger.info('Order created', { orderId: newOrder.id, customerId });
    res.status(201).json(newOrder);

  } catch (error) {
    if (error.response) {
      logger.error('Validation request failed', {
        customerId,
        statusCode: error.response.status
      });
      return res.status(error.response.status).json({
        error: 'Customer validation failed',
        details: error.response.data
      });
    }
    logger.error('Unexpected error', { error: error.message });
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 🔧 FIX: Add this endpoint for worker to update status
app.patch('/orders/:id/status', (req, res) => {
  const orderId = parseInt(req.params.id);
  const { status } = req.body;

  const order = orders.find(o => o.id === orderId);

  if (!order) {
    logger.warn('Order not found for status update', {
      order_id: orderId
    });
    return res.status(404).json({ error: 'Order not found' });
  }

  const oldStatus = order.status;
  order.status = status;

  logger.info('Order status updated', {
    order_id: orderId,
    old_status: oldStatus,
    new_status: status
  });

  res.json(order);
});

app.listen(3001, () => {
  logger.info('Order Service started', { port: 3001 });
});
