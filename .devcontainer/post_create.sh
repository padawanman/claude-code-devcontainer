#!/bin/bash
set -euo pipefail

echo "=== post_create.sh: セットアップ開始 ==="

CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-/home/node/.claude}"
mkdir -p "$CLAUDE_CONFIG_DIR"

# -------------------------------------------------------
# 1. Playwright Chromium のインストール
# -------------------------------------------------------
echo "--- Playwright Chromium をインストール中 ---"
npx --yes playwright install chromium

# -------------------------------------------------------
# 2. Playwright MCP の設定
# -------------------------------------------------------
echo "--- Playwright MCP を設定中 ---"
MCP_CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude.json"

if [ ! -f "$MCP_CONFIG_FILE" ]; then
    cat > "$MCP_CONFIG_FILE" << 'EOF'
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--browser", "chromium",
        "--no-sandbox",
        "--isolated"
      ]
    }
  }
}
EOF
    echo "MCP 設定を作成しました: $MCP_CONFIG_FILE"
else
    echo "MCP 設定ファイルがすでに存在するためスキップします"
fi

# -------------------------------------------------------
# 3. Everything Claude Code のインストール
#    ※ postCreateCommand はファイアウォール起動前に実行されるため
#      GitHub へのアクセスが可能
# -------------------------------------------------------
echo "--- Everything Claude Code をインストール中 ---"
ECC_TMP="/tmp/everything-claude-code"

if [ -d "$ECC_TMP" ]; then
    rm -rf "$ECC_TMP"
fi

git clone --depth 1 https://github.com/affaan-m/everything-claude-code.git "$ECC_TMP"

# ~/.claude/ 配下の各ディレクトリにコピー（既存ファイルは上書き）
for dir in agents rules commands skills; do
    if [ -d "$ECC_TMP/$dir" ]; then
        mkdir -p "$CLAUDE_CONFIG_DIR/$dir"
        cp -r "$ECC_TMP/$dir/." "$CLAUDE_CONFIG_DIR/$dir/"
        echo "  コピー完了: $dir/"
    fi
done

# フック設定のコピー
if [ -f "$ECC_TMP/hooks/hooks.json" ]; then
    mkdir -p "$CLAUDE_CONFIG_DIR/hooks"
    cp "$ECC_TMP/hooks/hooks.json" "$CLAUDE_CONFIG_DIR/hooks/hooks.json"
    echo "  コピー完了: hooks/hooks.json"
fi

# フックスクリプトのコピー
if [ -d "$ECC_TMP/scripts" ]; then
    mkdir -p "$CLAUDE_CONFIG_DIR/scripts"
    cp -r "$ECC_TMP/scripts/." "$CLAUDE_CONFIG_DIR/scripts/"
    echo "  コピー完了: scripts/"
fi

rm -rf "$ECC_TMP"
echo "Everything Claude Code のインストール完了"

# -------------------------------------------------------
# 4. Claude Code の設定ファイルをコピー
#    （ワークスペースの .claude/settings.json が優先）
# -------------------------------------------------------
if [ -f "/workspace/.claude/settings.json" ] && [ ! -f "$CLAUDE_CONFIG_DIR/settings.json" ]; then
    cp /workspace/.claude/settings.json "$CLAUDE_CONFIG_DIR/settings.json"
    echo "settings.json を Claude 設定ディレクトリにコピーしました"
fi

# -------------------------------------------------------
# 完了メッセージ
# -------------------------------------------------------
# -------------------------------------------------------
# 5. zsh エイリアスの登録
# -------------------------------------------------------
echo "--- zsh エイリアスを登録中 ---"
cat >> /home/node/.zshrc << 'EOF'

# Claude Code エイリアス
alias cc='claude'
alias ccp='claude --dangerously-skip-permissions'
alias ccr='claude --resume'
EOF
echo "zsh エイリアスを登録しました"

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "使い方:"
echo "  1. APIキーを設定: export ANTHROPIC_API_KEY=sk-ant-..."
echo "  2. Claude Code を起動: claude"
echo "  3. 自律モード（このコンテナ内では安全）: claude --dangerously-skip-permissions"
echo ""
echo "インストール済み:"
echo "  - Playwright Chromium (MCP 経由でブラウザ操作可能)"
echo "  - Everything Claude Code (スキル・コマンド・エージェント・フック)"
