// One line per item, then the total, as printed on the receipt.
export const formatReceipt = (items) => {
  const lines = items.map((item) => `${item.name} x${item.qty}: ${item.price * item.qty}`);
  const total = items.reduce((sum, item) => sum + item.price * item.qty, 0);
  return [...lines, `Total: ${total}`].join('\n');
};
