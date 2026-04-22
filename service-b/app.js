const express = require('express');
const app = express();

// Root route
app.get('/', (req, res) => {
  res.send('Hello from Service B');
});

// Path-based route (for ALB / CloudFront)
app.get('/service-b', (req, res) => {
  res.send('Hello from Service B');
});

// Health check (VERY IMPORTANT for ALB)
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

// Listen on port 5000 (BEST PRACTICE for Docker + ALB)
app.listen(5000, '0.0.0.0', () => {
  console.log('Service B running on port 5000');
});
