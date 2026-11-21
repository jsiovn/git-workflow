// Shipping fee in VND, by delivery region.
const FEES = { HCM: 20000, HN: 30000 };
const STANDARD_FEE = 40000;

export const shippingFee = (region) => FEES[region] ?? STANDARD_FEE;
