#!/usr/bin/env node
import { config } from "dotenv";
import { Command } from "commander";
import fetch from "node-fetch";
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
  .name("jira-mcp-cli")
  .description("CLI for Jira MCP Server")
  .version("1.0.0");

// Initialize Jira credentials
function getJiraConfig() {
  const JIRA_BASE_URL = getEnv("JIRA_BASE_URL");
  const JIRA_EMAIL = getEnv("JIRA_EMAIL");
  const JIRA_API_TOKEN = getEnv("JIRA_API_TOKEN");

  const authHeader = `Basic ${Buffer.from(`${JIRA_EMAIL}:${JIRA_API_TOKEN}`).toString("base64")}`;

  return {
    baseUrl: JIRA_BASE_URL,
    authHeader,
  };
}

async function jiraRequest(endpoint: string, method = "GET", body?: any) {
  const config = getJiraConfig();
  const url = `${config.baseUrl}/rest/api/3${endpoint}`;
  const options: any = {
    method,
    headers: {
      Authorization: config.authHeader,
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  };

  if (body) {
    options.body = JSON.stringify(body);
  }

  const response = await fetch(url, options);

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Jira API error (${response.status}): ${errorText}`);
  }

  return await response.json();
}

function renderAdfToText(adf: any): string {
  if (!adf) {
    return "";
  }
  if (typeof adf === "string") {
    try {
      adf = JSON.parse(adf);
    } catch {
      return "";
    }
  }
  try {
    const parts: string[] = [];
    const walk = (node: any) => {
      if (!node) return;
      if (node.type === "text") {
        parts.push(node.text || "");
      } else if (Array.isArray(node.content)) {
        node.content.forEach(walk);
        if (node.type === "paragraph") {
          parts.push("\n");
        }
      }
    };
    walk(adf);
    return parts
      .join("")
      .replace(/\n{3,}/g, "\n\n")
      .trim();
  } catch {
    return "";
  }
}

// Read ticket command
program
  .command("jira-read-ticket")
  .description(
    "Read detailed information about a Jira ticket including description, acceptance criteria, comments, and attachments",
  )
  .requiredOption("-k, --key <key>", "Jira issue key (e.g., 'PROJECT-123')")
  .action(async (options) => {
    try {
      const issueKey = options.key;

      // Fetch issue with expanded fields
      const fieldsParam =
        "summary,description,labels,components,attachment,comment,customfield_10111,status,assignee,reporter,priority";
      const endpoint = `/issue/${issueKey}?fields=${encodeURIComponent(fieldsParam)}&expand=renderedFields`;
      const issue = (await jiraRequest(endpoint)) as any;

      const fields = issue.fields || {};

      // Get comments
      const commentsRes = (await jiraRequest(
        `/issue/${issueKey}/comment?maxResults=10`,
      )) as any;
      const comments = (commentsRes.comments || [])
        .map((c: any) => renderAdfToText(c.body))
        .filter(Boolean);

      // Process image attachments
      const imageAttachments = (fields.attachment || [])
        .filter((a: any) => a?.mimeType?.startsWith("image/"))
        .map((a: any) => ({
          filename: a.filename,
          mimeType: a.mimeType,
          url: a.content,
          size: a.size,
        }));

      const ticketData = {
        key: issueKey,
        title: fields.summary || "",
        description: renderAdfToText(fields.description),
        acceptanceCriteria: renderAdfToText(fields["customfield_10111"] || ""),
        labels: fields.labels || [],
        components: (fields.components || [])
          .map((c: any) => c.name)
          .filter(Boolean),
        comments,
        imageAttachments,
        status: fields.status?.name || "",
        assignee: fields.assignee?.displayName || "Unassigned",
        reporter: fields.reporter?.displayName || "",
        priority: fields.priority?.name || "",
      };

      console.log(JSON.stringify(ticketData, null, 2));
    } catch (error: any) {
      console.error("Error:", error.message);
      process.exit(1);
    }
  });

// Search tickets command
program
  .command("jira-search-tickets")
  .description("Search for Jira tickets using JQL (Jira Query Language)")
  .requiredOption(
    "-q, --jql <jql>",
    "JQL query string (e.g., 'project = PROJECT AND status = Open')",
  )
  .option(
    "-m, --max-results <number>",
    "Maximum number of results to return",
    "50",
  )
  .option(
    "-f, --fields <fields>",
    "Comma-separated list of fields to include in the response",
  )
  .action(async (options) => {
    try {
      const params = new URLSearchParams({
        jql: options.jql,
        maxResults: options.maxResults,
      });

      if (options.fields) {
        params.append("fields", options.fields);
      }

      const data = await jiraRequest(`/search?${params.toString()}`);

      console.log(JSON.stringify(data, null, 2));
    } catch (error: any) {
      console.error("Error:", error.message);
      process.exit(1);
    }
  });

// List projects command
program
  .command("jira-list-projects")
  .description("List all Jira projects accessible to the user")
  .option(
    "-m, --max-results <number>",
    "Maximum number of results to return",
    "50",
  )
  .action(async (options) => {
    try {
      const data = await jiraRequest(
        `/project?maxResults=${options.maxResults}`,
      );

      console.log(JSON.stringify(data, null, 2));
    } catch (error: any) {
      console.error("Error:", error.message);
      process.exit(1);
    }
  });

// Verify connection command
program
  .command("jira-verify")
  .description("Verify Jira connection and credentials")
  .action(async () => {
    try {
      const config = getJiraConfig();
      console.log(`Connecting to: ${config.baseUrl}`);

      const data = (await jiraRequest("/myself")) as any;

      console.log(
        JSON.stringify(
          {
            status: "success",
            message: "Successfully connected to Jira",
            user: {
              accountId: data.accountId,
              displayName: data.displayName,
              emailAddress: data.emailAddress,
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
            status: "error",
            message: error.message,
          },
          null,
          2,
        ),
      );
      process.exit(1);
    }
  });

program.parse();
