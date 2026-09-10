#!/bin/bash

set -e

cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
REVIEWDOG_INSTALL_SCRIPT="$(mktemp)"
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh -o "$REVIEWDOG_INSTALL_SCRIPT"
sh "$REVIEWDOG_INSTALL_SCRIPT" -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

echo '::group:: Installing woke ... https://github.com/get-woke/woke'
WOKE_INSTALL_SCRIPT="$(mktemp)"
curl -sfL https://raw.githubusercontent.com/get-woke/woke/main/install.sh -o "$WOKE_INSTALL_SCRIPT"
sh "$WOKE_INSTALL_SCRIPT" -b "${TEMP_PATH}" "${INPUT_WOKE_VERSION}" 2>&1
echo '::endgroup::'


echo '::group:: Running woke with reviewdog 🐶 ...'
woke_args=()
if [ -n "$INPUT_WOKE_ARGS" ]; then
  while IFS= read -r -d '' t; do woke_args+=("$t"); done \
    < <(printf '%s' "$INPUT_WOKE_ARGS" | xargs printf '%s\0')
fi

reviewdog_flags=()
if [ -n "$INPUT_REVIEWDOG_FLAGS" ]; then
  while IFS= read -r -d '' t; do reviewdog_flags+=("$t"); done \
    < <(printf '%s' "$INPUT_REVIEWDOG_FLAGS" | xargs printf '%s\0')
fi

woke --output simple "${woke_args[@]}" \
  | reviewdog -efm="%f:%l:%c: %m" \
      -name="woke" \
      -reporter="${INPUT_REPORTER:-github-pr-check}" \
      -filter-mode="${INPUT_FILTER_MODE:-added}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR:-false}" \
      -level="${INPUT_LEVEL}" \
      "${reviewdog_flags[@]}"
echo '::endgroup::'
