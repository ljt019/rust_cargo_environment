#!/usr/bin/env bash

set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

main() {
    # Check if sudo is installed
    if ! command -v sudo &> /dev/null; then
        apt update
        apt install sudo -y
    fi

    log_info "Updating apt..."
    sudo apt update

    log_info "Installing git, tmux, htop, nvtop, cmake, python3-dev, cgroup-tools..."
    sudo apt install git tmux htop nvtop cmake python3-dev cgroup-tools -y

    log_info "Installing Rust and Cargo..."
    if ! command -v cargo &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
    else
        log_info "Rust and Cargo are already installed"
    fi

    log_info "Configuring SSH to automatically accept GitHub's host key..."
    ssh-keyscan github.com >>~/.ssh/known_hosts 2>/dev/null

    log_info "Cloning repository..."
    git clone git@github.com:PrimeIntellect-ai/prime-environments.git

    log_info "Entering project directory..."
    cd prime-environments

    log_info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh

    log_info "Installing pre-commit hooks..."
    uv run pre-commit install

    log_info "Sourcing uv environment..."
    if ! command -v uv &> /dev/null; then
        source $HOME/.local/bin/env
    fi

    log_info "Sourcing Rust environment..."
    if [ -f ~/.cargo/env ]; then
        source ~/.cargo/env
    fi

    log_info "Installing verifiers and flash-attn..."
    uv add 'verifiers[all]' && uv pip install flash-attn --no-build-isolation

    log_info "Installing dependencies in virtual environment..."
    uv sync

    log_info "Logging in to HuggingFace & WandB..."
    uv run hf auth login
    uv run wandb login

    log_info "Setup completed!"
}

main