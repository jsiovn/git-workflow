import assert from 'node:assert/strict';
import test from 'node:test';
import { isFreeShipping } from './free-shipping.js';

test('500,000 VND and above ships for free', () => {
  assert.equal(isFreeShipping(500000), true);
  assert.equal(isFreeShipping(499999), false);
});
