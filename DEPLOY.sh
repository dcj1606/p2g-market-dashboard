#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
#  P2G Market Dashboard — one-shot deploy to Vercel + GitHub setup
#  Run this from the p2g-market-dashboard folder on your Mac/PC terminal
# ──────────────────────────────────────────────────────────────────────────

set -e

# ── Paste your tokens here (this file should NOT be committed to GitHub) ──
VERCEL_TOKEN=""   # paste your Vercel token between the quotes
GH_TOKEN=""       # paste your GitHub PAT between the quotes
GH_USER="dcj1606"
REPO_NAME="p2g-market-dashboard"

# Guard: exit early if tokens are missing
if [ -z "$VERCEL_TOKEN" ] || [ -z "$GH_TOKEN" ]; then
  echo "✗  Please open DEPLOY.sh and paste your Vercel and GitHub tokens before running."
  exit 1
fi

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║   Parcel2Go Market Dashboard — Deploy Script             ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# ── Step 1: Check Node / npm ─────────────────────────────────────────────
echo "▶  Checking Node.js..."
if ! command -v node &>/dev/null; then
  echo "✗  Node.js not found. Install from https://nodejs.org then re-run."
  exit 1
fi
echo "   Node $(node --version) ✓"

# ── Step 2: Install Vercel CLI if missing ────────────────────────────────
echo "▶  Checking Vercel CLI..."
if ! command -v vercel &>/dev/null; then
  echo "   Installing Vercel CLI..."
  npm install -g vercel
fi
echo "   Vercel CLI $(vercel --version 2>/dev/null | head -1) ✓"

# ── Step 3: Create GitHub repo ───────────────────────────────────────────
echo ""
echo "▶  Creating GitHub repo: $GH_USER/$REPO_NAME"
REPO_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "Content-Type: application/json" \
  https://api.github.com/user/repos \
  -d "{\"name\":\"$REPO_NAME\",\"description\":\"Parcel2Go UK Retail & Parcel Market Board Dashboard\",\"private\":false,\"auto_init\":false}")

REPO_URL=$(echo "$REPO_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('html_url',''))" 2>/dev/null)

if [ -n "$REPO_URL" ] && [ "$REPO_URL" != "None" ]; then
  echo "   Created: $REPO_URL ✓"
else
  # Might already exist
  REPO_URL="https://github.com/$GH_USER/$REPO_NAME"
  echo "   Repo may already exist — using: $REPO_URL"
fi

# ── Step 4: Push to GitHub ───────────────────────────────────────────────
echo ""
echo "▶  Pushing files to GitHub..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

git init -b main 2>/dev/null || (git init && git checkout -b main 2>/dev/null || true)
git config user.email "david.coleman-jones@parcel2go.com"
git config user.name "dcj1606"

# Add remote (replace if exists)
git remote remove origin 2>/dev/null || true
git remote add origin "https://$GH_TOKEN@github.com/$GH_USER/$REPO_NAME.git"

git add index.html vercel.json README.md
git commit -m "Initial commit: P2G Market Dashboard" 2>/dev/null || \
  git commit --allow-empty -m "Update dashboard"

git push -u origin main --force
echo "   Pushed to GitHub ✓"

# ── Step 5: Deploy to Vercel and link GitHub ─────────────────────────────
echo ""
echo "▶  Deploying to Vercel..."
DEPLOY_OUTPUT=$(vercel deploy \
  --token "$VERCEL_TOKEN" \
  --yes \
  --prod \
  --name "$REPO_NAME" \
  2>&1)

LIVE_URL=$(echo "$DEPLOY_OUTPUT" | grep -E "https://.*vercel\.app" | tail -1 | tr -d ' ')

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                   🚀 DEPLOYMENT COMPLETE                 ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║                                                          ║"
echo "║  Live URL:  $LIVE_URL"
echo "║  GitHub:    $REPO_URL                                    ║"
echo "║                                                          ║"
echo "║  Next: connect GitHub → Vercel for auto-deploy:          ║"
echo "║  https://vercel.com/dashboard → Settings → Git           ║"
echo "║                                                          ║"
echo "║  Then set your Google Sheet ID in index.html             ║"
echo "║  (see README.md for full instructions)                   ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
