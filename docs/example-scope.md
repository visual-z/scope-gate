# Example: what a complete scope looks like

> **Synthetic illustration, not authorization.** Every value below is a
> placeholder or a reserved documentation range. Copy the *shape*, never the
> *content*: what makes a scope real is a written approval from the party that
> owns the assets — and that approval stays in your ticketing system, not in this
> repository.

```markdown
# Engagement Scope

Status: APPROVED

## Authorization

- Engagement name: <engagement name>
- Authorizing organization/person: <asset owner, named person>
- Operator: <your handle>
- Written authorization evidence path or reference: <ticket/contract id, stored outside this repo>
- Approval date: <YYYY-MM-DD>
- Start time and timezone: 2026-11-17 09:00 UTC
- End time and timezone: 2026-11-17 17:00 UTC
- Emergency/stop contact: <out-of-band contact, verified before start>

## In-Scope Assets

- 192.0.2.0/24 (RFC 5737 documentation range, isolated test VLAN)
- <hostname or URL of the lab target>
- <synthetic account 1>, <synthetic account 2>

## Out-of-Scope Assets

- Anything outside the range above
- The hypervisor and its management interface
- Real user data, if any is unexpectedly encountered

## Allowed Techniques

- [x] Offline static analysis
- [x] Isolated dynamic analysis
- [x] Network discovery and enumeration
- [x] Authenticated application testing
- [x] Exploit validation
- [ ] Privilege-escalation validation
- [ ] Lateral-movement simulation
- [ ] Persistence simulation
- [ ] Social-engineering simulation

## Explicitly Prohibited Techniques

- Denial of service, including load or fuzzing that degrades the host
- Any outbound traffic to the public internet
- Destructive writes beyond the provided snapshots

## Operational Limits

- Source IPs / test runners: <single test runner address>
- Rate and concurrency limits: <e.g. 5 req/s, 2 concurrent scanners>
- Approved test accounts: <synthetic accounts only>
- Data-volume limit: <e.g. 500 MB captured traffic>
- Allowed persistence duration: none; revert snapshots after each session
- Required monitoring/notification: <who is told before and after>
- Stop conditions: host instability, unexpected real data, any signal from the
  asset owner, or the end of the window above

## Evidence and Data Handling

- Evidence storage location: artifacts/ (gitignored)
- Encryption requirements: <none for synthetic data; encrypt for real work>
- Retention period: <e.g. 30 days>
- Required redactions: account names, cookies, and tokens in any shared report
- Reporting recipients: <asset owner>

## Recovery and Cleanup

- Backup/restore owner: <asset owner>
- Cleanup steps: revert snapshots, delete uploaded files, close sessions
- Validation owner: <asset owner>
- Required completion evidence: snapshot IDs and a post-run host health check
```

## Check it

```bash
# extract the block above into a file, then:
bin/scope-check --file scope.md --now 1794916800   # inside the window: OPEN
bin/scope-check --file scope.md                    # today: EXPIRED
```

The example is complete, and the checker still blocks it today, because its
window closed in 2026. That is the point: completeness is not permission, and an
expired approval stops work. Renewing it means obtaining new written
authorization, not editing a timestamp.