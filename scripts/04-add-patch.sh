#!/usr/bin/env bash
# Post section 5.1: git add -p stages the logic change and leaves the debug log.
# The answers a developer would type are piped in: s (split), y, y, n.
source "$(dirname "$0")/lib.sh"

fresh_dir 04-add-patch

# Setup: checkout.js, committed; then one edit that mixes logic and a debug log.
git init -q repo
cd repo
clock 50
cat > checkout.js <<'EOF'
export function checkout(cart) {
  const total = cart.reduce((s, i) => s + i.price, 0);
  return { total };
}
EOF
git add checkout.js
git commit -q -m 'feat(checkout): tính tổng giỏ hàng'
cat > checkout.js <<'EOF'
export function checkout(cart, coupon) {
  const total = cart.reduce((s, i) => s + i.price, 0);
  const discounted = coupon ? total * 0.9 : total;
  return { total: discounted };
}

// TODO: xóa log này trước khi push
console.log('debugging');
EOF

echo '# Section 5.1: one hunk mixes the coupon logic and a debug log'
run 'git diff'
echo

echo '# git add -p: split the hunk, stage the two logic hunks, skip the log'
echo '# (prompts end without a newline, so each answer runs into the next line)'
run "printf 's\\ny\\ny\\nn\\n' | git add -p"
echo
echo

echo '# Staged: the logic only'
run 'git diff --cached'
echo

echo '# Not staged: the debug log'
run 'git diff'
