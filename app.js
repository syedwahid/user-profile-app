const express = require('express');
const app = express();
const path = require('path');

// Middleware
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

// Sample user data
const user = {
  name: "John Doe",
  address: "123 Main St, Anytown, USA",
  email: "john.doe@example.com",
  phone: "1234567890"
};

// API endpoint to get user data
app.get('/api/user', (req, res) => {
  res.json(user);
});

// Serve HTML page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start server
const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, () => {  // Assign to 'server'
  console.log(`Server running on port ${PORT}`);
});

// Graceful shutdown handler
const shutdown = () => {
  server.close(() => {
    console.log('Server stopped');
    process.exit(0);
  });
};

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

// Export both app and server for testing
module.exports = { app, server };