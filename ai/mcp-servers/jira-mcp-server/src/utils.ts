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
