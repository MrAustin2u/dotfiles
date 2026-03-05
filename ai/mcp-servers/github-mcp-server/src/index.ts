#!/usr/bin/env node

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { Octokit } from "@octokit/rest";
import { config } from "dotenv";
import { getEnv } from "./utils.js";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

// Load environment variables from .env file in the project root
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
config({ path: join(__dirname, "../.env") });

const GITHUB_TOKEN = getEnv("GITHUB_TOKEN");
const GITHUB_OWNER = getEnv("GITHUB_OWNER", false);

const octokit = new Octokit({ auth: GITHUB_TOKEN });

const server = new McpServer({
  name: "github-mcp-server",
  version: "1.0.0",
});

server.registerTool(
  "github-list-repos",
  {
    description: "List repositories for a GitHub user or organization",
    inputSchema: {
      owner: z
        .string()
        .optional()
        .describe(
          "GitHub username or organization name (optional, uses default if not provided)",
        ),
      type: z
        .enum(["all", "owner", "public", "private", "member"])
        .optional()
        .default("all")
        .describe("Type of repositories to list"),
      sort: z
        .enum(["created", "updated", "pushed", "full_name"])
        .optional()
        .default("updated")
        .describe("Sort repositories by"),
      per_page: z
        .number()
        .optional()
        .default(30)
        .describe("Number of results per page (max 100)"),
    },
  },
  async ({ owner, type, sort, per_page }) => {
    const username = owner || GITHUB_OWNER;
    const { data } = await octokit.repos.listForUser({
      username,
      type: type as any,
      sort: sort as any,
      per_page,
    });

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  },
);

server.registerTool(
  "github-list-prs",
  {
    description: "List pull requests for a repository",
    inputSchema: {
      owner: z.string().describe("Repository owner"),
      repo: z.string().describe("Repository name"),
      state: z
        .enum(["open", "closed", "all"])
        .optional()
        .default("open")
        .describe("Pull request state"),
      per_page: z
        .number()
        .optional()
        .default(30)
        .describe("Number of results per page (max 100)"),
    },
  },
  async ({ owner, repo, state, per_page }) => {
    const { data } = await octokit.pulls.list({
      owner,
      repo,
      state: state as any,
      per_page,
    });

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  },
);

server.registerTool(
  "github-get-pr",
  {
    description: "Get detailed information about a specific pull request",
    inputSchema: {
      owner: z.string().describe("Repository owner"),
      repo: z.string().describe("Repository name"),
      pull_number: z.number().describe("Pull request number"),
    },
  },
  async ({ owner, repo, pull_number }) => {
    const { data } = await octokit.pulls.get({
      owner,
      repo,
      pull_number,
    });

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  },
);

server.registerTool(
  "github-get-pr-files",
  {
    description: "Get the list of files changed in a pull request",
    inputSchema: {
      owner: z.string().describe("Repository owner"),
      repo: z.string().describe("Repository name"),
      pull_number: z.number().describe("Pull request number"),
    },
  },
  async ({ owner, repo, pull_number }) => {
    const { data } = await octokit.pulls.listFiles({
      owner,
      repo,
      pull_number,
    });

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  },
);

server.registerTool(
  "github-get-pr-reviews",
  {
    description: "Get reviews for a pull request",
    inputSchema: {
      owner: z.string().describe("Repository owner"),
      repo: z.string().describe("Repository name"),
      pull_number: z.number().describe("Pull request number"),
    },
  },
  async ({ owner, repo, pull_number }) => {
    const { data } = await octokit.pulls.listReviews({
      owner,
      repo,
      pull_number,
    });

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  },
);

server.registerTool(
  "github-get-pr-comments",
  {
    description: "Get comments on a pull request",
    inputSchema: {
      owner: z.string().describe("Repository owner"),
      repo: z.string().describe("Repository name"),
      pull_number: z.number().describe("Pull request number"),
    },
  },
  async ({ owner, repo, pull_number }) => {
    // Get both review comments and issue comments
    const [reviewComments, issueComments] = await Promise.all([
      octokit.pulls.listReviewComments({
        owner,
        repo,
        pull_number,
      }),
      octokit.issues.listComments({
        owner,
        repo,
        issue_number: pull_number,
      }),
    ]);

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(
            {
              reviewComments: reviewComments.data,
              issueComments: issueComments.data,
            },
            null,
            2,
          ),
        },
      ],
    };
  },
);

