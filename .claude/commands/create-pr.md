---
description: Create a new branch, commit changes, and submit a pull request with automatic commit splitting
category: version-control-git
allowed-tools: Bash(git *), Bash(gh *), Bash(biome *), Bash(mix format), Bash(script *), mcp__github__*
---

# Create Pull Request Command

Get local changes onto a branch as reviewable commits, then hand off to the
`open-pr` skill to write the description and open the PR.

Everything about the PR itself — base branch and stack detection, template
discovery, description, title, reviewers, labels, draft mode — lives in `open-pr`.
Do not restate it here; the two drifted apart once already.

## Branch

1. Read the current stack with the `gh-stack` skill (`git stack` as the fallback)
2. If the current branch is `develop`, `master`, or `main`, create a new branch
   for the work. Never commit to one of those directly
3. Check whether the current branch already has an open PR:
   `gh pr list --head "$(git branch --show-current)"`. If it does, the new changes
   belong on their own branch rather than being added to one under review

Route branch creation by what the work needs, per the rules in `CLAUDE.md`:

- The current branch is in a stack, or the work is a layer on top of it: use
  `gh stack add <branch>` from the `gh-stack` skill. It branches from the current
  layer and registers the new one, which plain `git checkout -b` does not
- The work needs its own directory: use the `create-worktree` skill
- Neither applies: plain `git`

## Commit

1. Format the modified files (`mix format`, `biome`, whatever the repo uses)
2. Split the changes into logical commits:
   - Split by feature, component, or concern
   - Keep related file changes together
   - Separate refactoring from feature additions
   - Each commit should be understandable on its own
3. Write the messages in the repo's existing style. In repos that use emoji
   conventional commits, match that
4. Never reference Claude, Anthropic, or any AI tool in a commit message

## Open the PR

Invoke the `open-pr` skill. It handles the rest.
