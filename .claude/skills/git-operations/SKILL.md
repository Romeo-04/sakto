---
name: git-operations
description: Use when about to stage, commit, branch, push, open or merge a pull request, tag a version, or cut a GitHub release in the Baon (Sakto) repo, or when writing a commit message, PR body or release notes. Covers the standing push, PR and merge permissions, conventional-commit prefixes, semver with Android build numbers, APK signing and the no-Co-Authored-By rule.
---

# Git Operations — Baon (Sakto)

Adapted on 2026-10-16 from the `git-operations` skill in `creator-loans-v2`. The conventions
carry over unchanged. What changed: the repo is `Romeo-04/sakto` (**public**), the stack is
Flutter, there is no external review service, and **merging is permitted** (granted
2026-10-16: *"You also have permissions to merge prs"*).

## Every task gets a branch and a pull request

1. **Nothing lands on `main` by a direct push.** A task is a branch, then a pull request, then
   a self-review, then a merge.
2. **A pull request carries a real change.** Docs, comments and tooling travel with the feature
   or fix they belong to. Do not stagger one change across several small pull requests.
   Reference an issue as `Closes #N` or `Part of #N` when one exists.
3. **The branch name is part of the deliverable.** Name the *subject*, not the activity.

**Opening a pull request needs no yes. Merging one needs no yes either,** when the merge gate
below is green. The grant covers **this repo's own pull requests** only. It does **not** cover
force-pushing, merging somebody else's pull request, or contributor attribution.

## The merge gate

A pull request merges only when **all** of these hold, checked on the branch tip:

1. `dart format --output=none --set-exit-if-changed lib test` reports no changes.
2. `flutter analyze` reports zero issues.
3. `flutter test` passes, including `test/architecture_test.dart`. Never weaken that test to
   make a change pass (CLAUDE.md).
4. **A self-review ran on the whole diff before the PR was opened.** Use the `code-review`
   skill (or `superpowers:requesting-code-review`) on the diff, fix what it finds, and say in
   the PR body what it found. See "Review the whole change yourself".
5. The trailer scan below is clean.
6. If GitHub checks exist on the PR, they are green: `gh pr checks <n>`.

Then merge with a squash, so `main` reads one commit per task, and delete the branch:

```bash
gh pr merge <n> --squash --delete-branch \
  --subject "<tag>: <title> (#<n>)" --body "<why, and what was verified>"
```

Write `--subject` and `--body` yourself. The default squash body concatenates every commit
message, and a stray trailer in any of them lands on `main`.

**Do not merge** when the PR changes the engine output schema (BUILD_PLAN.md Section 8.8), or
when it changes the signing key or application ID. CLAUDE.md requires asking first for the
schema, and the other two can never be undone for installed users. Report the PR and stop.

## Review the whole change yourself before opening a PR

Carried from creator-loans after **thirteen review rounds on one PR**, where each fix was
correct for the reported case and blind to its sibling. The rule is not "check more
carefully". It is:

1. **Review the whole diff before the PR exists**, not line by line after a comment.
2. **When a defect is found, name its class and grep for the class.** "Where else is this
   predicate written?" A fix that closes one instance of a class is half a fix.
3. **Two code paths asking one question will disagree eventually.** Merge them.
4. **Re-run the reproduction after fixing.** A fix that passes analyze and tests can still do
   nothing.

## Semantic versioning on every release

