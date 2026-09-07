#!/bin/sh
set -eu

script="${OPENCLAW_WORKSPACE_MATERIALIZER:?OPENCLAW_WORKSPACE_MATERIALIZER is required}"

work="$(mktemp -d)"
trap 'chmod -R u+w "$work"; rm -rf "$work"' EXIT
stale="$work/workspace/skills/stale"
current="$work/workspace/AGENTS.md"

mkdir -p "$stale" "$work/src"
printf 'stale\n' > "$stale/SKILL.md"
printf 'old-doc\n' > "$current"
printf '%s\n%s\n' "$stale" "$current" > "$work/manifest"
printf 'new-doc\n' > "$work/src/AGENTS.md"
printf '%s\t%s\n' "$work/src/AGENTS.md" "$current" > "$work/source.tsv"
printf '%s\n' "$work/workspace" > "$work/roots"

"$script" "$work/manifest" "$work/source.tsv" "$work/roots"

test ! -e "$stale"
test -f "$current"
grep -q 'new-doc' "$current"
grep -Fxq "$current" "$work/manifest"
! grep -Fxq "$stale" "$work/manifest"

empty_work="$work/empty"
empty_stale="$empty_work/workspace/skills/stale"

mkdir -p "$empty_stale"
printf 'stale\n' > "$empty_stale/SKILL.md"
printf '%s\n' "$empty_stale" > "$empty_work/manifest"
: > "$empty_work/source.tsv"
printf '%s\n' "$empty_work/workspace" > "$empty_work/roots"

"$script" "$empty_work/manifest" "$empty_work/source.tsv" "$empty_work/roots"

test ! -e "$empty_stale"
test ! -s "$empty_work/manifest"

# Cleanup authority comes from configured roots, including custom names and
# multiple instances, rather than path names or the set of desired files.
custom="$work/custom agent"
second="$work/second-agent"
outside="$work/unrelated/workspace"
mkdir -p "$custom/stale" "$second/stale" "$outside" "$custom-sibling"
printf 'keep\n' > "$outside/keep"
printf 'keep\n' > "$custom-sibling/keep"
printf '%s\n' "$custom" "$second/" > "$work/roots"
printf '%s\n' "$custom/stale" "$second/stale" "$outside" "$custom-sibling" \
  "$custom/../unrelated/workspace" "$custom/." "$custom/" > "$work/manifest"
: > "$work/source.tsv"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots" 2> "$work/warnings"
test ! -e "$custom/stale"
test ! -e "$second/stale"
test -f "$outside/keep"
test -f "$custom-sibling/keep"
test -d "$custom"
grep -Fq 'Preserving stale path' "$work/warnings"
grep -Fxq "$outside" "$work/manifest"

# Never remove a configured root (or its ancestor) through a broader root.
mkdir -p "$custom/nested/root"
printf '%s\n' "$custom" "$custom/nested/root" > "$work/roots"
printf '%s\n' "$custom" "$custom/nested" "$custom/nested/root" > "$work/manifest"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots" 2> "$work/warnings"
test -d "$custom/nested/root"

ln -s "$custom/nested/root" "$work/aliased-root"
printf '%s\n' "$custom" "$work/aliased-root" > "$work/roots"
printf '%s\n' "$custom//nested" > "$work/manifest"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots" 2> "$work/warnings"
test -d "$custom/nested/root"

# A removed instance has no remaining authority, even with an empty desired
# manifest. Keep its old state so cleanup can be inspected or retried explicitly.
printf '%s\n' "$outside" > "$work/manifest"
: > "$work/roots"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots" 2> "$work/warnings"
test -f "$outside/keep"
grep -Fxq "$outside" "$work/manifest"

# An intermediate symlink must not turn an in-workspace path into an outside
# delete or replacement. Reject desired escapes before any stale cleanup.
printf '%s\n' "$custom" > "$work/roots"
ln -s "$outside" "$custom/escape"
printf '%s\n' "$custom/escape/keep" > "$work/manifest"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots" 2> "$work/warnings"
test -f "$outside/keep"
mkdir -p "$custom/still-managed"
printf '%s\n' "$custom/still-managed" > "$work/manifest"
printf '%s\t%s\n' "$work/src/AGENTS.md" "$custom/escape/keep" > "$work/source.tsv"
if "$script" "$work/manifest" "$work/source.tsv" "$work/roots" 2> "$work/warnings"; then
  echo 'materializer accepted an escaped desired target' >&2
  exit 1
fi
test -d "$custom/still-managed"
grep -qx keep "$outside/keep"
grep -Fxq "$custom/still-managed" "$work/manifest"

# Final symlinks, including dangling links, can be unlinked safely. Recursive
# removal must also leave symlink targets and hardlinked file modes untouched.
chmod 400 "$outside/keep"
ln -s "$outside/keep" "$custom/final-link"
ln -s "$outside/missing" "$custom/dangling-link"
mkdir -p "$custom/readonly/subdir"
ln -s "$outside" "$custom/readonly/outside-link"
ln "$outside/keep" "$custom/readonly/subdir/hardlink"
chmod 500 "$custom/readonly" "$custom/readonly/subdir"
printf '%s\n' "$custom/final-link" "$custom/dangling-link" "$custom/readonly" > "$work/manifest"
: > "$work/source.tsv"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots"
test ! -L "$custom/final-link"
test ! -L "$custom/dangling-link"
test ! -e "$custom/readonly"
test -f "$outside/keep"
# Portable mode proof on Darwin and Linux, independent of the current uid.
test "$(find "$outside/keep" -perm 0400 -print)" = "$outside/keep"

