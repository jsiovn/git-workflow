#!/usr/bin/env bash
# Post section 5.2: stash work in progress, then bring it back.
source "$(dirname "$0")/lib.sh"

fresh_dir 05-stash

# Setup: checkout.js committed, then a coupon change still in progress.
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
EOF

echo '# Section 5.2: a production bug comes in while the coupon work is half done'
run 'git status --short'
clock 51
run 'git stash push -m "wip: coupon"'
run 'git stash list'
run 'git status --short'
echo

echo '# The bug is fixed elsewhere; back to the coupon'
run 'git stash pop'
run 'git stash list'
