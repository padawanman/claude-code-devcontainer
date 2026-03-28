# Claude Code Devcontainer

Claude Code 開発に最適化された Dev Container の設定集です。

Anthropic 公式の安全なサンドボックス環境に、Playwright MCP と [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) を組み合わせた、実践的な Claude Code 開発環境です。

---

## 含まれるもの

| コンポーネント | 内容 |
|---|---|
| **Anthropic 公式 Dev Container** | Node.js 20 ベース、iptables ファイアウォール付き安全なサンドボックス |
| **Playwright MCP** | Claude がヘッドレス Chromium を操作できるブラウザ自動化 |
| **Everything Claude Code** | 102以上のスキル・52以上のコマンド・28エージェント・フック |
| **Python 3** | pip / venv 付き |
| **開発ツール** | zsh / fzf / git-delta / jq / GitHub CLI |

---

## なぜ Dev Container を使うのか

| 観点 | Dev Container | Ubuntu 直接 |
|---|---|---|
| セキュリティ | Claude のアクセスがワークスペース内に隔離される | ホスト全体へアクセス可能 |
| `--dangerously-skip-permissions` | 安全に使える（Anthropic 公式推奨） | ホスト全体が対象になるため危険 |
| ネットワーク | API/GitHub/npm 以外をブロック | 外部通信の制限なし |
| 再現性 | 誰でも同じ環境を一発で再現 | ホストの状態に依存 |

---

## 必要なもの

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) または Docker Engine
- [VS Code](https://code.visualstudio.com/)
- VS Code 拡張機能: [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- Anthropic の API キー（[取得はこちら](https://console.anthropic.com/)）

---

## セットアップ手順

### 1. リポジトリをクローン

```bash
git clone https://github.com/padawanman/claude-code-devcontainer.git
cd claude-code-devcontainer
```

### 2. VS Code でコンテナを開く

VS Code でフォルダを開き、左下の `><` アイコンをクリックして
**「コンテナーで再度開く (Reopen in Container)」** を選択します。

初回ビルドでは以下が自動実行されます（5〜10分程度）：
- Docker イメージのビルド（Node.js 20 + Python 3 + 開発ツール）
- Playwright Chromium のインストール
- Everything Claude Code のインストール

### 3. API キーを設定

コンテナ内のターミナルで：

```bash
export ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxx
```

毎回入力するのが面倒な場合は、`~/.zshrc` に追記するか、
VS Code の `devcontainer.json` の `containerEnv` に設定してください。

### 4. Claude Code を起動

```bash
# 通常モード（都度確認あり）
claude

# 自律モード / YOLO モード（このコンテナ内では安全）
claude --dangerously-skip-permissions
```

---

## ファイル構成

```
.
├── .devcontainer/
│   ├── devcontainer.json   # Dev Container の設定（VS Code 拡張・ボリューム・環境変数等）
│   ├── Dockerfile          # コンテナイメージの定義
│   ├── init-firewall.sh    # iptables ファイアウォール（コンテナ起動のたびに実行）
│   └── post_create.sh      # 初回作成時のセットアップ（Playwright + ECC インストール）
├── .claude/
│   └── settings.json       # Claude Code の設定（モデル・トークン等）
├── scripts/
│   └── setup-ecc.sh        # Everything Claude Code の手動アップデート用
├── CLAUDE.md               # Claude Code へのガイダンス
└── README.md               # このファイル
```

---

## ファイアウォール

コンテナ起動のたびに `init-firewall.sh` が実行され、以下以外の外部通信をブロックします：

| 許可先 | 用途 |
|---|---|
| `api.anthropic.com` | Claude API |
| GitHub IP レンジ | リポジトリ操作・GitHub CLI |
| `registry.npmjs.org` | npm パッケージ |
| `pypi.org` / `files.pythonhosted.org` | Python パッケージ |
| VS Code マーケットプレイス | 拡張機能 |

これにより `--dangerously-skip-permissions`（Claude が確認なしで操作する自律モード）を安全に使用できます。

### ファイアウォールに追加ドメインを許可する方法

`.devcontainer/init-firewall.sh` の `for domain in ...` に追加：

```bash
for domain in \
    "api.anthropic.com" \
    "registry.npmjs.org" \
    "追加したいドメイン.example.com" \  # ← ここに追加
    ...
```

変更後はコンテナを再起動（または `sudo /usr/local/bin/init-firewall.sh`）してください。

---

## Everything Claude Code

コンテナ作成時に自動インストールされる設定集（113k スター）です。

### インストール済みの内容

| 種類 | 数 | 説明 |
|---|---|---|
| エージェント | 28 | プランナー・セキュリティレビュアー・TDD ガイド等 |
| スキル | 102以上 | TDD・Next.js・セキュリティ・API 設計等 |
| コマンド | 52以上 | `/tdd`・`/plan`・`/code-review`・`/e2e` 等 |
| ルール | 34 | TypeScript・Python・Go・Rust 等の言語別ガイドライン |
| フック | 8種類 | 自動フォーマット・型チェック・コスト計測等 |

### 主要コマンド

```
/tdd           テスト駆動開発ワークフロー
/plan          実装計画の立案
/code-review   コードレビュー
/e2e           E2E テスト実行
/security      セキュリティ監査
```

### ECC を最新版にアップデートする

```bash
bash scripts/setup-ecc.sh
```

---

## Playwright MCP の使い方

Claude がブラウザを操作できます。たとえば：

```
「http://localhost:3000 のスクリーンショットを撮って」
「このフォームに入力してボタンをクリックして」
「ページの DOM 構造を確認して」
```

MCP 設定は `~/.claude/claude.json` に保存されています。

---

## Claude Code の設定（settings.json）

`.claude/settings.json` でモデルとトークン設定を管理しています：

```json
{
  "model": "sonnet",
  "env": {
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
  }
}
```

- `model: "sonnet"` — Opus より低コストで高速（ECC 推奨設定）
- `MAX_THINKING_TOKENS: "10000"` — 思考トークンのコストを約70%削減
- `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE: "50"` — コンテキスト50%で自動圧縮

---

## 参考リンク

- [Anthropic 公式 Dev Container](https://github.com/anthropics/claude-code/tree/main/.devcontainer)
- [Anthropic Dev Container ドキュメント](https://docs.anthropic.com/ja/docs/claude-code/devcontainer)
- [Everything Claude Code](https://github.com/affaan-m/everything-claude-code)
- [Playwright MCP](https://github.com/microsoft/playwright-mcp)
- [Claude Code ドキュメント](https://docs.anthropic.com/ja/docs/claude-code)

---

## ライセンス

MIT
