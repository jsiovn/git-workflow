import assert from 'node:assert/strict';
import test from 'node:test';
import { shippingFee } from './shipping.js';

test('each known region has its own fee', () => {
  assert.equal(shippingFee('HCM'), 20000);
  assert.equal(shippingFee('HN'), 30000);
});

test('an unknown region pays the standard fee', () => {
  assert.equal(shippingFee('DN'), 40000);
});
