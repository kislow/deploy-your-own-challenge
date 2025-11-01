#!/bin/bash
#
# MongoDB Data Ingestion Script
# Populates the production_db with sample customer and order data
#

set -e

# Get credentials from environment or use defaults
MONGO_USER="${MONGO_ADMIN_USER:-admin}"
MONGO_PASS="${MONGO_ADMIN_PASSWORD:-AdminPass123!}"
MONGO_HOST="${MONGO_HOST:-localhost}"
MONGO_PORT="${MONGO_PORT:-27017}"

echo "=== MongoDB Data Ingestion Script ==="
echo "Populating production_db with sample data..."

# Create a JavaScript file with data generation logic
cat > /tmp/generate_data.js << 'EOJS'
// Switch to production database
db = db.getSiblingDB('production_db');

// Drop existing collections if they exist
db.customers.drop();
db.orders.drop();

print("Generating customer data...");

// Generate 150 customers with realistic data
const firstNames = ["James", "Mary", "John", "Patricia", "Robert", "Jennifer", "Michael", "Linda", "William", "Elizabeth", "David", "Barbara", "Richard", "Susan", "Joseph", "Jessica", "Thomas", "Sarah", "Charles", "Karen", "Christopher", "Nancy", "Daniel", "Lisa", "Matthew", "Betty", "Anthony", "Margaret", "Mark", "Sandra", "Donald", "Ashley", "Steven", "Kimberly", "Paul", "Emily", "Andrew", "Donna", "Joshua", "Michelle"];
const lastNames = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Thompson", "White", "Harris", "Clark", "Lewis", "Robinson", "Walker", "Young", "Hall"];
const cities = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "San Diego", "Dallas", "San Jose", "Austin", "Jacksonville", "Seattle", "Denver", "Boston", "Portland", "Miami", "Atlanta", "Detroit", "Minneapolis"];
const states = ["NY", "CA", "IL", "TX", "AZ", "PA", "TX", "CA", "TX", "CA", "TX", "FL", "WA", "CO", "MA", "OR", "FL", "GA", "MI", "MN"];

let customers = [];
for (let i = 1; i <= 150; i++) {
    const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
    const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
    const cityIndex = Math.floor(Math.random() * cities.length);

    customers.push({
        customer_id: i,
        first_name: firstName,
        last_name: lastName,
        email: `${firstName.toLowerCase()}.${lastName.toLowerCase()}${i}@example.com`,
        phone: `+1-555-${String(Math.floor(Math.random() * 9000) + 1000)}-${String(Math.floor(Math.random() * 9000) + 1000)}`,
        address: {
            street: `${Math.floor(Math.random() * 9999) + 1} Main St`,
            city: cities[cityIndex],
            state: states[cityIndex],
            zip: String(Math.floor(Math.random() * 90000) + 10000)
        },
        registration_date: new Date(Date.now() - Math.floor(Math.random() * 365 * 24 * 60 * 60 * 1000)),
        loyalty_points: Math.floor(Math.random() * 5000),
        account_status: Math.random() > 0.1 ? "active" : "inactive",
        preferences: {
            newsletter: Math.random() > 0.3,
            sms_notifications: Math.random() > 0.5
        }
    });
}

db.customers.insertMany(customers);
print(`Inserted ${customers.length} customers`);

print("Generating order data...");

// Generate 200 orders
const products = [
    { name: "Laptop Pro 15", price: 1299.99 },
    { name: "Wireless Mouse", price: 29.99 },
    { name: "USB-C Cable", price: 12.99 },
    { name: "External Monitor 27\"", price: 349.99 },
    { name: "Mechanical Keyboard", price: 89.99 },
    { name: "Webcam HD", price: 79.99 },
    { name: "Desk Lamp LED", price: 45.99 },
    { name: "Phone Case", price: 19.99 },
    { name: "Bluetooth Headphones", price: 159.99 },
    { name: "Portable SSD 1TB", price: 119.99 },
    { name: "Ergonomic Chair", price: 299.99 },
    { name: "Standing Desk", price: 449.99 },
    { name: "Tablet 10\"", price: 329.99 },
    { name: "Smart Watch", price: 249.99 },
    { name: "Power Bank", price: 39.99 }
];

const statuses = ["pending", "processing", "shipped", "delivered", "cancelled"];

let orders = [];
for (let i = 1; i <= 200; i++) {
    const numItems = Math.floor(Math.random() * 4) + 1;
    let items = [];
    let total = 0;

    for (let j = 0; j < numItems; j++) {
        const product = products[Math.floor(Math.random() * products.length)];
        const quantity = Math.floor(Math.random() * 3) + 1;
        const itemTotal = product.price * quantity;
        total += itemTotal;

        items.push({
            product_name: product.name,
            quantity: quantity,
            unit_price: product.price,
            total: itemTotal
        });
    }

    orders.push({
        order_id: i,
        customer_id: Math.floor(Math.random() * 150) + 1,
        order_date: new Date(Date.now() - Math.floor(Math.random() * 180 * 24 * 60 * 60 * 1000)),
        status: statuses[Math.floor(Math.random() * statuses.length)],
        items: items,
        subtotal: total,
        tax: Math.round(total * 0.08 * 100) / 100,
        shipping: 9.99,
        total: Math.round((total * 1.08 + 9.99) * 100) / 100,
        shipping_address: {
            street: `${Math.floor(Math.random() * 9999) + 1} Delivery Ave`,
            city: cities[Math.floor(Math.random() * cities.length)],
            state: states[Math.floor(Math.random() * states.length)],
            zip: String(Math.floor(Math.random() * 90000) + 10000)
        },
        payment_method: Math.random() > 0.5 ? "credit_card" : "paypal",
        notes: Math.random() > 0.7 ? "Please leave at front door" : ""
    });
}

db.orders.insertMany(orders);
print(`Inserted ${orders.length} orders`);

// Create indexes for better performance
db.customers.createIndex({ customer_id: 1 });
db.customers.createIndex({ email: 1 });
db.orders.createIndex({ order_id: 1 });
db.orders.createIndex({ customer_id: 1 });

print("\n=== Data Summary ===");
print(`Total Customers: ${db.customers.countDocuments()}`);
print(`Total Orders: ${db.orders.countDocuments()}`);
print("\nSample Customer:");
printjson(db.customers.findOne());
print("\nSample Order:");
printjson(db.orders.findOne());
print("\n=== Data ingestion complete! ===");
EOJS

# Execute the JavaScript file with mongosh
mongosh -u "$MONGO_USER" -p "$MONGO_PASS" --authenticationDatabase admin < /tmp/generate_data.js

# Clean up
rm -f /tmp/generate_data.js

echo ""
echo "=== SUCCESS ==="
echo "Database: production_db"
echo "Collections: customers (150 docs), orders (200 docs)"
echo ""
echo "To verify data:"
echo "  mongosh -u $MONGO_USER -p <password> --authenticationDatabase admin"
echo "  use production_db"
echo "  db.customers.countDocuments()"
echo ""
