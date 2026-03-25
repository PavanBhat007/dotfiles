# MacBook Development Setup Guide

A structured, fast, and extensible setup for modern full-stack development (Next.js, Python, MongoDB, Local AI, DevOps).

---

## 0. System Baseline

```bash
# Xcode CLI tools
xcode-select --install

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Update
brew update
brew upgrade
```

---

## 1. Core Shell + Productivity

```bash
brew install zsh git curl wget fzf ripgrep bat eza tmux
```

Optional:

```bash
brew install starship

echo 'eval "$(starship init zsh)"' >> ~/.zshrc
```

---

## 2. Node.js + Frontend Stack

```bash
brew install fnm

echo 'eval "$(fnm env)"' >> ~/.zshrc
source ~/.zshrc

fnm install --lts
fnm use --lts

node -v
npm -v
```

Global tools:

```bash
npm install -g pnpm
yarn
```

---

## 3. Python (Flask / FastAPI)

```bash
brew install pyenv

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
source ~/.zshrc
```

Install Python:

```bash
pyenv install 3.11
pyenv global 3.11
```

Install uv:

```bash
curl -Ls https://astral.sh/uv/install.sh | sh
```

Usage:

```bash
uv venv
source .venv/bin/activate
uv pip install fastapi flask uvicorn
```

---

## 4. MongoDB

```bash
brew tap mongodb/brew
brew install mongodb-community

brew services start mongodb-community
```

Check:

```bash
mongosh
```

Optional GUI:

```bash
brew install --cask mongodb-compass
```

---

## 5. Git Setup

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

git config --global init.defaultBranch main
git config --global core.editor "code --wait"
```

SSH:

```bash
ssh-keygen -t ed25519 -C "your@email.com"
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

---

## 6. VS Code

```bash
brew install --cask visual-studio-code
```

Recommended extensions:

* ES7 React Snippets
* Tailwind CSS IntelliSense
* Prettier
* ESLint
* Python
* Docker

Enable CLI:

```bash
# Cmd+Shift+P → Install 'code' command
```

---

## 7. Docker

```bash
brew install --cask docker
```

Test:

```bash
docker --version
docker run hello-world
```

---

## 8. Kubernetes (Optional)

```bash
brew install kubectl
brew install minikube
```

---

## 9. Local AI Setup

### Ollama

```bash
brew install ollama
ollama serve
```

Models:

```bash
ollama pull llama3
ollama pull mistral
ollama pull codellama
```

Test:

```bash
ollama run llama3
```

---

### AI Coding Tools

```bash
pip install aider-chat
```

Usage:

```bash
aider --model ollama/codellama
```

---

## 10. DevOps Tools

```bash
brew install gh
brew install lazygit
brew install htop
```

---

## 11. Productivity Tools

```bash
brew install --cask iterm2
brew install --cask rectangle
brew install --cask raycast
```

---

## 12. Directory Structure

```bash
mkdir ~/dev
cd ~/dev

mkdir projects experiments learning
```

---

## 13. First Project Sanity Check

```bash
# Next.js
pnpm create next-app@latest

# Python API
mkdir api && cd api
uv init
uv add fastapi uvicorn
```

---

## Setup Strategy

### Phase 1

* Homebrew
* Node.js
* VS Code
* Git

### Phase 2

* Python
* MongoDB

### Phase 3

* Docker

### Phase 4

* Ollama + AI

### Phase 5

* Go / Rust / Kubernetes

---

## Key Principle

> Optimize for fast iteration, not completeness.

Your setup should:

* Start quickly
* Install dependencies fast
* Support local AI workflows
* Scale to containers

---

## Optional Next Steps

* Add dotfiles
* Create bootstrap script
* Configure AI coding workflows
