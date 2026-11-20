#!/usr/bin/env bash
# Self-test for bin/scope-check. Synthetic fixtures only; no network, no targets.
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
check="$root/bin/scope-check"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

pass=0
fail=0

# run_case NAME EXPECTED_EXIT NOW FILE
run_case() {
  local name="$1" want="$2" now="$3" file="$4" out rc
  out="$("$check" --file "$file" --now "$now" 2>&1)"; rc=$?
  if [ "$rc" -eq "$want" ]; then
    pass=$((pass + 1)); printf 'ok   %s\n' "$name"
  else
    fail=$((fail + 1)); printf 'FAIL %s (exit %s, wanted %s)\n%s\n' "$name" "$rc" "$want" "$out"
  fi
  LAST_OUT="$out"
}

# expect_message NAME SUBSTRING
expect_message() {
  case "${LAST_OUT:-}" in
    *"$2"*) pass=$((pass + 1)); printf 'ok   %s\n' "$1" ;;
    *) fail=$((fail + 1)); printf 'FAIL %s (missing "%s")\n%s\n' "$1" "$2" "${LAST_OUT:-}" ;;
  esac
}

approved_scope() {
  cat <<'EOF'
# Engagement Scope

Status: APPROVED

## Authorization

- Engagement name: Synthetic lab
- Authorizing organization/person: Lab owner (synthetic)
- Operator: tester
- Written authorization evidence path or reference: approval-ref-1
- Approval date: 2026-11-16
- Start time and timezone: 2026-11-20 09:00 UTC
- End time and timezone: 2026-11-20 17:00 UTC
- Emergency/stop contact: #ops

## In-Scope Assets

- 192.0.2.0/24 (isolated lab VLAN)

## Out-of-Scope Assets

- Anything outside 192.0.2.0/24

## Allowed Techniques

- [x] Offline static analysis
- [ ] Network discovery and enumeration

## Explicitly Prohibited Techniques

- Denial of service

## Operational Limits

- Rate and concurrency limits: 5 req/s
- Stop conditions: host instability, any signal from the lab owner

## Evidence and Data Handling

- Evidence storage location: artifacts/
EOF
}

now_inside=1795176000   # 2026-11-20 12:00 UTC, inside the fixture window

approved_scope > "$tmp/approved.md"
run_case "approved scope inside window" 0 "$now_inside" "$tmp/approved.md"
expect_message "approved scope reports OPEN" "Scope gate: OPEN"

sed 's/^Status: APPROVED/Status: DRAFT/' "$tmp/approved.md" > "$tmp/draft.md"
run_case "draft scope is blocked" 1 "$now_inside" "$tmp/draft.md"
expect_message "draft names the status" "not 'APPROVED'"

sed 's/^Status: APPROVED/Status: approved/' "$tmp/approved.md" > "$tmp/lower.md"
run_case "status match is case-insensitive" 0 "$now_inside" "$tmp/lower.md"

sed 's/^- Authorizing organization\/person:.*/- Authorizing organization\/person:/' "$tmp/approved.md" > "$tmp/nofield.md"
run_case "empty required field is blocked" 1 "$now_inside" "$tmp/nofield.md"
expect_message "empty field is named" "Authorizing organization/person"

awk '/^## In-Scope Assets/{print; getline; print ""; next} 1' "$tmp/approved.md" \
  | sed '/^- 192\.0\.2\.0\/24/d' > "$tmp/noassets.md"
run_case "no assets is blocked" 1 "$now_inside" "$tmp/noassets.md"
expect_message "missing assets reported" "no in-scope assets"

sed 's/^- \[x\] Offline static analysis/- [ ] Offline static analysis/' "$tmp/approved.md" > "$tmp/notechnique.md"
run_case "no allowed technique is blocked" 1 "$now_inside" "$tmp/notechnique.md"
expect_message "missing technique reported" "no allowed technique"

sed 's/^- Stop conditions:.*/- Stop conditions:/' "$tmp/approved.md" > "$tmp/nostop.md"
run_case "no stop conditions is blocked" 1 "$now_inside" "$tmp/nostop.md"
expect_message "missing stop conditions reported" "no stop conditions"

run_case "before window is blocked" 1 1794000000 "$tmp/approved.md"
expect_message "future window reported" "has not opened yet"

run_case "after window is blocked" 1 1796000000 "$tmp/approved.md"
expect_message "expired window reported" "has expired"

sed 's/^- Start time and timezone:.*/- Start time and timezone: 2026-11-20T08:00:00Z/' "$tmp/approved.md" > "$tmp/tformat.md"
run_case "ISO-8601 start time parses" 0 "$now_inside" "$tmp/tformat.md"

sed 's/^- Start time and timezone:.*/- Start time and timezone: sometime tuesday/' "$tmp/approved.md" > "$tmp/badtime.md"
run_case "unparseable time is blocked" 1 "$now_inside" "$tmp/badtime.md"
expect_message "unparseable time reported" "cannot parse start time"

sed 's/^- Start time and timezone:.*/- Start time and timezone: 2026-11-20 18:00/' "$tmp/approved.md" > "$tmp/reversed.md"
run_case "reversed window is blocked" 1 "$now_inside" "$tmp/reversed.md"
expect_message "reversed window reported" "not before end time"

run_case "missing file is blocked" 1 "$now_inside" "$tmp/does-not-exist.md"
expect_message "missing file reported" "not found"

sed 's/^Status: APPROVED/Status: REVOKED/' "$tmp/approved.md" > "$tmp/revoked.md"
run_case "revoked scope is blocked" 1 "$now_inside" "$tmp/revoked.md"

"$check" --bogus >/dev/null 2>&1; rc=$?
if [ "$rc" -eq 2 ]; then pass=$((pass + 1)); echo "ok   unknown argument is a usage error"
else fail=$((fail + 1)); echo "FAIL unknown argument (exit $rc, wanted 2)"; fi

printf '\n%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]