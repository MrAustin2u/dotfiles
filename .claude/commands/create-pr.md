---
description: Create a new branch, commit changes, and submit a pull request with automatic commit splitting
category: version-control-git
allowed-tools: Bash(git *), Bash(gh *), Bash(biome *), Bash(mix format), Bash(script *), mcp__github__*
---

# Create Pull Request Command

Create a new branch, commit changes, and submit a pull request.

## Behavior

- Creates a new branch based on current changes, only if in develop, master or main
- Formats modified files
- Analyzes changes and automatically splits into logical commits when appropriate
- Each commit focuses on a single logical change or feature
- Creates descriptive commit messages for each logical unit
- Pushes branch to remote
- Creates pull request with proper summary and description
- Never ever reference Claude, Anthropic, or any AI reference

## Guidelines for Automatic Commit Splitting

- Split commits by feature, component, or concern
- Keep related file changes together in the same commit
- Separate refactoring from feature additions
- Ensure each commit can be understood independently
- Multiple unrelated changes should be split into separate commits

## Guidelines for Creating Pull Requests

- Use Jira ticket number in pull request title if available in branch name
- Check for pull request template, and fill all the requirements
- **PRIMARY METHOD**: Try using the github-mcp-server tools first:
  - Use `mcp__github__github-create-pr` tool to create the pull request
  - Use `mcp__github__github-get-push-branch` to check if branch exists remotely
  - Use `mcp__github__github-list-prs` to check for existing PRs
  - Extract owner/repo from git remote URL using `git config --get remote.origin.url`
  - Parse remote URL formats: `git@github.com:owner/repo.git` or `https://github.com/owner/repo.git`
- **FALLBACK METHOD**: If github-mcp-server is not available or fails, use gh CLI:
  - **CRITICAL**: Always wrap `gh` commands with `script -q /dev/null` to provide a pseudo-terminal and avoid "interactive IO not available" errors
  - **CRITICAL**: Always use non-interactive flags for `gh pr create`:
    - `--title "PR Title"` - Required: Set PR title
    - `--body "PR Description"` or `--body-file path/to/file` - Required: Set PR description
    - `--base branch-name` - Required: Set base branch (usually develop, main, or master)
    - `--draft` - Optional: Create as draft PR
    - `--web` - Optional: Open in browser after creation
  - Never use interactive `gh pr create` without these flags as it will fail in non-interactive environments
- If a pull request template exists (.github/pull_request_template.md), read it and format the --body accordingly

## Example PR Creation with MCP Server

```
1. Get current branch: git branch --show-current
2. Get remote URL: git config --get remote.origin.url
3. Parse owner/repo from URL (e.g., "git@github.com:owner/repo.git" -> owner="owner", repo="repo")
4. Check if branch exists remotely: mcp__github__github-get-push-branch with owner, repo, branch
5. Push branch if needed: git push -u origin branch-name
6. Create PR: mcp__github__github-create-pr with owner, repo, title, body, head (branch), base (e.g., "develop"), draft
```

## Example PR Creation Commands (Fallback)

```bash
# Standard PR (use script wrapper to avoid interactive IO errors)
script -q /dev/null gh pr create --title "[TICKET-123] Add feature" --body "Description here" --base develop

# Using PR template
script -q /dev/null gh pr create --title "[TICKET-123] Add feature" --body-file /tmp/pr-body.txt --base develop

# Draft PR
script -q /dev/null gh pr create --draft --title "[TICKET-123] WIP: Add feature" --body "Work in progress" --base develop

# Check if PR already exists for current branch
script -q /dev/null gh pr list --head "$(git branch --show-current)"
```
