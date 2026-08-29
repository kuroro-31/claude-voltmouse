# voltmouse

A pixel-art electric mouse that lives in your [Claude Code](https://claude.com/claude-code)
status line. It greets you when a session starts, reflects how much context and
rate-limit headroom is left, and reacts when Claude needs you.

```
▀▄   ▄▀  ⚡ Opus 5/low ▸ cx 12% ▸ 5h 3% ▸ 7d 9%
▐▀▀▀▀▀▌  claude-voltmouse ▸ ⎇ main
▝▀▀▀▀▀▘
```

(The real thing is drawn in colour with half-block characters.)

## Install

```
claude plugin marketplace add kuroro-31/claude-voltmouse
claude plugin install voltmouse
```

Then turn the status line on:

```
/voltmouse:on
```

Claude Code plugins cannot ship a status line directly, so `/voltmouse:on`
writes the `statusLine` entry into your `~/.claude/settings.json` and keeps a
backup of whatever was there before. `/voltmouse:off` puts it back.

Requires `bash` and `jq`.

## Moods

The mouse changes with your session:

| Mood | When |
| --- | --- |
| `normal` | plenty of headroom |
| `zap` | 5-hour rate limit at 80% or more — ears charged |
| `tired` | context window at 70% or more |
| `sleep` | context window at 90% or more |

`/voltmouse:mood` previews them all. Set `VOLTMOUSE_MOOD=happy` to pin one.

## Commands

| Command | What it does |
| --- | --- |
| `/voltmouse:on` | Enable the status line |
| `/voltmouse:off` | Restore the previous status line |
| `/voltmouse:mood` | Preview every mood |

## Configuration

Set these in your shell or in `settings.json` under `env`:

| Variable | Default | Meaning |
| --- | --- | --- |
| `VOLTMOUSE_MOOD` | *(automatic)* | Pin one mood |
| `VOLTMOUSE_NAME` | `voltmouse` | Name shown in the greeting |
| `VM_Y` `VM_K` `VM_R` `VM_W` | see `scripts/pixel.sh` | Body, dark, cheek and charged colours as `R;G;B` |

## Notes

voltmouse is an original character. It is not affiliated with, endorsed by, or
derived from Pokémon, Nintendo, or any other franchise.

## License

MIT. See [LICENSE](LICENSE).