# Failure to chmod a directory need not prevent its removal from a writable
# parent. Inject that permission error without requiring another system user.
mkdir -p "$work/failing-tools" "$custom/chmod-failure/child"
cat > "$work/failing-tools/chmod" <<'EOF'
#!/bin/sh
touch "$CHMOD_PROBE"
exit 1
EOF
chmod +x "$work/failing-tools/chmod"
printf '%s\n' "$custom/chmod-failure" > "$work/manifest"
PATH="$work/failing-tools:$PATH" CHMOD_PROBE="$work/chmod-attempted" \
  "$script" "$work/manifest" "$work/source.tsv" "$work/roots"
test -f "$work/chmod-attempted"
test ! -e "$custom/chmod-failure"

# Normal nested writes and replacement of a final symlink remain supported.
ln -s "$outside/keep" "$custom/AGENTS.md"
printf '%s\t%s\n' "$work/src/AGENTS.md" "$custom/AGENTS.md" \
  "$work/src/AGENTS.md" "$custom/new/nested/doc.md" > "$work/source.tsv"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots"
test ! -L "$custom/AGENTS.md"
grep -qx new-doc "$custom/AGENTS.md"
grep -qx new-doc "$custom/new/nested/doc.md"
grep -qx keep "$outside/keep"
test "$(find "$outside/keep" -perm 0400 -print)" = "$outside/keep"

# A configured workspace may itself be a symlink. The configured root and the
# target's parent must resolve into the same tree.
ln -s "$second" "$work/linked-root"
printf '%s\n' "$work/linked-root" > "$work/roots"
printf '%s\t%s\n' "$work/src/AGENTS.md" "$work/linked-root/doc.md" > "$work/source.tsv"
: > "$work/manifest"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots"
grep -qx new-doc "$second/doc.md"

# Nix joins a configured workspaceDir ending in '/' with '/<filename>'.
printf '%s\n' "$second/" > "$work/roots"
printf '%s\t%s\n' "$work/src/AGENTS.md" "$second//nested/doc.md" > "$work/source.tsv"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots" 2> "$work/warnings"
grep -qx new-doc "$second/nested/doc.md"

# A generation may replace a managed file with managed descendants, or back.
printf '%s\n' "$custom" > "$work/roots"
printf 'old file\n' > "$custom/notes"
printf '%s\n' "$custom/notes" > "$work/manifest"
printf '%s\t%s\n' "$work/src/AGENTS.md" "$custom/notes/doc.md" > "$work/source.tsv"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots"
grep -qx new-doc "$custom/notes/doc.md"
! grep -Fxq "$custom/notes" "$work/manifest"
printf '%s\t%s\n' "$work/src/AGENTS.md" "$custom/notes" > "$work/source.tsv"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots"
test -f "$custom/notes"
grep -qx new-doc "$custom/notes"

# Optimized store inputs can share inodes and symlinks. Runtime skill copies
# must be ordinary single-link files, including executable helpers.
skill_source="$work/store-backed-skill"
skill_root="$work/runtime skills/prod"
other_skill_root="$work/runtime skills/test"
skill_target="$skill_root/skill"
mkdir -p "$skill_source/scripts" "$skill_root" "$other_skill_root"
printf '# skill\n' > "$skill_source/SKILL.md"
ln "$skill_source/SKILL.md" "$skill_source/hardlinked.md"
ln -s SKILL.md "$skill_source/symlinked.md"
printf '#!/bin/sh\nprintf skill-helper\\n\n' > "$skill_source/scripts/helper"
chmod 555 "$skill_source/scripts/helper"
printf '%s\n%s\n' "$skill_root" "$other_skill_root" > "$work/roots"
printf '%s\t%s\n' "$skill_source" "$skill_target" \
  "$skill_source" "$other_skill_root/skill" > "$work/source.tsv"
: > "$work/manifest"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots"
test -z "$(find "$skill_root" "$other_skill_root" -type l -print)"
test -z "$(find "$skill_root" "$other_skill_root" -type f ! -links 1 -print)"
test -x "$skill_target/scripts/helper"
test "$(find "$skill_source/SKILL.md" -links 2 -print)" = "$skill_source/SKILL.md"

# Refresh and rollback replace files rather than sharing old inodes. A removed
# instance loses cleanup authority; removed skills in an active instance do not.
printf 'updated\n' > "$skill_source/SKILL.md"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots"
grep -qx updated "$skill_target/SKILL.md"
printf '# skill\n' > "$skill_source/SKILL.md"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots"
grep -qx '# skill' "$skill_target/SKILL.md"
printf '%s\n' "$skill_root" > "$work/roots"
: > "$work/source.tsv"
"$script" "$work/manifest" "$work/source.tsv" "$work/roots" 2> "$work/warnings"
test ! -e "$skill_target"
test -f "$other_skill_root/skill/SKILL.md"
grep -Fxq "$other_skill_root/skill" "$work/manifest"
grep -Fq 'Preserving stale path' "$work/warnings"
