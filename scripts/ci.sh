#!/bin/sh
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
. scripts/log.sh

# This script runs the continuous integration tests.

x ./scripts/ci-copyright.sh
x cargo xtask textreview
x ./scripts/wrapper.sh mdl -g -s markdownlint.rb .
x ./scripts/ci-taplo.sh
x git submodule update --init third_party/OpenSK
x cargo xtask applet rust opensk
x cargo xtask --release applet rust opensk
( cd examples/rust/opensk
  x cargo test --features=test
  x cargo fmt -- --check
  # TODO: Enable these 2 lines at some point.
  # x cargo clippy --lib --target=wasm32-unknown-unknown -- --deny=warnings
  # x cargo clippy --features=test -- --deny=warnings
)
git diff --exit-code || e 'Modified files'
[ -z "$(git status -s | tee /dev/stderr)" ] || e 'Untracked files'
d "CI passed"
