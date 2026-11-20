# Scope Gate

A small, model-agnostic workspace template for authorized reverse engineering,
lab work, and red-team engagements — including engagements where an AI coding
agent does part of the work.

Everything here rests on one idea: **no active work until a written, complete,
approved scope exists**, and that scope lives in a file the agent is told to read
before it touches anything.

It is a scaffold, not a security control and not a substitute for written
authorization from the asset owner.

## What's in the box

| Path                | Purpose                                                        |
| ------------------- | -------------------------------------------------------------- |
| `AGENTS.md`         | Operating rules an agent loads automatically from the repo root |
| `SCOPE.md`          | The authorization gate. `DRAFT` blocks active work             |
| `bin/scope-check`   | Lints `SCOPE.md`; exits non-zero unless the current window is approved |
| `tests/run.sh`      | Self-test for `bin/scope-check` using synthetic fixtures        |
| `samples/`          | Owned or authorized local samples; originals are preserved      |
| `artifacts/`        | Derived notes, logs, scripts, patches, evidence                 |
| `docs/example-scope.md` | A filled-in example so you can see what "complete" looks like |

`samples/` and `artifacts/` are gitignored except for their READMEs, so real
binaries and evidence do not get committed by accident.

## Quick start

```bash
# 1. copy or "Use this template" the repo, then work inside your copy
# 2. fill in SCOPE.md — every field, including stop conditions and time window
# 3. confirm the gate agrees before starting
bin/scope-check            # exits 1 and says what is missing
# 4. only then flip Status: APPROVED
bin/scope-check && echo "scope approved, window open"
# 5. start your agent from the repo root so AGENTS.md is loaded
```

The default state of a fresh copy is `Status: DRAFT`. That is deliberate: a
template cannot ship approved scope, because approval is a fact about a specific
engagement, not about a file.

## How the gate works

1. `AGENTS.md` tells the agent to read `SCOPE.md` before any network traffic,
   exploitation, credential testing, payload execution, persistence, or target
   modification, and to state the mode it is in (`OFFLINE_RE`, `LAB`,
   `AUTHORIZED_RED_TEAM`, `PLANNING_ONLY`).
2. `SCOPE.md` must say `Status: APPROVED`, name the authorizing party, list
   in-scope assets, allowed techniques, limits, stop conditions, and an active
   time window.
3. Anything not listed is out of scope. Ambiguity stops work; it does not
   resolve in favor of proceeding.
4. `bin/scope-check` is the mechanical part: it refuses `DRAFT`, missing fields,
   an empty asset list, no allowed technique, no stop condition, and an expired
   or unparseable window.

```console
$ bin/scope-check
Scope gate: BLOCKED
  - Status is 'DRAFT', not 'APPROVED'
  - 3 required field(s) empty: Authorizing organization/person, Emergency/stop contact, ...
```

### Enforcement

`bin/scope-check` is a lint, not an enforcement agent. If you want it to bite:

- run it in a `pre-commit` hook, or in your shell prompt;
- wrap the commands that matter (`nmap`, `sqlmap`, `ffuf`, agent launchers) in a
  small shim that calls it first;
- re-check whenever the scope file changes, and treat any edit to `SCOPE.md` as a
  reason to re-read it rather than as a formality.

## Using it with different agents

- **Grok Build, Codex, Cursor, Zed, and similar** read `AGENTS.md` at the repo
  root, so no extra wiring is needed.
- **Claude Code** reads `CLAUDE.md`; link it rather than duplicating the rules:

  ```bash
  ln -s AGENTS.md CLAUDE.md
  ```

- Agents with no file convention still benefit: paste `AGENTS.md` and the
  completed `SCOPE.md` into the first turn, and keep `bin/scope-check` as the
  human-run check that the window is open.

## Rules of engagement this template assumes

Least-invasive method first; respect rate, concurrency, volume, and time limits;
synthetic credentials whenever possible; stop on unexpected access, sensitive
data, instability, or scope drift; preserve evidence; never claim a command ran
without output that proves it. Reports end with scope status, actions taken,
actions skipped, artifacts produced, and open risks.

## What this is not

- Not legal advice, and not a grant of permission. `Status: APPROVED` only means
  *you* recorded an authorization that already exists in writing elsewhere.
- Not a sandbox. Isolation, disposable VMs, and network segmentation are still
  your responsibility.
- Not a scanner, an exploitation framework, or a payload set. It ships no
  offensive tooling.

## License

MIT — see [LICENSE](LICENSE).