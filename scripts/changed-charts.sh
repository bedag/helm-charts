#!/usr/bin/env bash
set -o pipefail

repository=$(git rev-parse --show-toplevel)
: "${CT_CONFIG:-$repo_root/ct.yaml}"
changed_charts=$(ct list-changed --config "${CT_CONFIG}")
echo "$changed_charts"