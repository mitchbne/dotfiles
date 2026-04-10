#!/opt/homebrew/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

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

# GitHub CLI (needed for private repo auth)
echo "🍺 Installing brew packages..."

# Snapshot current brew package versions before bundle
declare -A brew_versions_before
while IFS= read -r line; do
  pkg="${line%% *}"
  ver="${line#* }"
  brew_versions_before["$pkg"]="$ver"
done < <(brew list --versions)

brew bundle --file="$DOTFILES_DIR/Brewfile"

# Compare versions and notify on upgrades
while IFS= read -r line; do
  pkg="${line%% *}"
  ver="${line#* }"
  old_ver="${brew_versions_before[$pkg]:-}"
  if [ -n "$old_ver" ] && [ "$old_ver" != "$ver" ]; then
    osascript -e "display notification \"$pkg upgraded from $old_ver → $ver\" with title \"Dotfiles\" subtitle \"Homebrew Upgrade\""
    echo "  📦 $pkg: $old_ver → $ver"
  fi
done < <(brew list --versions)

if ! gh auth status &>/dev/null; then
  echo "🔑 Authenticate with GitHub..."
  gh auth login
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
  git -C "$AMP_SKILLS_DIR" pull --ff-only 2>/dev/null
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

  # Symlink private skills individually (live editing)
  for skill_dir in "$AMP_SKILLS_DIR/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    ln -sfn "$skill_dir" ~/.config/agents/skills/"$(basename "$skill_dir")"
  done

  echo "  ✓ Amp skills, AGENTS.md, settings"
else
  echo "  ⚠️  Amp skills repo not accessible — set up manually"
fi

# Sync npx skills (vercel-labs/skills)
echo "🔄 Syncing npx skills..."
npx -y skills add buildkite/agent-skills-internal --all -y
echo "  ✓ npx skills synced"

# LaunchAgents
for plist in "$DOTFILES_DIR/config/launchd/"*.plist; do
  install_launch_agent "$(basename "$plist")"
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
mise install

echo ""
echo "✅ Done! Restart your shell: exec zsh"