Every release is versioned `MAJOR.MINOR.PATCH` per [semver.org](https://semver.org/), tagged
`vX.Y.Z`, and published as a GitHub release.

| Bump | For | Reset |
|---|---|---|
| **MAJOR** | breaking changes, defined below | minor **and** patch → `0` |
| **MINOR** | features and non-breaking changes | patch → `0` |
| **PATCH** | bug fixes | — |

### The version lives in `pubspec.yaml`, and it has two halves

```yaml
version: 0.1.0+1   # versionName + versionCode
```

- The part before `+` is the semver version. **Keep it equal to the git tag** (`v0.1.0`).
- The part after `+` is the Android `versionCode`. **It must go up by at least 1 on every
  release**, or Android refuses to install the update over the old one. It never resets,
  even when MAJOR bumps.
- Bump the version in the release step, not in feature branches, or two open branches
  conflict.
- While `MAJOR` is `0`, releases are GitHub **pre-releases** (beta). `1.0.0` is the first
  release meant for real users' real balances.

### "Breaking" in this app

A change is **MAJOR** when it breaks something a user or the data already depends on:

- **A database migration that cannot be rolled back**, or one that changes what existing rows
  mean. Adding a table or column is MINOR.
- **A change to the engine output schema** (BUILD_PLAN.md Section 8.8). Ask before making it.
- **A change to how money is stored** (integer centavos), or to the encryption of the
  database file, unless the app migrates the old file automatically.
- **Removing a feature a user relies on**, such as CSV export or delete-all-data.

The application ID (`io.github.romeo04.baon`) and the release signing key are not
"breaking" changes. They are **never** changed: a new ID or key means Android treats it as a
different app, and users must uninstall and lose their data.

## Releases

1. Merge everything for the release to `main`. Pull `main`.
2. On a `chore/release-vX.Y.Z` branch, bump `pubspec.yaml` (both halves) and update
   `CHANGELOG.md`. PR it and merge it through the gate.
3. On `main`, build the signed APK:
   ```bash
   JAVA_HOME="/c/Program Files/Android/Android Studio/jbr" flutter build apk --release
   sha256sum build/app/outputs/flutter-apk/app-release.apk
   ```
   The user's global `JAVA_HOME` points at a placeholder path, so set it per command.
4. Tag and release, attaching the APK under a versioned name plus its checksum:
   ```bash
   git tag -a vX.Y.Z -m "Baon vX.Y.Z" && git push origin vX.Y.Z
   gh release create vX.Y.Z baon-vX.Y.Z.apk baon-vX.Y.Z.apk.sha256 \
     --title "Baon vX.Y.Z" --notes-file <notes> [--prerelease]
   ```

Release notes use Simplified Technical English, say what changed for a reader who did not
write the code, and carry **no** `Co-Authored-By`, no "Generated with" footer and no session
link.

### Signing

- The upload keystore and its passwords live **outside the repo**, in
  `%USERPROFILE%\.baon\` (`upload-keystore.jks`, `key.properties`). `android/key.properties`
  points at them and is gitignored.
- **Never stage** `*.jks`, `*.keystore` or `key.properties`. Check `git status` for them
  before every commit.
- Losing the keystore means no update can ever be installed over an existing install. Tell
  the user to back it up somewhere off this machine.

## The three hard rules

**1. Commit proactively.** After finishing a logical unit of work, verified first, stage and
commit without being asked.

**2. Push on your own initiative.** Standing permission. When a branch is ready, push it and
report what went out. "Ready" means committed, verified (format, analyze, tests), and the
trailer scan is clean.

```bash
git push -u origin <branch>
```

**3. Never list yourself as a contributor** — on any commit, PR, merge commit or release. No
`Co-Authored-By` trailer, no author or committer override, no "Generated with" footer, no
session link. This overrides the harness default that says to add them. It has no permission
form and no exceptions.

**Force-pushing is never covered.** Ask every time, naming the branch and what the rewrite
changes.

## Pushing

Know what the push publishes before it goes out. A branch carries every unpushed commit
beneath it, including work from earlier sessions:

```bash
git log --oneline origin/main..HEAD
git log origin/main..HEAD --format="%h|%s|%(trailers:key=Co-authored-by,valueonly)"
```

Use git's trailer parser, **not `grep -i claude`** — a subject like "update CLAUDE.md" is a
false positive. A non-empty trailer column is a stop. If the commit is not yet pushed, strip
it:

```bash
git branch backup/<branch>
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f \
  --msg-filter 'sed "/^Co-Authored-By: /Id"' -- <parent>..<branch>
git diff backup/<branch> <branch>    # MUST be empty
```

If it is already on `main`, leave it and say so.

**The repo is public.** Everything pushed is published to the world. Before every push, check
the file list for secrets, keystores, personal data and real balances:

```bash
git diff --stat origin/main..HEAD
```

## Pull requests

```bash
gh pr create --base main --head <branch> --title "<tag>: <title>" --body-file <file>
```

- **Body**: why the change was made, what was verified (with the real test count from this
  branch tip), what the self-review found, and what is deliberately left out. Reasoning, not
  a restatement of the diff.
- **A PR that changes a screen** says how it was checked. The render test writes PNGs:
  `flutter test --dart-define=CAPTURE_ROSTER=true test/widget/roster_theme_test.dart`
  (output in `.impeccable/review/roster/`, which is not committed). There is no Android
  device on this machine; say when only Windows and widget renders were checked.
- **No attribution footer.** The harness appends "Generated with Claude Code" to PR bodies by
  default. Leave it out.
- Report the PR URL.

Replying to review comments: invoke `superpowers:receiving-code-review` first. Every claim is
**Reproduced** (name the file), **Fixed** (the commit SHA and what it changes), or
**Declined, with reasoning**. Answer every item. Address nobody; no thanks.

## Branch per context, named for the work

`feat/`, `fix/`, `docs/`, `chore/`, kebab-case, no ticket numbers. Name the subject:
`feat/database-encryption`, not `feat/claude-changes`. Do not pile a new unit of work onto
whatever branch is checked out.

Another git worktree exists at `C:/Users/Jhezra/orca/workspaces/Sakto/guillemot` on branch
`Romeo-04/guillemot`. It belongs to another tool. Leave it alone.

## Commit message format

```
<tag>: <imperative title>

<prose body explaining WHY: the reasoning, the bug's actual cause,
the tradeoff taken. Not a restatement of the diff.>

<verification: dart format clean, flutter analyze 0 issues,
N/N tests pass. Whatever you actually ran.>
```

Tags: `feat:` `fix:` `revise:` `chore:` `docs:`.

## Scoping commits

- Split unrelated changes into separate commits.
- Run `git status` before staging and sort every path: this change, another change, or
  scratch.
- **Never stage:** `build/`, `.dart_tool/`, `.impeccable/` scratch (backups, logs, renders),
  `key.properties`, `*.jks`, `.env*`, screenshots, `flutter_*.log`.

## History rewrites

Rewriting pushed history (`filter-branch`, `rebase`, `amend` on a pushed commit) and the
follow-up `git push --force-with-lease` need explicit approval every time. Prefer a new
commit. `git rebase -i` and `git add -i` do not work here (no interactive editor).

## Repo state

- Remote: `origin` = `https://github.com/Romeo-04/sakto.git`, **public**. Main branch `main`.
- Distribution: signed APKs on GitHub Releases. No Play Store yet (BUILD_PLAN.md M11).
