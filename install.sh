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

# Amp
mkdir -p ~/.config/amp
ln -sf "$DOTFILES_DIR/config/amp/AGENTS.md" ~/.config/amp/AGENTS.md
ln -sf "$DOTFILES_DIR/config/amp/settings.json" ~/.config/amp/settings.json
echo "  ✓ ~/.config/amp/"

# Amp skills
mkdir -p ~/.config/agents
ln -sfn "$DOTFILES_DIR/config/agents/skills" ~/.config/agents/skills
echo "  ✓ ~/.config/agents/skills"

# Mise
mkdir -p ~/.config/mise
ln -sf "$DOTFILES_DIR/config/mise/config.toml" ~/.config/mise/config.toml
echo "  ✓ ~/.config/mise/config.toml"

# Fonts
echo "📦 Installing fonts..."
mkdir -p ~/Library/Fonts
cp -n "$DOTFILES_DIR/fonts/"*.ttf ~/Library/Fonts/ 2>/dev/null || true
echo "  ✓ MonoLisa fonts"

# Homebrew dependencies
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "🍺 Installing brew packages..."
brew install starship zsh-autosuggestions mise

echo ""
echo "✅ Done! Restart your shell: exec zsh"
