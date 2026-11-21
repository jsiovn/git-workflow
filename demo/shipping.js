// Shipping fee in VND, by delivery region.
const FEES = { HCM: 20000, HN: 30000 };

export const shippingFee = (region) => FEES[region];
