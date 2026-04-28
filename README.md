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
| **Mise** | Global tool versions and CLI tools (`ruby`, `node`, `go`, `lefthook`, Buildkite tools) |

## Install

```bash
git clone git@github.com:mitchbne/dotfiles.git ~/github.com/mitchbne/dotfiles
cd ~/github.com/mitchbne/dotfiles
./install.sh
```

## How it works

The install script **symlinks** everything into place, so edits in this repo are immediately live. Fonts are copied (not symlinked) since macOS expects them in `~/Library/Fonts/`.

It also links `~/.config/mise/config.toml` to this repo, then runs `mise install` and `mise upgrade --bump`, so globally managed tools like `lefthook`, `bk`, and `buildkite-agent` stay available and up to date.

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
| [lefthook](https://github.com/evilmartians/lefthook) | Installed globally by `./install.sh` via `mise` | Git hooks manager |
| [gh](https://cli.github.com) | `brew install gh` | GitHub CLI |
| [bk](https://github.com/buildkite/cli) | Installed globally by `./install.sh` via `mise` | Buildkite CLI |
| [buildkite-agent](https://buildkite.com/docs/agent) | Installed globally by `./install.sh` via `mise` | Buildkite build agent |
| [slack-cli](https://github.com/lox/slack-cli) | `brew install --cask lox/tap/slack-cli` | Slack CLI |
| [linear](https://github.com/schpet/linear) | `brew install schpet/tap/linear` | Linear CLI |
| [bun](https://bun.sh) | `brew install oven-sh/bun/bun` | JavaScript runtime & bundler |

### Infrastructure

| Tool | Install | Notes |
|---|---|---|
| [OrbStack](https://orbstack.dev) | `brew install --cask orbstack` | Docker & Linux VMs (replaces Docker Desktop) |
| [awscli](https://aws.amazon.com/cli/) | `brew install awscli` | AWS CLI |

### Productivity

| Tool | Install | Notes |
|---|---|---|
| [Raycast](https://raycast.com) | Direct download | Spotlight replacement |
| [1Password](https://1password.com) | App Store + `brew install --cask 1password-cli` | Password manager |
| [CleanShot X](https://cleanshot.com) | Direct download | Screenshots & recording |
| [Scroll Reverser](https://pilotmoon.com/scrollreverser/) | `brew install --cask scroll-reverser` | Natural scroll for trackpad, normal for mouse |

### Communication

| Tool | Install | Notes |
|---|---|---|
| [Slack](https://slack.com) | App Store | Team chat |
| [Linear](https://linear.app) | Direct download | Issue tracking |
| [Notion](https://notion.so) | Direct download | Docs & wiki |
| [Zoom](https://zoom.us) | Direct download | Video calls |

### Media

| Tool | Install | Notes |
|---|---|---|
| [Spotify](https://spotify.com) | Direct download | Music |
| [KeyCastr](https://github.com/keycastr/keycastr) | `brew install --cask keycastr` | Show keystrokes on screen (for demos) |
