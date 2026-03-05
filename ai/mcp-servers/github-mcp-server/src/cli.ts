#!/usr/bin/env node
import { config } from "dotenv";
import { Command } from "commander";
import { Octokit } from "@octokit/rest";
import { getEnv } from "./utils.js";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

// Get the directory of this script
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load environment variables from .env file in the project root
config({ path: join(__dirname, "..", ".env") });

const program = new Command();

program
  .name("github-mcp-cli")
  .description("CLI for GitHub MCP Server")
  .version("1.0.0");

// Initialize Octokit with environment variables
function getOctokit(): Octokit {
  const GITHUB_TOKEN = getEnv("GITHUB_TOKEN");
  return new Octokit({ auth: GITHUB_TOKEN });
}

function getDefaultOwner(): string {
  return getEnv("GITHUB_OWNER", false);
}

// Verify GitHub token command
program
  .command("github-verify")
  .description("Verify GitHub token and display authenticated user information")
  .action(async () => {
    try {
      const token = getEnv("GITHUB_TOKEN");
      const octokit = getOctokit();
      const { data } = await octokit.users.getAuthenticated();

      console.log(
        JSON.stringify(
          {
            success: true,
            token: token,
            user: {
              login: data.login,
              name: data.name,
              email: data.email,
              type: data.type,
              company: data.company,
              location: data.location,
              bio: data.bio,
              public_repos: data.public_repos,
              followers: data.followers,
              following: data.following,
              created_at: data.created_at,
            },
          },
          null,
          2,
        ),
      );
    } catch (error: any) {
      console.error(
        JSON.stringify(
          {
            success: false,
            error: error.message,
            status: error.status,
          },
          null,
          2,
        ),
      );
      process.exit(1);
    }
  });

// List repositories command
program
  .command("github-list-repos")
  .description("List repositories for a GitHub user or organization")
  .option("-o, --owner <owner>", "GitHub username or organization name")
  .option(
    "-t, --type <type>",
    "Type of repositories (all|owner|public|private|member)",
    "all",
  )
  .option(
    "-s, --sort <sort>",
    "Sort by (created|updated|pushed|full_name)",
    "updated",
  )
  .option("-p, --per-page <number>", "Number of results per page", "30")
  .action(async (options) => {
    try {
      const octokit = getOctokit();
      const owner = options.owner || getDefaultOwner();

      if (!owner) {
        console.error(
          "Error: --owner is required or set GITHUB_OWNER environment variable",
        );
        process.exit(1);
      }

      const { data } = await octokit.repos.listForUser({
        username: owner,
        type: options.type as any,
        sort: options.sort as any,
        per_page: parseInt(options.perPage),
      });

      console.log(JSON.stringify(data, null, 2));
    } catch (error: any) {
      console.error("Error:", error.message);
      process.exit(1);
    }
  });

// List pull requests command
program
  .command("github-list-prs")
  .description("List pull requests for a repository")
  .requiredOption("-o, --owner <owner>", "Repository owner")
  .requiredOption("-r, --repo <repo>", "Repository name")
  .option("-s, --state <state>", "Pull request state (open|closed|all)", "open")
  .option("-p, --per-page <number>", "Number of results per page", "30")
  .action(async (options) => {
    try {
      const octokit = getOctokit();
      const { data } = await octokit.pulls.list({
        owner: options.owner,
        repo: options.repo,
        state: options.state as any,
        per_page: parseInt(options.perPage),
      });

      console.log(JSON.stringify(data, null, 2));
    } catch (error: any) {
      console.error("Error:", error.message);
      process.exit(1);
    }
  });

// Get pull request command
program
  .command("github-get-pr")
  .description("Get detailed information about a specific pull request")
  .requiredOption("-o, --owner <owner>", "Repository owner")
  .requiredOption("-r, --repo <repo>", "Repository name")
  .requiredOption("-n, --number <number>", "Pull request number")
  .action(async (options) => {
    try {
      const octokit = getOctokit();
      const { data } = await octokit.pulls.get({
        owner: options.owner,
        repo: options.repo,
        pull_number: parseInt(options.number),
      });

      console.log(JSON.stringify(data, null, 2));
    } catch (error: any) {
      console.error("Error:", error.message);
      process.exit(1);
    }
  });

// Get pull request files command
program
  .command("github-get-pr-files")
  .description("Get the list of files changed in a pull request")
  .requiredOption("-o, --owner <owner>", "Repository owner")
  .requiredOption("-r, --repo <repo>", "Repository name")
  .requiredOption("-n, --number <number>", "Pull request number")
  .action(async (options) => {
    try {
      const octokit = getOctokit();
      const { data } = await octokit.pulls.listFiles({
        owner: options.owner,
        repo: options.repo,
        pull_number: parseInt(options.number),
      });

      console.log(JSON.stringify(data, null, 2));
    } catch (error: any) {
      console.error("Error:", error.message);
      process.exit(1);
    }
  });

