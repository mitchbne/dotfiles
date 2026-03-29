#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

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

# Ghostty
mkdir -p ~/.config/ghostty
ln -sf "$DOTFILES_DIR/config/ghostty/config" ~/.config/ghostty/config
echo "  ✓ ~/.config/ghostty/config"

# Starship
ln -sf "$DOTFILES_DIR/config/starship/starship.toml" ~/.config/starship.toml
echo "  ✓ ~/.config/starship.toml"

# Amp (private repo)
if git clone git@github.com:mitchbne/amp-skills-private.git /tmp/amp-skills-private 2>/dev/null; then
  mkdir -p ~/.config/amp ~/.config/agents
  cp /tmp/amp-skills-private/AGENTS.md ~/.config/amp/AGENTS.md
  cp /tmp/amp-skills-private/settings.json ~/.config/amp/settings.json
  cp -r /tmp/amp-skills-private/skills ~/.config/agents/skills
  rm -rf /tmp/amp-skills-private
  echo "  ✓ Amp skills, AGENTS.md, settings"
else
  echo "  ⚠️  Amp skills repo not accessible — set up manually"
fi

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

# Fonts (private repo)
echo "📦 Installing fonts..."
mkdir -p ~/Library/Fonts
if git clone git@github.com:mitchbne/fonts-private.git /tmp/fonts-private 2>/dev/null; then
  cp -n /tmp/fonts-private/*.ttf ~/Library/Fonts/
  rm -rf /tmp/fonts-private
  echo "  ✓ MonoLisa fonts"
else
  echo "  ⚠️  Fonts repo not accessible — install MonoLisa manually"
fi

# Homebrew dependencies
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "🍺 Installing brew packages..."
brew install mise zsh-autosuggestions puma-dev awscli buildkite-agent bk@3

echo "🔧 Installing tools via mise..."
mise install

echo ""
echo "✅ Done! Restart your shell: exec zsh"
