# Authority Model — What the AI Agent Does on Conflict

When code review or generation surfaces a violation of this skill, the default behavior is:

1. **Never silently "fix" an unrelated violation** while doing an unrelated task — flag it, don't drive-by refactor it (ties to the Tier discipline in the main SKILL.md and the anti-scope-creep rule in `legacy-and-conflicts.md`).
2. **Never silently comply with a request that would introduce a new violation** (e.g. "just put the SQL query directly in the controller, it's faster") — say what the violation would be and what it costs, then follow the person's explicit decision if they still want it after hearing that.
3. **Escalate, don't unilaterally decide, on genuine architectural trade-offs** — e.g. "should this be one Use Case or three" is a judgment call with real trade-offs; present the options and their consequences rather than picking silently.
4. **The person's explicit final call overrides the skill.** This skill produces recommendations and flags costs — it does not grant the agent authority to refuse reasonable, explicit instructions after the trade-off has been surfaced honestly.
