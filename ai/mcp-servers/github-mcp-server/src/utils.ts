import { execSync } from "child_process";

/**
 * Process an environment variable value. If the value starts with "cmd:",
 * execute the command and return the output. Otherwise, return the value as-is.
 *
 * @param value - The environment variable value to process
 * @returns The processed value (either the original value or command output)
 * @throws Error if command execution fails
 */
export function processEnvValue(value: string | undefined): string {
  if (!value) {
    return "";
  }

  // Check if the value starts with "cmd:"
  if (value.startsWith("cmd:")) {
    const command = value.slice(4).trim();
    
    if (!command) {
      throw new Error("Empty command after 'cmd:' prefix");
    }

    try {
      // Execute the command and capture stdout
      const output = execSync(command, {
        encoding: "utf8",
        stdio: ["pipe", "pipe", "pipe"],
      });
      
      // Return trimmed output (remove trailing newlines)
      return output.trim();
    } catch (error: any) {
      throw new Error(
        `Failed to execute command "${command}": ${error.message}`
      );
    }
  }

  // Return the value as-is if it doesn't start with "cmd:"
  return value;
}

/**
 * Get the git remote URL for the current repository
 * 
 * @param remote - The remote name (default: "origin")
 * @returns The git remote URL or empty string if not found
 */
export function getGitRemoteUrl(remote = "origin"): string {
  try {
    const url = execSync(`git config --get remote.${remote}.url`, {
      encoding: "utf8",
      stdio: ["pipe", "pipe", "pipe"],
    });
    return url.trim();
  } catch {
    return "";
  }
}

/**
 * Parse a GitHub repository URL and extract owner and repo name
 * 
 * @param url - The git URL (SSH or HTTPS format)
 * @returns Object with owner and repo, or null if parsing fails
 */
export function parseRepoUrl(url: string): { owner: string; repo: string } | null {
  if (!url) {
    return null;
  }

  // Normalize common SSH form: git@github.com:owner/repo(.git)
  let normalized = url.trim();
  if (/^git@github\.com:/i.test(normalized)) {
    normalized = normalized.replace(/^git@github\.com:/i, "github.com/");
  }

  const m = normalized.match(/github\.com\/([^/]+)\/([^/]+)(?:\.git)?\/?$/i);
  if (!m) {
    return null;
  }

  let repoName = m[2];
  // Remove .git suffix if present
  if (repoName.endsWith(".git")) {
    repoName = repoName.slice(0, -4);
  }

  return { owner: m[1], repo: repoName };
}

/**
 * Get the GitHub owner from the current git repository URL
 * 
 * @param remote - The remote name (default: "origin")
 * @returns The GitHub owner/organization name or empty string if not found
 */
export function getGitHubOwnerFromRepo(remote = "origin"): string {
  const url = getGitRemoteUrl(remote);
  if (!url) {
    return "";
  }

  const parsed = parseRepoUrl(url);
  return parsed?.owner || "";
}

/**
 * Process environment variable and validate it's not empty
 * 
 * @param key - The environment variable key
 * @param required - Whether the environment variable is required
 * @returns The processed environment variable value
 * @throws Error if required variable is missing or command execution fails
 */
export function getEnv(key: string, required = true): string {
  const rawValue = process.env[key];
  
  if (!rawValue) {
    if (required) {
      throw new Error(`${key} environment variable is required`);
    }
    return "";
  }

  return processEnvValue(rawValue);
}
