{
  perSystem = {pkgs, ...}: let
    # Use the same toolchain as packages.nix
    rustToolchain = pkgs.rust-bin.stable.latest.default.override {
      extensions = ["rust-src" "rust-analyzer" "clippy" "rustfmt"];
    };
  in {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        # Rust toolchain (from rust-overlay)
        rustToolchain

        # Development tools
        cargo-watch
        cargo-flamegraph
        cargo-bloat
        cargo-expand
        bacon

        # Fast linker
        mold

        # Build tools
        pkg-config
      ];

      # Environment variables
      shellHook = ''
        export ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
        export CARGO_HOME="$ROOT/.cargo"

        # Use mold linker for faster builds
        export RUSTFLAGS="-C link-arg=-fuse-ld=mold"

        # Rust source for IDE support
        export RUST_SRC_PATH="${pkgs.rustPlatform.rustLibSrc}"

        echo "🦀 Rust development environment ready!"
        echo "   Rust: $(rustc --version)"
        echo "   Cargo: $(cargo --version)"
        echo ""
        echo "Available commands:"
        echo "  cargo build          - Build the project"
        echo "  cargo run            - Run the project"
        echo "  cargo watch -x run   - Watch and run on changes"
        echo "  bacon                - Background Rust compiler"
        echo "  nix build            - Build with Nix"
      '';
    };
  };
}
