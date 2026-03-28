#!/bin/bash
# Everything Claude Code の再インストール / アップデートスクリプト
# コンテナ作成時は post_create.sh が自動実行するため通常は不要です。
# 最新版に更新したい場合にこのスクリプトを手動実行してください。
set -euo pipefail

echo "=== Everything Claude Code インストール / アップデート ==="

CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
ECC_TMP="/tmp/everything-claude-code"

echo "インストール先: $CLAUDE_CONFIG_DIR"

# 既存の一時ディレクトリを削除
if [ -d "$ECC_TMP" ]; then
    rm -rf "$ECC_TMP"
fi

echo "GitHub からクローン中..."
git clone --depth 1 https://github.com/affaan-m/everything-claude-code.git "$ECC_TMP"

# 各ディレクトリをコピー（既存ファイルは上書き）
for dir in agents rules commands skills; do
    if [ -d "$ECC_TMP/$dir" ]; then
        mkdir -p "$CLAUDE_CONFIG_DIR/$dir"
        cp -r "$ECC_TMP/$dir/." "$CLAUDE_CONFIG_DIR/$dir/"
        echo "  更新: $dir/"
    fi
done

# フック設定
if [ -f "$ECC_TMP/hooks/hooks.json" ]; then
    mkdir -p "$CLAUDE_CONFIG_DIR/hooks"
    cp "$ECC_TMP/hooks/hooks.json" "$CLAUDE_CONFIG_DIR/hooks/hooks.json"
    echo "  更新: hooks/hooks.json"
fi

# フックスクリプト
if [ -d "$ECC_TMP/scripts" ]; then
    mkdir -p "$CLAUDE_CONFIG_DIR/scripts"
    cp -r "$ECC_TMP/scripts/." "$CLAUDE_CONFIG_DIR/scripts/"
    echo "  更新: scripts/"
fi

rm -rf "$ECC_TMP"

echo ""
echo "=== インストール / アップデート完了 ==="
echo ""
echo "インストールされた内容:"
echo "  agents/   — $(ls "$CLAUDE_CONFIG_DIR/agents/" 2>/dev/null | wc -l) エージェント"
echo "  rules/    — $(ls "$CLAUDE_CONFIG_DIR/rules/" 2>/dev/null | wc -l) ルール"
echo "  commands/ — $(ls "$CLAUDE_CONFIG_DIR/commands/" 2>/dev/null | wc -l) コマンド"
echo "  skills/   — $(ls "$CLAUDE_CONFIG_DIR/skills/" 2>/dev/null | wc -l) スキル"
