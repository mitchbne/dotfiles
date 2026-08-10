#!/opt/homebrew/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

notify() {
  # $1 = subtitle, $2 = message
  osascript -e "display notification \"$2\" with title \"Dotfiles\" subtitle \"$1\"" 2>/dev/null || true
}

# Capture failures with line number for the EXIT trap
FAIL_LINE=""
trap 'FAIL_LINE=$LINENO' ERR

on_exit() {
  local rc=$?

  # Re-install the self-plist (we can't bootout/bootstrap ourselves while running,
  # so this is deferred until exit). Surface failures via notification.
  local self_plist="com.mitchbne.dotfiles-install.plist"
  local self_link="$HOME/Library/LaunchAgents/$self_plist"
  if ! ln -sf "$DOTFILES_DIR/config/launchd/$self_plist" "$self_link"; then
    notify "Self-install failed" "Could not symlink $self_plist"
  else
    launchctl bootout "gui/$(id -u)" "$self_link" 2>/dev/null || true
    if ! launchctl bootstrap "gui/$(id -u)" "$self_link" 2>/tmp/dotfiles-bootstrap.err; then
      notify "Self-install failed" "launchctl bootstrap failed; see /tmp/dotfiles-bootstrap.err"
    fi
  fi

  if [ "$rc" -ne 0 ]; then
    notify "Install failed (exit $rc)" "Failed near line ${FAIL_LINE:-?}; see /tmp/dotfiles-install.log"
  fi
  exit "$rc"
}
trap on_exit EXIT

install_launch_agent() {
  local plist="$1"
  ln -sf "$DOTFILES_DIR/config/launchd/$plist" ~/Library/LaunchAgents/$plist
  launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/$plist 2>/dev/null || true
  launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/$plist
  echo "  ✓ ~/Library/LaunchAgents/$plist"
}

uninstall_launch_agent() {
  local plist="$1"
  launchctl bootout gui/$(id -u) "$plist" 2>/dev/null || true
  rm -f "$plist"
  echo "  ✗ Removed $(basename "$plist")"
}

# Homebrew (needed first for everything else)
if [ ! -x /opt/homebrew/bin/brew ] && [ ! -x /usr/local/bin/brew ]; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"

# Mise (activate shims so mise-managed tools like node/npx are available, especially under launchd)
eval "$(mise activate bash --shims 2>/dev/null)" || true

# GitHub CLI (needed for private repo auth)
echo "🍺 Installing brew packages..."

# Snapshot current brew package versions before bundle
declare -A brew_versions_before
while IFS= read -r line; do
  pkg="${line%% *}"
  ver="${line#* }"
  brew_versions_before["$pkg"]="$ver"
done < <(brew list --versions)

# Homebrew refuses to load non-official formulae when tap trust is required.
# These are the third-party taps explicitly managed by this Brewfile.
brew trust --tap \
  ngrok/ngrok \
  oven-sh/bun \
  lox/tap \
  puma/puma \
  schpet/tap \
  withgraphite/tap

brew bundle --file="$DOTFILES_DIR/Brewfile"

# Compare versions and notify on upgrades
while IFS= read -r line; do
  pkg="${line%% *}"
  ver="${line#* }"
  old_ver="${brew_versions_before[$pkg]:-}"
  if [ -n "$old_ver" ] && [ "$old_ver" != "$ver" ]; then
    notify "Homebrew Upgrade" "Upgraded $pkg from $old_ver → $ver"
    echo "  📦 Upgraded $pkg from $old_ver → $ver"
  fi
done < <(brew list --versions)

if ! gh auth status &>/dev/null; then
  echo "🔑 Authenticate with GitHub..."
  gh auth login
fi

# Export GITHUB_TOKEN for downstream tools (mise, npx skills, etc.) so they
# don't hit unauthenticated rate limits. No-op if gh is missing or logged out.
if command -v gh &>/dev/null && gh auth status &>/dev/null; then
  export GITHUB_TOKEN="$(gh auth token)"
fi

echo "🔗 Linking dotfiles..."

# Shell
ln -sf "$DOTFILES_DIR/zshrc" ~/.zshrc
echo "  ✓ ~/.zshrc"