server.registerTool(
  "github-get-pr-commits",
  {
    description: "Get commits in a pull request",
    inputSchema: {
      owner: z.string().describe("Repository owner"),
      repo: z.string().describe("Repository name"),
      pull_number: z.number().describe("Pull request number"),
    },
  },
  async ({ owner, repo, pull_number }) => {
    const { data } = await octokit.pulls.listCommits({
      owner,
      repo,
      pull_number,
    });

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  },
);

server.registerTool(
  "github-create-pr",
  {
    description: "Create a new pull request",
    inputSchema: {
      owner: z.string().describe("Repository owner"),
      repo: z.string().describe("Repository name"),
      title: z.string().describe("Pull request title"),
      body: z.string().optional().describe("Pull request description"),
      head: z
        .string()
        .describe("The name of the branch where your changes are implemented"),
      base: z
        .string()
        .describe("The name of the branch you want the changes pulled into"),
      draft: z
        .boolean()
        .optional()
        .default(false)
        .describe("Create as draft PR"),
    },
  },
  async ({ owner, repo, title, body, head, base, draft }) => {
    const { data } = await octokit.pulls.create({
      owner,
      repo,
      title,
      body,
      head,
      base,
      draft,
    });

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  },
);

server.registerTool(
  "github-update-pr",
  {
    description:
      "Update an existing pull request (title, body, base branch, or state)",
    inputSchema: {
      owner: z.string().describe("Repository owner"),
      repo: z.string().describe("Repository name"),
      pull_number: z.number().describe("Pull request number"),
      title: z.string().optional().describe("New pull request title"),
      body: z.string().optional().describe("New pull request description"),
      base: z.string().optional().describe("New base branch name"),
      state: z
        .enum(["open", "closed"])
        .optional()
        .describe("State of the pull request (open or closed)"),
    },
  },
  async ({ owner, repo, pull_number, title, body, base, state }) => {
    const updateParams: {
      owner: string;
      repo: string;
      pull_number: number;
      title?: string;
      body?: string;
      base?: string;
      state?: "open" | "closed";
    } = {
      owner,
      repo,
      pull_number,
    };

    if (title !== undefined) updateParams.title = title;
    if (body !== undefined) updateParams.body = body;
    if (base !== undefined) updateParams.base = base;
    if (state !== undefined) updateParams.state = state;

    const { data } = await octokit.pulls.update(updateParams);

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  },
);

server.registerTool(
  "github-get-push-branch",
  {
    description:
      "Get the current branch that can be pushed (typically for creating PRs)",
    inputSchema: {
      owner: z.string().describe("Repository owner"),
      repo: z.string().describe("Repository name"),
      branch: z.string().describe("Branch name to check"),
    },
  },
  async ({ owner, repo, branch }) => {
    try {
      const { data } = await octokit.repos.getBranch({
        owner,
        repo,
        branch,
      });

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(data, null, 2),
          },
        ],
      };
    } catch (error: any) {
      if (error.status === 404) {
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                {
                  exists: false,
                  branch,
                  message: "Branch not found - it can be pushed",
                },
                null,
                2,
              ),
            },
          ],
        };
      }
      throw error;
    }
  },
);

server.registerTool(
  "github-request-pr-review",
  {
    description: "Request reviewers for a pull request",
    inputSchema: {
      owner: z.string().describe("Repository owner"),
      repo: z.string().describe("Repository name"),
      pull_number: z.number().describe("Pull request number"),
      team_reviewers: z
        .array(z.string())
        .describe("An array of team slugs that will be requested."),
    },
  },
  async ({ owner, repo, pull_number, team_reviewers }) => {
    try {
      const { data } = await octokit.pulls.requestReviewers({
        owner,
        repo,
        pull_number,
        team_reviewers,
      });

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(data, null, 2),
          },
        ],
      };
    } catch (error: any) {
      if (error.status === 404) {
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(
                {
                  success: false,
                  pull_number,
                  message: `Pull request #${pull_number} not found`,
                },
                null,
                2,
              ),
            },
          ],
        };
      }
      throw error;
    }
  },
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("GitHub MCP Server running on stdio");
}

main().catch((error) => {
  console.error("Fatal error in main():", error);
  process.exit(1);
});
