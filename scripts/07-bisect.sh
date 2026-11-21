#!/usr/bin/env bash
# Post section 5.4: git bisect run finds the commit that broke the total.
# Needs node on PATH (the test is a tiny ES module).
source "$(dirname "$0")/lib.sh"

fresh_dir 07-bisect

# Setup: a cart total with 10% VAT. Integer math gives 385 for a 350 cart;
# the VAT commit switches to `sum * 1.1`, which gives 385.00000000000006.
git init -q repo
cd repo

write_total() {
  cat > total.js <<EOF
export const total = (items) => {
  const sum = items.reduce((s, i) => s + i.price, 0);
  return $1;
};
EOF
}

clock 20
printf '%s\n' '{ "type": "module", "dependencies": { "lodash": "4.17.20" } }' > package.json
write_total 'sum + (sum * 10) / 100'
cat > test.mjs <<'EOF'
import { total } from './total.js';

const got = total([{ price: 100 }, { price: 250 }]);
if (got === 385) {
  console.log('PASS');
} else {
  console.log(`FAIL: got ${got}`);
  process.exit(1);
}
EOF
git add .
git commit -q -m 'feat(cart): tính tổng tiền có VAT'
good="$(git rev-parse --short HEAD)"

clock 21
printf '%s\n' '# cart' 'Cart total with VAT.' > README.md
git add README.md
git commit -q -m 'docs: thêm README'

clock 22
printf '%s\n' '{ "type": "module", "dependencies": { "lodash": "4.17.21" } }' > package.json
git commit -q -am 'chore(deps): bump lodash'

clock 23
write_total 'sum * 1.1'
git commit -q -am 'feat(cart): cộng VAT vào tổng'

clock 24
cat > total.js <<'EOF'
export const total = (items) => {
  const sum = items.reduce((s, item) => s + item.price, 0);
  return sum * 1.1;
};
EOF
git commit -q -am 'style(cart): format lại code'

clock 25
printf '%s\n' 'Run the test with `node test.mjs`.' >> README.md
git commit -q -am 'docs: hướng dẫn chạy test'

echo '# Section 5.4: the test passed on an old commit and fails on HEAD'
run 'git log --oneline'
run 'node test.mjs || true'
echo

echo "# Bisect between HEAD (bad) and $good (good), and let the test decide"
run "git bisect start HEAD $good --"
run 'git bisect run node test.mjs'
run 'git bisect reset'
