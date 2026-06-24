#!/usr/bin/env node

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import fetch from "node-fetch";
import { config } from "dotenv";
import { getEnv } from "./utils.js";
import { fileURLToPath } from "url";
import { dirname, join, basename } from "path";
import { readFile } from "fs/promises";

// Load environment variables from .env file in the project root
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
config({ path: join(__dirname, "../.env") });

const JIRA_BASE_URL = getEnv("JIRA_BASE_URL");
const JIRA_EMAIL = getEnv("JIRA_EMAIL");
const JIRA_API_TOKEN = getEnv("JIRA_API_TOKEN");

const authHeader = `Basic ${Buffer.from(`${JIRA_EMAIL}:${JIRA_API_TOKEN}`).toString("base64")}`;

async function jiraRequest(endpoint: string, method = "GET", body?: any) {
  const url = `${JIRA_BASE_URL}/rest/api/3${endpoint}`;
  const options: any = {
    method,
    headers: {
      Authorization: authHeader,
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

const server = new McpServer({
  name: "jira-mcp-server",
  version: "1.0.0",
});

server.registerTool(
  "jira_read_ticket",
  {
    description:
      "Read detailed information about a Jira ticket including description, acceptance criteria, comments, and attachments",
    inputSchema: {
      issueKey: z.string().describe("Jira issue key (e.g., 'PROJECT-123')"),
    },
  },
  async ({ issueKey }) => {
    // Fetch issue with expanded fields
    const fieldsParam =
      "summary,description,labels,components,attachment,comment,customfield_10111";
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

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(ticketData, null, 2),
        },
      ],
    };
  },
);

server.registerTool(
  "jira_search_tickets",
  {
    description: "Search for Jira tickets using JQL (Jira Query Language)",
    inputSchema: {
      jql: z
        .string()
        .describe(
          "JQL query string (e.g., 'project = PROJECT AND status = Open')",
        ),
      maxResults: z
        .number()
        .optional()
        .default(50)
        .describe("Maximum number of results to return"),
      fields: z
        .array(z.string())
        .optional()
        .describe("Fields to include in the response (optional)"),
    },
  },
  async ({ jql, maxResults, fields }) => {
    const params = new URLSearchParams({
      jql,
      maxResults: (maxResults || 50).toString(),
    });

    const requestedFields =
      fields && fields.length > 0
        ? fields.join(",")
        : "summary,status,assignee,priority,issuetype,created,updated";
    params.append("fields", requestedFields);

    const data = await jiraRequest(`/search/jql?${params.toString()}`);

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
  "jira_list_projects",
  {
    description: "List all Jira projects accessible to the user",
    inputSchema: {
      maxResults: z
        .number()
        .optional()
        .default(50)
        .describe("Maximum number of results"),
    },
  },
  async ({ maxResults }) => {
    const data = await jiraRequest(`/project?maxResults=${maxResults || 50}`);

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
  "jira_add_attachment",
  {
    description:
      "Upload a local file as an attachment to a Jira issue (e.g. a PDF deck or screenshot). Provide the absolute path to a file on disk.",
    inputSchema: {
      issueKey: z.string().describe("Jira issue key (e.g., 'PROJECT-123')"),
      filePath: z
        .string()
        .describe("Absolute path to the local file to upload as an attachment"),
      filename: z
        .string()
        .optional()
        .describe(
          "Optional override for the attached filename (defaults to the file's basename)",
        ),
    },
  },
  async ({ issueKey, filePath, filename }) => {
    const data = await readFile(filePath);
    const name = filename || basename(filePath);

    // Jira attachments require a multipart/form-data upload with the
    // X-Atlassian-Token: no-check header, and live under /rest/api/3 directly
    // (not the JSON jiraRequest helper). Use the global fetch/FormData/Blob
    // (undici) so the multipart body is serialized correctly.
    const form = new FormData();
    form.append("file", new Blob([new Uint8Array(data)]), name);

    const url = `${JIRA_BASE_URL}/rest/api/3/issue/${encodeURIComponent(
      issueKey,
    )}/attachments`;

    const response = await globalThis.fetch(url, {
      method: "POST",
      headers: {
        Authorization: authHeader,
        Accept: "application/json",
        "X-Atlassian-Token": "no-check",
      },
      body: form,
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Jira API error (${response.status}): ${errorText}`);
    }

    const result = (await response.json()) as any[];
    const attached = (Array.isArray(result) ? result : []).map((a: any) => ({
      id: a.id,
      filename: a.filename,
      size: a.size,
      mimeType: a.mimeType,
      url: a.content,
    }));

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify({ issueKey, attached }, null, 2),
        },
      ],
    };
  },
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Jira MCP Server running on stdio");
}

main().catch((error) => {
  console.error("Fatal error in main():", error);
  process.exit(1);
});
