# MCP Servers for Claude Code
# Each server is in its own subdirectory with a flake.nix
{ gitRepoRoot, configSubdir, system }:

let
  # Helper to import an MCP server flake
  mcpFlake = name: builtins.getFlake "git+file://${gitRepoRoot}?dir=${configSubdir}/mcp-servers/${name}";

  # Import all MCP server flakes
  context7 = mcpFlake "context7";
  firecrawl = mcpFlake "firecrawl";
in
[
  context7.packages.${system}.default
  firecrawl.packages.${system}.default
]
