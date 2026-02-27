return {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  build = "npm install -g mcp-hub@latest",
  cmd = "MCPHub",
  keys = {
    { "<leader>cm", "<cmd>MCPHub<cr>", desc = "MCPHub" },
  },
  config = function()
    require("mcphub").setup {
      mcp_servers = {
        github = {
          command = "node",
          args = {
            "$HOME/ai/mcp-servers/github-mcp-server/build/index.js",
          },
          autoApprove = {
            "github-list-repos",
            "github-list-prs",
            "github-get-pr",
            "github-get-pr-files",
            "github-get-pr-reviews",
            "github-get-pr-comments",
            "github-get-pr-commits",
            "github-create-pr",
            "github-update-pr",
            "github-get-push-branch",
          },
        },
        jira = {
          command = "node",
          args = {
            "$HOME/ai/mcp-servers/jira-mcp-server/build/index.js",
          },
          autoApprove = {
            "jira_read_ticket",
            "jira_search_tickets",
            "jira_list_projects",
          },
        },
      },
      extensions = {
        codecompanion = {
          make_slash_commands = true,
        },
      },
    }
  end,
}
