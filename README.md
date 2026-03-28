# dotfiles

Personal dotfiles for macOS.

## What's included

| Category | Files |
|---|---|
| **Shell** | `zshrc` (zsh config, aliases, lazy-loading) |
| **Git** | `gitconfig`, `gitconfig.work`, `gitignore` |
| **Terminal** | Ghostty config, Starship prompt |
| **Fonts** | MonoLisa (Regular, Bold, Italic) |
| **Rails** | `railsrc` (default flags for `rails new`) |
| **Amp** | `AGENTS.md`, `settings.json`, all skills |
| **Mise** | Global tool versions (Ruby, Node, Go) |

## Install

```bash
git clone git@github.com:mitchbne/dotfiles.git ~/github.com/mitchbne/dotfiles
cd ~/github.com/mitchbne/dotfiles
./install.sh
```

## How it works

The install script **symlinks** everything into place, so edits in this repo are immediately live. Fonts are copied (not symlinked) since macOS expects them in `~/Library/Fonts/`.

## Apps & Tools

Things I use regularly on macOS. Install via App Store, Homebrew, or direct download.

### Terminal & Dev

| Tool | Install | Notes |
|---|---|---|
| [Ghostty](https://ghostty.org) | `brew install --cask ghostty` | Terminal emulator (config included) |
| [Starship](https://starship.rs) | `brew install starship` | Prompt with git info (config included) |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | `brew install zsh-autosuggestions` | Ghost text from history |
| [mise](https://mise.jdx.dev) | `brew install mise` | Tool version manager (Ruby, Node, Go) |
| [Overmind](https://github.com/DarthSim/overmind) | `brew install overmind` | Process manager for Procfile |
| [puma-dev](https://github.com/puma/puma-dev) | `brew install puma-dev` | Local `.localhost` domains |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `brew install ripgrep` | Fast search |
| [jq](https://jqlang.github.io/jq/) | `brew install jq` | JSON processor |
| [gh](https://cli.github.com) | `brew install gh` | GitHub CLI |
| [bk](https://github.com/buildkite/cli) | `brew install bk@3` | Buildkite CLI |
| [thefuck](https://github.com/nvbn/thefuck) | `brew install thefuck` | Auto-correct terminal commands |
| [shellcheck](https://www.shellcheck.net) | `brew install shellcheck` | Shell script linter |

### Infrastructure

| Tool | Install | Notes |
|---|---|---|
| [OrbStack](https://orbstack.dev) | `brew install --cask orbstack` | Docker & Linux VMs (replaces Docker Desktop) |
| [awscli](https://aws.amazon.com/cli/) | `brew install awscli` | AWS CLI |
| [aws-vault](https://github.com/99designs/aws-vault) | `brew install --cask aws-vault` | Secure AWS credential storage |
| [helm](https://helm.sh) | `brew install helm` | Kubernetes package manager |
| [k9s](https://k9scli.io) | `brew install k9s` | Kubernetes TUI |
| [tflint](https://github.com/terraform-linters/tflint) | `brew install tflint` | Terraform linter |

### Productivity

| Tool | Install | Notes |
|---|---|---|
| [Raycast](https://raycast.com) | Direct download | Spotlight replacement |
| [1Password](https://1password.com) | App Store + `brew install --cask 1password-cli` | Password manager |
| [CleanShot X](https://cleanshot.com) | Direct download | Screenshots & recording |
| [Scroll Reverser](https://pilotmoon.com/scrollreverser/) | `brew install --cask scroll-reverser` | Natural scroll for trackpad, normal for mouse |
| [NordVPN](https://nordvpn.com) | App Store | VPN |

### Communication

| Tool | Install | Notes |
|---|---|---|
| [Slack](https://slack.com) | App Store | Team chat |
| [Linear](https://linear.app) | Direct download | Issue tracking |
| [Notion](https://notion.so) | Direct download | Docs & wiki |
| [HEY](https://hey.com) | App Store | Email |
| [Zoom](https://zoom.us) | Direct download | Video calls |

### Media

| Tool | Install | Notes |
|---|---|---|
| [Spotify](https://spotify.com) | Direct download | Music |
| [KeyCastr](https://github.com/keycastr/keycastr) | `brew install --cask keycastr` | Show keystrokes on screen (for demos) |
