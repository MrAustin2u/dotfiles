return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "j-hui/fidget.nvim", -- Display status
    "ravitemer/mcphub.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  init = function()
    vim.cmd [[cab cc CodeCompanion]]
    require("plugins.custom.spinner"):init()
  end,
  config = function()
    require("codecompanion").setup {
      log_level = "WARN",
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            make_tools = true,
            show_server_tools_in_chat = true,
            add_mcp_prefix_to_tool_names = false,
            show_result_in_chat = true,
            format_tool = nil,
            make_vars = false,
            make_slash_commands = true,
          },
        },
      },
      slash_commands = {
        ["commit"] = {
          description = "Create a git commit",
          opts = {
            contains_code = false,
            user_prompt = true,
          },
          prompts = {
            {
              role = "system",
              content = function()
                local git_status = vim.fn.system "git status"
                local git_diff = vim.fn.system "git diff HEAD"
                local git_branch = vim.fn.system("git branch --show-current"):gsub("\n", "")
                local git_log = vim.fn.system "git log --oneline -10"
                local commit_template = ""

                -- Try to read commit template
                local template_path = vim.fn.expand "~/.config/git/commit-template"
                if vim.fn.filereadable(template_path) == 1 then
                  commit_template = table.concat(vim.fn.readfile(template_path), "\n")
                end

                return string.format(
                  [[
## Context

- Current git status: %s
- Current git diff (staged and unstaged changes): %s
- Current branch: %s
- Recent commits: %s

## Your task

Based on the above changes, create a single git commit.
If changes can be placed into separate relevant commits suggest them.
Follow the formatting guidelines below:

%s

## Restrictions

- Don't add anthropic/claude references
- Don't add co-authored
- Don't add generated with
]],
                  git_status,
                  git_diff,
                  git_branch,
                  git_log,
                  commit_template
                )
              end,
            },
          },
        },
        ["pr"] = {
          description = "Create a new branch, commit changes, and submit a pull request with automatic commit splitting",
          opts = {
            contains_code = false,
            user_prompt = true,
          },
          prompts = {
            {
              role = "system",
              content = [[Create a new branch, commit changes, and submit a pull request.

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
  - Use `mcp__github__github-request-pr-review` to request review from relevant team reviewers. Check for repos ".github/CODEOWNERS" file
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
5. Push branch if needed: mcp__github__github-push-branch with owner, repo, branch, sha
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
```]],
            },
          },
        },
      },
      interactions = {
        chat = { adapter = { name = "claude_code" } },
        inline = { adapter = "anthropic_fast" },
        cmd = { adapter = "anthropic" },
      },
      adapters = {
        acp = {
          claude_code = function()
            return require("codecompanion.adapters").extend("claude_code", {
              env = {
                -- ANTHROPIC_API_KEY = "cmd:op read op://Private/Anthropic/credential --no-newline",
                CLAUDE_CODE_OAUTH_TOKEN = "cmd:op read op://Private/Claude_Code_OAuth/credential --no-newline",
              },
              defaults = {
                model = "opus",
              },
            })
          end,
        },
        http = {
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                api_key = "cmd:op read op://Private/Anthropic/credential --no-newline",
              },
              schema = {
                model = {
                  default = "claude-sonnet-4-6",
                },
                extended_thinking = {
                  default = true,
                },
              },
            })
          end,
          anthropic_fast = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                api_key = "cmd:op read op://Private/Anthropic/credential --no-newline",
              },
              schema = {
                model = {
                  default = "claude-haiku-4-5",
                },
                extended_thinking = {
                  default = false,
                },
              },
            })
          end,
        },
      },
    }

    -- Helper function for cleaner keymap definitions
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
    end

    -- Keymaps
    map({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", "CodeCompanion Actions")
    map({ "n", "v" }, "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>", "CodeCompanion Toggle")
    map("v", "<leader>ae", "<cmd>CodeCompanionChat Add<cr>", "CodeCompanion Add to Chat")
  end,
}
