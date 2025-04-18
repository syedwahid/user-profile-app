const assert = require('assert');
const request = require('supertest');
const app = require('../app');

describe('User Profile API', () => {
  it('should return user data with valid phone number', (done) => {
    request(app)
      .get('/api/user')
      .expect(200)
      .end((err, res) => {
        if (err) return done(err);
        
        // Validate phone number is 10 digits
        assert.strictEqual(res.body.phone.length, 10, 'Phone number should be 10 digits');
        assert(/^\d+$/.test(res.body.phone), 'Phone number should contain only digits');
        
        // Validate other fields
        assert(res.body.name, 'Name should exist');
        assert(res.body.address, 'Address should exist');
        assert(res.body.email, 'Email should exist');
        
        done();
      });
  });
});