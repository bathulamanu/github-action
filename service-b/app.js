const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello manohar from Service B');
});

// ✅ FIX HERE
app.listen(5000, '0.0.0.0', () => {
  console.log('Service B running on port 5000');
});
