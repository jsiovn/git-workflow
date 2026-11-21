// Orders from 500,000 VND ship for free.
export const FREE_SHIPPING_FROM = 500000;

export const isFreeShipping = (subtotal) => subtotal >= FREE_SHIPPING_FROM;
