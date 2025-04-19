const express = require('express');
const app = express();
const path = require('path');

// ... (keep all your existing middleware and routes)

// Modified server startup
const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, () => {
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