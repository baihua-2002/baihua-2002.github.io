#!/usr/bin/env bash
# ============================================================
# deploy.sh — 博客一键部署
# 流程：构建站点 → 推送源码到 source 分支 → 发布构建产物到 main 分支（GitHub Pages）
# 用法：./deploy.sh ["自定义提交说明"]
# ============================================================
set -euo pipefail

cd "$(dirname "$0")"
REPO="git@github.com:baihua-2002/baihua-2002.github.io.git"
MSG="${1:-站点更新 $(date '+%Y-%m-%d %H:%M:%S')}"

# 仓库级 git 身份（仅在缺失时设置，不污染全局配置）
git config user.name  >/dev/null 2>&1 || git config user.name  "baihua-2002"
git config user.email >/dev/null 2>&1 || git config user.email "baijun2002@icloud.com"

echo "==> [1/3] 构建站点"
hugo --gc --minify

echo "==> [2/3] 推送源码到 source 分支"
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "$MSG"
  git push origin source
  echo "    source 已更新"
else
  echo "    源码无变化，跳过"
fi

echo "==> [3/3] 发布构建产物到 main 分支"
DEPLOY_DIR="$(mktemp -d)"
trap 'rm -rf "$DEPLOY_DIR"' EXIT
git clone -q --depth 1 -b main "$REPO" "$DEPLOY_DIR"
rsync -a --delete --exclude .git public/ "$DEPLOY_DIR"/
touch "$DEPLOY_DIR/.nojekyll"
cd "$DEPLOY_DIR"
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "$MSG"
  git push origin main
  echo "    main 已发布"
else
  echo "    站点内容无变化，跳过"
fi

echo "✅ 完成：https://baihua-2002.github.io/（Pages 构建约需 1 分钟）"
