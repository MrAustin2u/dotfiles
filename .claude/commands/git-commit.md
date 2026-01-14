---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Read(~/.config/git/commit-template)
description: Create a git commit
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes, create a single git commit.
Follow the formatting guidelines in ~/.config/git/commit-template

## Restrictions

- Don't add anthropic/claude references
- Don't add co-authored
- Don't add generated with
