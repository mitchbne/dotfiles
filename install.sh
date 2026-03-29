#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Homebrew (needed first for everything else)
if [ ! -x /opt/homebrew/bin/brew ] && [ ! -x /usr/local/bin/brew ]; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"

# GitHub CLI (needed for private repo auth)
echo "🍺 Installing brew packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

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
  if [ -d ~/.config/agents/skills ] && [ ! -L ~/.config/agents/skills ]; then
    rm -rf ~/.config/agents/skills
  fi
  ln -sfn "$AMP_SKILLS_DIR/skills" ~/.config/agents/skills
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
  cp -n /tmp/fonts-private/*.ttf ~/Library/Fonts/
  rm -rf /tmp/fonts-private
  echo "  ✓ MonoLisa fonts"
else
  echo "  ⚠️  Fonts repo not accessible — install MonoLisa manually"
fi

echo "🔧 Installing tools via mise..."
mise install

echo ""
echo "✅ Done! Restart your shell: exec zsh"
