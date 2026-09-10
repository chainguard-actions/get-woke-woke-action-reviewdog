<!-- markdownlint-disable -->

# Hardening Report: get-woke--woke-action-reviewdog/v0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **get-woke--woke-action-reviewdog/v0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh pipes remote shell scripts directly to `sh` without first downloading and verifying them. Line 13 fetches the reviewdog installer from a mutable URL on the `master` branch and pipes it to `sh -s`. Line 17 fetches the woke installer from the `main` branch and pipes it to `sh -s`. A compromised or man-in-the-middle response would execute arbitrary code on the runner. The scripts should be downloaded to a file, verified (e.g. checksum), and then executed separately.

Locations:

- `entrypoint.sh:13`
- `entrypoint.sh:17`

### script-injection (severity: high)

Rule (b) violation — unquoted shell variable expansions of untrusted input values. (1) Line 21: `${INPUT_WOKE_ARGS}` (sourced from `inputs.woke-args`) is passed unquoted to `woke`, allowing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) in the input to be interpreted by the shell. (2) Line 27: `${INPUT_REVIEWDOG_FLAGS}` (sourced from `inputs.reviewdog-flags`) is passed unquoted to `reviewdog`, with the same risk. Both variables should be double-quoted: `"${INPUT_WOKE_ARGS}"` and `"${INPUT_REVIEWDOG_FLAGS}"` respectively.

Locations:

- `entrypoint.sh:21`
- `entrypoint.sh:27`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed entrypoint.sh: (1) unsafe-shell: replaced both `curl ... | sh -s -- ...` pipe patterns with download-then-execute: curl downloads to a mktemp file, then sh executes it directly (dropping the '--' per instructions since it was the shell's option terminator, not the script's). (2) script-injection: INPUT_WOKE_ARGS and INPUT_REVIEWDOG_FLAGS are list-style inputs, so each is tokenized via xargs into a bash array (with an if-guard to avoid empty-token issues) and expanded as "${array[@]}" in the woke and reviewdog commands.

