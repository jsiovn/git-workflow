// A coupon code takes a percentage off the cart total (VND, rounded).
const COUPONS = { SALE10: 10, SALE20: 20 };

export const applyCoupon = (total, code) =>
  Math.round((total * (100 - (COUPONS[code] ?? 0))) / 100);
