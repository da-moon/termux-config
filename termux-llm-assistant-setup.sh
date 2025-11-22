#!/data/data/com.termux/files/usr/bin/env bash

set -efuo pipefail

# npm install -g @openai/codex
{
  INSTALL_DIR="${INSTALL_DIR:-/data/data/com.termux/files/usr/local/bin}"
  REPO="openai/codex"

  curl -sL "https://api.github.com/repos/${REPO}/releases/latest" \
    | jq -r ".assets[] | select(.name | contains(\"codex-$(uname -m)\") and contains(\"linux-musl\") and endswith(\".tar.gz\") and (contains(\".zst\") | not) ) | .browser_download_url" \
    | xargs curl -sL \
    | tar -xzOf - \
    | tee "${INSTALL_DIR}/codex" >/dev/null \
    && chmod +x "${INSTALL_DIR}/codex" \
    && codex --version >/dev/null 2>&1 || {
    echo "Failed to download codex-cli"
  }
}
# Install goose cli
mkdir -p "/data/data/com.termux/files/usr/tmp/"
curl -fsSL "https://github.com/block/goose/releases/download/stable/download_cli.sh" | sed -e 's|/tmp/|/data/data/com.termux/files/usr/tmp/|g' | bash
# Install Claude Code
npm install -g @anthropic-ai/claude-code
bash -lic "termux-fix-shebang "$(command -v claude)" && hash -r"
echo "Setting up MCP servers..."

claude mcp add --scope user -- context7 npx -y @upstash/context7-mcp@latest 2>/dev/null || true
claude mcp add --scope user -- tavily-mcp npx -y tavily-mcp@latest 2>/dev/null || true
claude mcp add --scope user -- sequential-thinking npx -y @modelcontextprotocol/server-sequential-thinking 2>/dev/null || true
claude mcp add --scope user -- perplexity-ask npx -y server-perplexity-ask 2>/dev/null || true
claude mcp add --scope user -- exa npx -y exa-mcp-server --tools=web_search_exa,github_search,crawling 2>/dev/null || true
claude mcp add --scope user -- firecrawl npx -y firecrawl-mcp 2>/dev/null || true
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
  --transport stdio 2>/dev/null || true
# NOTE: need to manually install npm MCP servers and fix shebang

npm install -g @upstash/context7-mcp@latest
npm install -g tavily-mcp@latest
npm install -g @modelcontextprotocol/server-sequential-thinking
npm install -g server-perplexity-ask
npm install -g exa-mcp-server
npm install -g firecrawl-mcp

PREFIX="$(npm config get prefix)"
find "$PREFIX/lib/node_modules" -type f -executable -exec termux-fix-shebang {} + 2>/dev/null
find "$PREFIX/bin" -type f -executable -exec termux-fix-shebang {} + 2>/dev/null
find "$npx_cache" -type f -name "*.js" -path "*/bin/*" -exec termux-fix-shebang {} + 2>/dev/null
