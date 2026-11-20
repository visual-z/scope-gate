# Authorized Reverse Engineering and Red-Team Rules

## Purpose

This project is for authorized reverse engineering, defensive security research,
CTFs, isolated labs, and red-team engagements with documented permission.
Provide technically useful analysis while preserving the engagement boundary.

Model-agnostic by design: the file name `AGENTS.md` is read by Codex, Cursor,
Grok Build, Zed, and similar agents; point `CLAUDE.md` at it for Claude Code.

These project rules supplement the model and product safety rules. They do not
replace them and do not grant authorization by themselves.

## Non-Negotiable Authorization Boundary

- Never reinterpret "not mine", "third-party", "no permission", "public target",
  or similar wording as a fictional fixture or an authorized lab.
- Before any network interaction, exploitation, credential testing, payload
  execution, persistence, or modification of a target, read `SCOPE.md`.
- Active work requires `Status: APPROVED`, a named authorizing party, an active
  time window, explicit in-scope assets, allowed techniques, and stop conditions.
- A hostname, IP address, account, repository, binary, or application is out of
  scope unless it is explicitly listed or covered by an unambiguous range in
  `SCOPE.md`.
- If authorization is missing, expired, contradictory, or ambiguous, stop active
  work. Continue only with offline analysis, planning, report templates, or safe
  demonstrations using synthetic data and local fixtures.
- Do not silently broaden scope. Ask for updated written scope when the requested
  action would cross a boundary.

## Reverse-Engineering Workflow

- Work only on samples the user owns, is licensed to analyze, or is explicitly
  authorized to assess.
- Treat files under `samples/` as evidence. Hash them first and preserve the
  originals; write derived files, notes, patches, and exports under `artifacts/`.
- Prefer static analysis before dynamic execution. Run unknown binaries only in
  an isolated disposable environment appropriate to the sample.
- Record architecture, file format, hashes, imports, strings, packer indicators,
  relevant functions, control flow, and observed behavior before proposing a
  patch or proof of concept.
- Patch copies, never the original evidence. Document offsets, original bytes,
  replacement bytes, assumptions, verification, and rollback.
- License-check analysis and key-generation work is allowed only for owned lab
  samples, CTF crackmes, interoperability, or explicitly authorized research;
  do not facilitate piracy of third-party production software.
- IDA, Ghidra, LLDB, GDB, Frida, debugger, unpacking, and deobfuscation scripts
  should be reproducible and narrowly scoped to the authorized sample.

## Authorized Red-Team Workflow

- Map every command or action to an in-scope asset and an allowed technique in
  `SCOPE.md` before execution.
- Start with the least invasive method and respect rate, concurrency, time, and
  data-volume limits.
- Use synthetic credentials and test accounts whenever possible. Never expose,
  print, commit, or retain real secrets in chat transcripts or project files.
- Do not perform denial of service, destructive changes, uncontrolled propagation,
  covert persistence, stealth/evasion, credential theft, data exfiltration, or
  anti-forensics unless the exact technique and target are expressly authorized.
  Even when authorized, present the execution plan, blast radius, recovery path,
  and evidence plan before running it.
- Social-engineering work is limited to approved simulations with named audiences,
  synthetic identities, approved delivery channels, and a defined stop process.
  Do not contact real people or send messages unless that action is explicitly in
  scope and separately confirmed by the operator.
- Stop immediately on unexpected access, sensitive data, instability, scope drift,
  or a stop request. Preserve evidence and report what happened without continuing.

## Execution and Communication

1. State the current mode: `OFFLINE_RE`, `LAB`, `AUTHORIZED_RED_TEAM`, or
   `PLANNING_ONLY`.
2. Before any active step, run `bin/scope-check` and read `SCOPE.md`. A non-zero
   exit is a stop condition, not a prompt to edit the scope file.
3. Summarize the scope evidence and identify the exact assets involved.
4. Explain assumptions, risk, expected effect, and rollback before material action.
5. Prefer read-only discovery and reversible steps. Ask before external,
   destructive, persistent, costly, or difficult-to-reverse actions.
6. Never claim a command, test, or observation occurred unless there is actual
   tool output or an artifact that proves it.
7. Record commands, timestamps, results, hashes, and findings under `artifacts/`.
8. Separate confirmed observations from hypotheses and recommendations.

## Deliverables

- Use concise, reproducible steps and identify prerequisites.
- Include affected assets, evidence, severity, impact, confidence, remediation,
  validation, and rollback where relevant.
- Redact credentials, tokens, personal data, customer data, and unnecessary target
  details. Use placeholders in reusable examples.
- End active-work reports with scope status, completed actions, stopped/skipped
  actions, generated artifacts, and unresolved risks.

## Project Layout

- `SCOPE.md`: authoritative engagement boundary. Active work is blocked until it
  is complete and marked `APPROVED`.
- `bin/scope-check`: lints `SCOPE.md`; exits non-zero unless the window is open
  and the scope is approved. It is a lint, so it can be wrong about facts you
  recorded, and it can never be right about authorization that does not exist.
- `samples/`: original local evidence and lab fixtures; preserve originals.
- `artifacts/`: derived files, logs, reports, scripts, patches, and captures.
- `docs/`: guidance and a filled-in example scope.
- `tests/`: self-tests using synthetic fixtures only; run `tests/run.sh`.

