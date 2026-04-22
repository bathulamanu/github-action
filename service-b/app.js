app.get('/', (req, res) => {
  res.send('Hello from Service B');
});

app.get('/service-b', (req, res) => {
  res.send('Hello from Service B');
});
