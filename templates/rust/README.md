# PROJ_NAME

DESCRIPTION

## Prerequisites

- NixOS or Nix with flakes enabled

## Quick Start

```bash
# Enter development shell
nix develop

# Build and run
cargo run

# Or build with Nix
nix build
./result/bin/PROJ_NAME
```

## Development

### Commands

```bash
# Build
cargo build

# Run
cargo run

# Watch mode (auto-rebuild on changes)
cargo watch -x run

# Background compiler
bacon

# Run tests
cargo test

# Clippy lint
cargo clippy

# Format code
cargo fmt
```

### Nix Commands

```bash
# Build package
nix build

# Run checks (clippy, fmt, tests)
nix flake check

# Enter dev shell
nix develop

# Format all code
nix fmt
```

## Project Structure

```
PROJ_NAME/
├── flake.nix           # Nix flake configuration
├── nix/
│   ├── packages.nix    # Package definitions (with crane)
│   ├── shell.nix       # Development shell
│   ├── overlays.nix    # Nix overlays
│   └── formatter.nix   # Code formatting
├── src/
│   └── main.rs         # Main application
└── Cargo.toml          # Rust dependencies
```

## Incremental Builds

This project uses [crane](https://github.com/ipetkov/crane) for Nix builds:

- **Dependency caching**: Dependencies are built separately and cached
- **Incremental rebuilds**: Only changed code is recompiled
- **CI-friendly**: Faster CI builds due to layer caching

## License

MIT
