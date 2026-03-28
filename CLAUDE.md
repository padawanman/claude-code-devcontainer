# CLAUDE.md

このファイルは、Claude Code がこの開発コンテナで作業する際のガイダンスを提供します。

## 環境

- コンテナ: Anthropic 公式 Claude Code Sandbox（Debian / Node.js 20）
- ファイアウォール: 有効 — 外部通信は Anthropic API・GitHub・npm・PyPI のみ許可
- シェル: zsh（Powerlevel10k テーマ）
- 安全モード: このコンテナ内では `--dangerously-skip-permissions` を安全に使用できます

## クイックスタート

```bash
# APIキーを設定（初回のみ）
export ANTHROPIC_API_KEY=sk-ant-...

# Claude Code を起動（対話モード）
claude

# 自律モード（YOLO モード）— このコンテナ内では安全
claude --dangerously-skip-permissions
```

## インストール済みツール

- **Claude Code** — `claude` コマンド
- **Node.js 20** + npm
- **Python 3** + pip + venv
- **GitHub CLI** — `gh` コマンド
- **Playwright**（Chromium）— MCP 経由のブラウザ自動操作
- **git-delta** — 見やすい git diff
- **fzf** — ファジーファインダー
- **jq** — JSON プロセッサ

## MCP サーバー

Playwright MCP が事前設定済みです。Claude はヘッドレス Chromium を操作できます。

MCP サーバーを追加する場合は `~/.claude/claude.json` を編集してください：

```json
{
  "mcpServers": {
    "playwright": { ... },
    "追加したいサーバー": {
      "command": "npx",
      "args": ["mcp-package-name"]
    }
  }
}
```

## Everything Claude Code

コンテナ作成時に自動インストール済みです（`~/.claude/` 配下）。

| ディレクトリ | 内容 |
|---|---|
| `~/.claude/agents/` | 28種の専門サブエージェント（プランナー・セキュリティレビュアー等） |
| `~/.claude/rules/` | 34のコーディングルール（TypeScript・Python・Go等） |
| `~/.claude/commands/` | 52以上のスラッシュコマンド（`/tdd`・`/plan`・`/code-review`等） |
| `~/.claude/skills/` | 102以上のスキル定義 |
| `~/.claude/hooks/hooks.json` | ライフサイクルフック（自動フォーマット・型チェック・コスト計測等） |

主要コマンド例：
- `/tdd` — テスト駆動開発ワークフロー
- `/plan` — 実装計画の立案
- `/code-review` — コードレビュー
- `/e2e` — E2Eテスト実行

## ファイアウォールについて

コンテナは以下以外の外部通信をすべてブロックします：
- `api.anthropic.com` — Claude API
- GitHub の IP レンジ全域
- `registry.npmjs.org` — npm パッケージ
- `pypi.org`, `files.pythonhosted.org` — Python パッケージ
- VS Code マーケットプレイス

追加ドメインを許可したい場合は `.devcontainer/init-firewall.sh` の
`for domain in ...` に追加して、コンテナを再起動してください。
