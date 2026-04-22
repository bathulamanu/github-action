const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello manohar from Service B');
});

app.listen(5001, () => {
  console.log('Service B running on port 5000');
});
