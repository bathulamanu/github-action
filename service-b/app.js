const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello from Service B');
});

app.listen(5001, () => {
  console.log('Service B running on port 5001');
});