# Git
ln -sf "$DOTFILES_DIR/git/gitconfig" ~/.gitconfig
ln -sf "$DOTFILES_DIR/git/gitconfig.work" ~/.gitconfig.work
ln -sf "$DOTFILES_DIR/git/gitignore" ~/.gitignore
echo "  ✓ ~/.gitconfig, ~/.gitconfig.work, ~/.gitignore"

# Rails
ln -sf "$DOTFILES_DIR/railsrc" ~/.railsrc
echo "  ✓ ~/.railsrc"

# Custom bin scripts
mkdir -p ~/.local/bin
for script in "$DOTFILES_DIR/bin/"*; do
  ln -sf "$script" ~/.local/bin/
done
echo "  ✓ ~/.local/bin scripts"

# Ghostty
mkdir -p ~/.config/ghostty
ln -sf "$DOTFILES_DIR/config/ghostty/config" ~/.config/ghostty/config
echo "  ✓ ~/.config/ghostty/config"

# Starship
ln -sf "$DOTFILES_DIR/config/starship/starship.toml" ~/.config/starship.toml
echo "  ✓ ~/.config/starship.toml"

# Amp (private repo)
AMP_SKILLS_DIR="$HOME/github.com/mitchbne/amp-skills-private"
if [ -d "$AMP_SKILLS_DIR" ]; then
  amp_skills_rev_before=$(git -C "$AMP_SKILLS_DIR" rev-parse HEAD 2>/dev/null)
  git -C "$AMP_SKILLS_DIR" pull --ff-only 2>/dev/null
  amp_skills_rev_after=$(git -C "$AMP_SKILLS_DIR" rev-parse HEAD 2>/dev/null)
  if [ "$amp_skills_rev_before" != "$amp_skills_rev_after" ]; then
    amp_skills_summary=$(git -C "$AMP_SKILLS_DIR" log --oneline "$amp_skills_rev_before..$amp_skills_rev_after" | head -5)
    notify "Amp Skills Updated" "$amp_skills_summary"
    echo "  📦 Amp skills updated:"
    echo "$amp_skills_summary" | sed 's/^/      /'
  fi
else
  gh repo clone mitchbne/amp-skills-private "$AMP_SKILLS_DIR" 2>/dev/null
fi
if [ -d "$AMP_SKILLS_DIR" ]; then
  mkdir -p ~/.config/amp ~/.config/agents
  ln -sf "$AMP_SKILLS_DIR/AGENTS.md" ~/.config/amp/AGENTS.md
  ln -sf "$AMP_SKILLS_DIR/settings.json" ~/.config/amp/settings.json

  # Replace directory symlink with a real directory if needed
  [ -L ~/.config/agents/skills ] && rm ~/.config/agents/skills
  mkdir -p ~/.config/agents/skills

  # Mirror private skills so deleted or renamed skills do not remain active locally.
  find ~/.config/agents/skills -mindepth 1 -maxdepth 1 -exec rm -rf {} +
  for skill_dir in "$AMP_SKILLS_DIR/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_target="$HOME/.config/agents/skills/$(basename "$skill_dir")"
    cp -R "$skill_dir" "$skill_target"
  done

  echo "  ✓ Amp skills, AGENTS.md, settings"
else
  echo "  ⚠️  Amp skills repo not accessible — set up manually"
fi

# Sync npx skills (vercel-labs/skills). These are agent instructions, so this
# trusts the configured upstream sources and applies their updates during the
# daily dotfiles install.
echo "🔄 Checking npx skills..."

# Re-add every source to refresh installed skills and discover newly published
# ones. The update command below also covers global skills outside this list.
skill_sources=(
  "buildkite/skills"
  "buildkite/agent-skills-internal"
  "vercel-labs/agent-browser"
  "emilkowalski/skill"
  "buildkite/slopcannon"
  "marckohlbrugge/37signals-skills"
)

for source in "${skill_sources[@]}"; do
  echo "  🔄 Syncing $source..."
  npx -y skills add "$source" --skill '*' -a amp -g -y || echo "  ⚠️  Failed to sync $source"
done

# Apply upstream updates automatically.
skills_update_out=$(npx -y skills update -g -y 2>&1)
skills_update_status=$?
if [ "$skills_update_status" -ne 0 ]; then
  echo "  ⚠️  Failed to update npx skills"
  echo "$skills_update_out" | sed 's/^/      /'
