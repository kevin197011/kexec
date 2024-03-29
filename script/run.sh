#!/usr/bin/env bash
# Copyright (c) 2024 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

set -o errexit
set -o nounset
set -o pipefail

# vars

# run code
export deploy_path="/root/.krun"
rm -rf deploy.sh
wget https://raw.githubusercontent.com/kevin197011/krun/main/deploy.sh
bash deploy.sh