// Get pull request reviews command
program
  .command("github-get-pr-reviews")
  .description("Get reviews for a pull request")
  .requiredOption("-o, --owner <owner>", "Repository owner")
  .requiredOption("-r, --repo <repo>", "Repository name")
  .requiredOption("-n, --number <number>", "Pull request number")
  .action(async (options) => {
    try {
      const octokit = getOctokit();
      const { data } = await octokit.pulls.listReviews({
        owner: options.owner,
        repo: options.repo,
        pull_number: parseInt(options.number),
      });

      console.log(JSON.stringify(data, null, 2));
    } catch (error: any) {
      console.error("Error:", error.message);
      process.exit(1);
    }
  });

// Get pull request comments command
program
  .command("github-get-pr-comments")
  .description("Get comments on a pull request")
  .requiredOption("-o, --owner <owner>", "Repository owner")
  .requiredOption("-r, --repo <repo>", "Repository name")
  .requiredOption("-n, --number <number>", "Pull request number")
  .action(async (options) => {
    try {
      const octokit = getOctokit();
      const pullNumber = parseInt(options.number);

      const [reviewComments, issueComments] = await Promise.all([
        octokit.pulls.listReviewComments({
          owner: options.owner,
          repo: options.repo,
          pull_number: pullNumber,
        }),
        octokit.issues.listComments({
          owner: options.owner,
          repo: options.repo,
          issue_number: pullNumber,
        }),
      ]);

      console.log(
        JSON.stringify(
          {
            reviewComments: reviewComments.data,
            issueComments: issueComments.data,
          },
          null,
          2,
        ),
      );
    } catch (error: any) {
      console.error("Error:", error.message);
      process.exit(1);
    }
  });

// Get pull request commits command
program
  .command("github-get-pr-commits")
  .description("Get commits in a pull request")
  .requiredOption("-o, --owner <owner>", "Repository owner")
  .requiredOption("-r, --repo <repo>", "Repository name")
  .requiredOption("-n, --number <number>", "Pull request number")
  .action(async (options) => {
    try {
      const octokit = getOctokit();
      const { data } = await octokit.pulls.listCommits({
        owner: options.owner,
        repo: options.repo,
        pull_number: parseInt(options.number),
      });

      console.log(JSON.stringify(data, null, 2));
    } catch (error: any) {
      console.error("Error:", error.message);
      process.exit(1);
    }
  });

// Create pull request command
program
  .command("github-create-pr")
  .description("Create a new pull request")
  .requiredOption("-o, --owner <owner>", "Repository owner")
  .requiredOption("-r, --repo <repo>", "Repository name")
  .requiredOption("-t, --title <title>", "Pull request title")
  .option("-b, --body <body>", "Pull request description")
  .requiredOption(
    "--head <head>",
    "The name of the branch where your changes are implemented",
  )
  .requiredOption(
    "--base <base>",
    "The name of the branch you want the changes pulled into",
  )
  .option("-d, --draft", "Create as draft PR", false)
  .action(async (options) => {
    try {
      const octokit = getOctokit();
      const { data } = await octokit.pulls.create({
        owner: options.owner,
        repo: options.repo,
        title: options.title,
        body: options.body,
        head: options.head,
        base: options.base,
        draft: options.draft,
      });

      console.log(JSON.stringify(data, null, 2));
    } catch (error: any) {
      console.error("Error:", error.message);
      process.exit(1);
    }
  });

// Get branch command
program
  .command("github-get-branch")
  .description("Get information about a branch")
  .requiredOption("-o, --owner <owner>", "Repository owner")
  .requiredOption("-r, --repo <repo>", "Repository name")
  .requiredOption("-b, --branch <branch>", "Branch name")
  .action(async (options) => {
    try {
      const octokit = getOctokit();
      const { data } = await octokit.repos.getBranch({
        owner: options.owner,
        repo: options.repo,
        branch: options.branch,
      });

      console.log(JSON.stringify(data, null, 2));
    } catch (error: any) {
      if (error.status === 404) {
        console.log(
          JSON.stringify(
            {
              exists: false,
              branch: options.branch,
              message: "Branch not found - it can be pushed",
            },
            null,
            2,
          ),
        );
      } else {
        console.error("Error:", error.message);
        process.exit(1);
      }
    }
  });

// Request PR review command
program
  .command("github-request-pr-review")
  .description("Request reviewers for a pull request")
  .requiredOption("-o, --owner <owner>", "Repository owner")
  .requiredOption("-r, --repo <repo>", "Repository name")
  .requiredOption("-n, --number <number>", "Pull request number")
  .requiredOption(
    "-t, --team-reviewers <teams...>",
    "Team slugs to request review from",
  )
  .action(async (options) => {
    try {
      const octokit = getOctokit();
      const { data } = await octokit.pulls.requestReviewers({
        owner: options.owner,
        repo: options.repo,
        pull_number: parseInt(options.number),
        team_reviewers: options.teamReviewers,
      });

      console.log(JSON.stringify(data, null, 2));
    } catch (error: any) {
      console.error("Error:", error.message);
      process.exit(1);
    }
  });

program.parse();