elif echo "$skills_update_out" | grep -qiE "updated|installed|added|removed"; then
  changed_skills=$(echo "$skills_update_out" | grep -iE "updated|installed|added|removed" | head -10)
  notify "npx Skills Updated" "$changed_skills"
  echo "  📦 npx skills updated:"
  echo "$changed_skills" | sed 's/^/      /'
else
  echo "  ✓ npx skills up to date"
fi

# LaunchAgents (the self-plist is handled by the on_exit trap)
SELF_PLIST="com.mitchbne.dotfiles-install.plist"
for plist in "$DOTFILES_DIR/config/launchd/"*.plist; do
  name="$(basename "$plist")"
  [ "$name" = "$SELF_PLIST" ] && continue
  install_launch_agent "$name"
done
for plist in ~/Library/LaunchAgents/com.mitchbne.*.plist; do
  [ -f "$plist" ] || continue
  [ -f "$DOTFILES_DIR/config/launchd/$(basename "$plist")" ] || uninstall_launch_agent "$plist"
done

# Mise
mkdir -p ~/.config/mise
ln -sf "$DOTFILES_DIR/config/mise/config.toml" ~/.config/mise/config.toml
echo "  ✓ ~/.config/mise/config.toml"

# VS Code
VSCODE_DIR="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_DIR"
ln -sf "$DOTFILES_DIR/config/vscode/settings.json" "$VSCODE_DIR/settings.json"
ln -sf "$DOTFILES_DIR/config/vscode/keybindings.json" "$VSCODE_DIR/keybindings.json"
echo "  ✓ VS Code settings + keybindings"
if command -v code &>/dev/null && [ -f "$DOTFILES_DIR/config/vscode/extensions.txt" ]; then
  installed=$(code --list-extensions)
  while IFS= read -r ext; do
    [ -z "$ext" ] && continue
    if ! echo "$installed" | grep -qi "^${ext}$"; then
      code --install-extension "$ext"
    fi
  done < "$DOTFILES_DIR/config/vscode/extensions.txt"
  # Install simple-project-switcher from private repo (not on marketplace)
  if gh release download --repo mitchbne/simple-project-switcher --pattern "*.vsix" --dir /tmp --clobber 2>/dev/null; then
    code --install-extension /tmp/simple-project-switcher*.vsix
    rm -f /tmp/simple-project-switcher*.vsix
  else
    echo "  ⚠️  Could not download simple-project-switcher VSIX"
  fi
  echo "  ✓ VS Code extensions"
fi

# Fonts (private repo)
echo "📦 Installing fonts..."
mkdir -p ~/Library/Fonts
rm -rf /tmp/fonts-private
if gh repo clone mitchbne/fonts-private /tmp/fonts-private 2>/dev/null; then
  cp -n /tmp/fonts-private/*.ttf ~/Library/Fonts/ 2>/dev/null || true
  rm -rf /tmp/fonts-private
  echo "  ✓ MonoLisa fonts"
else
  echo "  ⚠️  Fonts repo not accessible — install MonoLisa manually"
fi

# macOS app preferences
echo "⚙️  Setting macOS app preferences..."

# Scroll Reverser — reverse trackpad scroll only, keep mouse natural
defaults write com.pilotmoon.scroll-reverser InvertScrollingOn -bool true
defaults write com.pilotmoon.scroll-reverser ReverseMouse -bool false
defaults write com.pilotmoon.scroll-reverser HideIcon -bool true
echo "  ✓ Scroll Reverser"

echo "🔧 Installing tools via mise..."
mise_before=$(mise list --installed 2>/dev/null | awk '{print $1, $2}' | sort -u)
mise install
mise upgrade --bump
mise_after=$(mise list --installed 2>/dev/null | awk '{print $1, $2}' | sort -u)

while IFS= read -r line; do
  [ -z "$line" ] && continue
  tool="${line%% *}"
  ver="${line#* }"
  notify "Mise" "Installed $tool $ver"
  echo "  📦 Installed $tool $ver"
done < <(comm -13 <(echo "$mise_before") <(echo "$mise_after"))

echo ""
echo "✅ Done! Restart your shell: exec zsh"
