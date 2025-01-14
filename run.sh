#!/usr/bin/env bash
# Copyright (c) 2023 OpenHW Group
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

set -e

cd $(dirname "$0")


echo "Running RISC-V Compliance Framework on CV32E40P v1.0.0"
echo "Before running \"riscof\", this command will:"
echo "  -- delete the cv32e40p and riscv-arch-test directories (if they exist)"
echo "  -- clone the cv32e40p and riscv-arch-test submodules (thereby reinstating above dirs)"
echo "  -- apply a patch to cv32e40p (patch-file is in plugin-cv32e40p)"
read -p "Is that what you want? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

rm -rf cv32e40p
rm -rf riscv-arch-test

git submodule update --init
git apply plugin-cv32e40p/cv32e40p_manifest.patch

# Display git hashes of submodules
echo "CV32E40P Hash:"
cd cv32e40p
git log -1 --pretty=format:"%H"
cd ../
echo ""
echo "RISCV-ARCH-TEST Hash:"
cd riscv-arch-test
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
