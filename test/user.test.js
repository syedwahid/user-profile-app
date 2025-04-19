const assert = require('assert');
const request = require('supertest');
const { app, server } = require('../app');

describe('User Profile API', () => {
  before((done) => {
    // Wait for server to start if needed
    if (server.listening) return done();
    server.on('listening', done);
  });

  after((done) => {
    // Close server after tests
    server.close(done);
  });

  it('should return user data with valid phone number', (done) => {
    request(app)
      .get('/api/user')
      .expect(200)
      .end((err, res) => {
        if (err) return done(err);
        
        assert.strictEqual(res.body.phone.length, 10, 'Phone number should be 10 digits');
        assert(/^\d+$/.test(res.body.phone), 'Phone number should contain only digits');
        assert(res.body.name, 'Name should exist');
        assert(res.body.address, 'Address should exist');
        assert(res.body.email, 'Email should exist');
        
        done();
      });
  });
});