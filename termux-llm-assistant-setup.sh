#!/usr/bin/env bash

# FIXME: it works in zsh
# It does not work in bash
# When I loging as bash and run claude --version, I get the following error:
#
# bash: /data/data/com.termux/files/usr/bin/claude: /usr/bin/env: bad interpreter: No such file or directory
set -efuo pipefail

npm install -g @openai/codex
npm install -g @anthropic-ai/claude-code

echo "Setting up MCP servers..."

claude mcp add --scope user -- context7 npx -y @upstash/context7-mcp@latest 2>/dev/null || true ;

claude mcp add --scope user -- tavily-mcp npx -y tavily-mcp@0.1.3 2>/dev/null || true ;
claude mcp add --scope user -- sequential-thinking npx -y @modelcontextprotocol/server-sequential-thinking 2>/dev/null || true ;
claude mcp add --scope user -- perplexity-ask npx -y server-perplexity-ask 2>/dev/null || true ;
claude mcp add --scope user -- exa npx -y exa-mcp-server --tools=web_search_exa,github_search,crawling 2>/dev/null || true ;
claude mcp add --scope user -- firecrawl npx -y firecrawl-mcp 2>/dev/null || true ;
claude mcp add --scope user -- gitlab-mcp-doc uvx --from mcpdoc mcpdoc \
  --urls \
  GitLabAdmin:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/administration.txt \
  GitLabAPI:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/api.txt \
  GitLabArchitecture:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/architecture.txt \
  GitLabCI:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/ci.txt \
  GitLabCloudSeed:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/cloud_seed.txt \
  GitLabDowngrade:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/downgrade_ee_to_ce.txt \
  GitLabDrawers:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/drawers.txt \
  GitLabEditorExtensions:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/editor_extensions.txt \
  GitLabInstall:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/install.txt \
  GitLabIntegration:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/integration.txt \
  GitLabOperations:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/operations.txt \
  GitLabPolicy:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/policy.txt \
  GitLabRaketasks:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/raketasks.txt \
  GitLabSecurity:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/security.txt \
  GitLabSolutions:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/solutions.txt \
  GitLabSubscriptions:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/subscriptions.txt \
  GitLabTopics:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/topics.txt \
  GitLabTutorials:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/tutorials.txt \
  GitLabUpdate:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/update.txt \
  GitLabUser:https://raw.githubusercontent.com/da-moon/llms.txt/refs/heads/master/gitlab/user.txt \
  --allowed-domains '*' \
  --transport stdio 2>/dev/null || true ;
