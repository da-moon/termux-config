# MCP Servers for Claude Code
# Each server is in its own directory in github:da-moon/flakes
{ system }:

let
  # Helper to import an MCP server flake from GitHub
  mcpFlake = name: builtins.getFlake "github:da-moon/flakes?dir=${name}-mcp-server";

  # Import all MCP server flakes
  context7 = mcpFlake "context7";
  firecrawl = mcpFlake "firecrawl";
in
[
  context7.packages.${system}.default
  firecrawl.packages.${system}.default
]
