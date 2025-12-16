# PROJ_NAME

A reactive Python notebook project using [marimo](https://marimo.io) and [Nix](https://nixos.org/) with [uv2nix](https://github.com/pyproject-nix/uv2nix).

## Getting Started

```bash
# Initialize with your project name
nix run github:zmblr/toolz#init-template -- my-project-name .

# Enter development shell
direnv allow
# Or: nix develop .#impure

# Create/edit notebooks
marimo edit notebooks/example.py
```

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/) (recommended)

## Development Shells

| Shell    | Command                | Use Case                          |
| -------- | ---------------------- | --------------------------------- |
| `impure` | `nix develop .#impure` | Development with uv               |
| `pure`   | `nix develop .#pure`   | CI/deployment with fixed deps     |

### When to Use Each Shell

**impure** (daily development):
- Interactive notebook editing with `marimo edit`
- Flexible dependency management with `uv add`
- Quick iteration without rebuilding Nix derivations

**pure** (reproducibility):
- CI pipelines running notebooks as scripts
- Deploying marimo apps with `marimo run`
- Sharing exact environment with collaborators

## Project Structure

```
.
├── flake.nix           # Nix flake definition
├── pyproject.toml      # Python project config (package = false)
├── uv.lock             # Locked dependencies (commit this!)
├── nix/                # Nix modules
└── notebooks/          # Marimo notebooks
    └── example.py
```

## Adding Dependencies

```bash
# In impure shell
uv add pandas numpy

# Update lock file
uv lock --upgrade
```

## uv2nix for Notebook Projects

This template uses `[tool.uv] package = false` in pyproject.toml, meaning:
- No library is built (just dependency management)
- uv.lock fixes all dependency versions
- Pure shell provides reproducible notebook execution

**Workflow**:
1. Develop in `impure` shell (flexible, uses uv directly)
2. Commit `uv.lock` for reproducibility
3. Use `pure` shell in CI or for deployment

## Marimo Commands

```bash
marimo edit notebooks/example.py  # Edit notebook
marimo run notebooks/example.py   # Run as app (code hidden)
python notebooks/example.py       # Run as script
```

## License

MIT
