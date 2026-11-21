import assert from 'node:assert/strict';
import test from 'node:test';
import { applyCoupon } from './coupon.js';

test('SALE10 takes 10% off', () => {
  assert.equal(applyCoupon(200000, 'SALE10'), 180000);
});

test('an unknown code changes nothing', () => {
  assert.equal(applyCoupon(200000, 'NOPE'), 200000);
});
