---
description: Preview every voltmouse mood
allowed-tools: Bash(bash:*)
---

Run this to show all moods:

```
bash -c 'source "${CLAUDE_PLUGIN_ROOT}/scripts/pixel.sh"; for m in normal happy tired zap sleep; do echo "-- $m"; vm_sprite "$m"; done'
```

Then explain when each one appears: `tired` at 70% context, `sleep` at 90%,
`zap` at 80% of the 5-hour limit, `normal` otherwise. Mention that setting the
`VOLTMOUSE_MOOD` environment variable pins one mood.
