# AGENTS.md — nix-clawdbot

Single source of truth for product direction: `README.md`.

Documentation policy:
- Keep the surface area small.
- Avoid duplicate “pointer‑only” files.
- Update `README.md` first, then adjust references.

Defaults:
- Nix‑first, no sudo.
- Declarative config only.
- Batteries‑included install is the baseline.
- Breaking changes are acceptable pre‑1.0.0 (move fast, keep docs accurate).
- NO INLINE SCRIPTS EVER.
- NEVER send any message (iMessage, email, SMS, etc.) without explicit user confirmation:
  - Always show the full message text and ask: “I’m going to send this: <message>. Send? (y/n)”

Clawdbot packaging:
- The gateway package must include Control UI assets (run `pnpm ui:build` in the Nix build).

Golden path for pins (yolo + manual bumps):
- Hourly GitHub Action **Yolo Update Pins** runs `scripts/update-pins.sh`, which:
  - Picks latest upstream clawdbot SHA with green non-Windows checks
  - Rebuilds gateway to refresh `pnpmDepsHash`
  - Regenerates `nix/generated/clawdbot-config-options.nix` from upstream schema
  - Updates app pin/hash, commits, rebases, pushes to `main`
- Manual bump (rare): `GH_TOKEN=... scripts/update-pins.sh` (same steps as above). Use only if yolo is blocked.
- To verify freshness: `git pull --ff-only` and check `nix/sources/clawdbot-source.nix` vs `git ls-remote https://github.com/clawdbot/clawdbot.git refs/heads/main`.
- If upstream is moving fast and tighter freshness is needed, trigger yolo manually: `gh workflow run "Yolo Update Pins"`.

Philosophy:

The Zen of ~~Python~~ Clawdbot, ~~by~~ shamelessly stolen from Tim Peters

Beautiful is better than ugly.  
Explicit is better than implicit.  
Simple is better than complex.  
Complex is better than complicated.  
Flat is better than nested.  
Sparse is better than dense.  
Readability counts.  
Special cases aren't special enough to break the rules.  
Although practicality beats purity.  
Errors should never pass silently.  
Unless explicitly silenced.  
In the face of ambiguity, refuse the temptation to guess.  
There should be one-- and preferably only one --obvious way to do it.  
Although that way may not be obvious at first unless you're Dutch.  
Now is better than never.  
Although never is often better than *right* now.  
If the implementation is hard to explain, it's a bad idea.  
If the implementation is easy to explain, it may be a good idea.  
Namespaces are one honking great idea -- let's do more of those!

Nix file policy:
- No inline file contents in Nix code, ever.
- Always reference explicit file paths (keep docs as real files in the repo).
- No inline scripts in Nix code, ever (use repo scripts and reference their paths).
