# Jira MCP Server

A Model Context Protocol (MCP) server that provides integration with Jira Cloud, allowing AI assistants to read tickets, search issues, and list projects.

## Features

- **Read Jira Tickets**: Fetch detailed information about specific Jira issues including description, acceptance criteria, comments, and attachments
- **Search Tickets**: Query Jira using JQL (Jira Query Language) to find relevant issues
- **List Projects**: Retrieve all Jira projects accessible to the user
- **ADF Rendering**: Converts Atlassian Document Format (ADF) to plain text for better readability

## Installation

```bash
pnpm install
pnpm build
```

## Configuration

The server requires the following environment variables:

- `JIRA_BASE_URL`: Your Jira instance URL (e.g., `https://your-domain.atlassian.net`)
- `JIRA_EMAIL`: Your Jira account email
- `JIRA_API_TOKEN`: Your Jira API token ([create one here](https://id.atlassian.com/manage-profile/security/api-tokens))

### Dynamic Environment Variables

This server supports a special `cmd:` prefix for environment variables, which allows you to execute shell commands to retrieve secrets dynamically:

```bash
export JIRA_API_TOKEN="cmd:security find-generic-password -a jira -s api-token -w"
```

### MCP Settings Configuration

Add the server to your Claude Code configuration (`~/.claude/settings.json`):

```json
{
  "mcpServers": {
    "jira": {
      "command": "node",
      "args": [
        "/Users/aaustin/dotfiles/ai/mcp-servers/jira-mcp-server/build/index.js"
      ],
      "env": {
        "JIRA_BASE_URL": "https://your-domain.atlassian.net",
        "JIRA_EMAIL": "your-email@example.com",
        "JIRA_API_TOKEN": "cmd:security find-generic-password -a jira -s api-token -w"
      }
    }
  }
}
```

## Available Tools

### jira_read_ticket

Read detailed information about a Jira ticket.

**Parameters:**
- `issueKey` (string): Jira issue key (e.g., "PROJECT-123")

**Returns:**
- Key, title, description, acceptance criteria
- Labels, components, status, assignee, reporter, priority
- Recent comments (up to 10)
- Image attachments with URLs

**Example:**
```typescript
{
  "issueKey": "PROJ-123"
}
```

### jira_search_tickets

Search for Jira tickets using JQL.

**Parameters:**
- `jql` (string): JQL query string (e.g., "project = PROJ AND status = Open")
- `maxResults` (number, optional): Maximum number of results (default: 50)
- `fields` (array of strings, optional): Fields to include in the response

**Example:**
```typescript
{
  "jql": "project = PROJ AND assignee = currentUser() AND status != Done",
  "maxResults": 20
}
```

### jira_list_projects

List all Jira projects accessible to the user.

**Parameters:**
- `maxResults` (number, optional): Maximum number of results (default: 50)

**Example:**
```typescript
{
  "maxResults": 50
}
```

## CLI Usage

To use the MCP server as a command-line tool:

```bash
# Build and link globally
pnpm build
pnpm link --global

# Set environment variables
export JIRA_BASE_URL="https://your-domain.atlassian.net"
export JIRA_EMAIL="your-email@example.com"
export JIRA_API_TOKEN="your-api-token"

# Run the CLI
jira-mcp-cli
```

The CLI will communicate over stdio and accept MCP protocol messages.

## Development

```bash
# Build the project
pnpm build

# Watch mode for development
pnpm watch
```

## Technical Details

- Built with TypeScript
- Uses the [@modelcontextprotocol/sdk](https://github.com/modelcontextprotocol/sdk) for MCP implementation
- Communicates via stdio transport
- Supports Jira Cloud REST API v3
- Custom field mapping for acceptance criteria (customfield_10111)

## License

Private use only.
