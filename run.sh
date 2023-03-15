#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

set -e

cd $(dirname "$0")

# CV32E40P git hash
echo "CV32E40P Hash to be used:"
cd cv32e40p
git log -1 --pretty=format:"%H"
cd ../
echo ""
sleep 2

# run riscof
riscof run --config=config.ini \
           --suite=riscv-arch-test/riscv-test-suite/ \
           --env=riscv-arch-test/riscv-test-suite/env \
           --no-browser

# check report - run successful?
if grep -rniq riscof_work/report.html -e '>0failed<'
then
  echo "Test successful!"
  exit 0
else
  echo "Test FAILED!"
  exit 1
fi
