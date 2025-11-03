{
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages = {
      workflow = pkgs.writeShellScriptBin "workflow" ''
        #!${pkgs.bash}/bin/bash
        set -euo pipefail

        export TZ='Asia/Seoul'
        export IRR_PUB=1

        # Directory Setup
        ROOT=$(git rev-parse --show-toplevel)
        TIMESTAMP=$(date +%y%m%d_%H%M%S)
        OUTPUTS_DIR="$ROOT/outputs"
        EXPERIMENT_DIR="$OUTPUTS_DIR/experiments/$TIMESTAMP"
        WORK_DIR="$OUTPUTS_DIR/work"

        MAIN_WF="$ROOT/workflows/main.nf"

        # Create directories
        mkdir -p "$EXPERIMENT_DIR" "$WORK_DIR"

        # Logging Setup
        CONFIG_FILE="$ROOT/workflows/.nextflow.config/nextflow.config"
        LOG_FILE="$EXPERIMENT_DIR/run.log"
        REPORT_FILE="$EXPERIMENT_DIR/report.html"
        TRACE_FILE="$EXPERIMENT_DIR/trace.txt"
        TIMELINE_FILE="$EXPERIMENT_DIR/timeline.html"
        DAG_FILE="$EXPERIMENT_DIR/dag.html"

        # Environment Variables for Nextflow
        export NXF_CACHE_DIR="$ROOT/.nextflow"
        export NXF_RESULT_DIR="$EXPERIMENT_DIR/results"
        export ROOT

        if ${pkgs.nextflow}/bin/nextflow \
          -log "$LOG_FILE" \
          run "$MAIN_WF" \
          -config "$CONFIG_FILE" \
          -work-dir "$WORK_DIR" \
          -with-report "$REPORT_FILE" \
          -with-timeline "$TIMELINE_FILE" \
          -with-trace "$TRACE_FILE" \
          -with-dag "$DAG_FILE" \
          -profile nix \
          -resume \
          "$@"; then

          # Create symlink to latest experiment
          LATEST_LINK="$OUTPUTS_DIR/latest"
          rm -f "$LATEST_LINK"
          ln -s "experiments/$TIMESTAMP" "$LATEST_LINK"
          exit 0

        else
          exit 1
        fi
      '';
    };

    apps = rec {
      default = workflow;

      workflow = {
        type = "app";
        program = "${config.packages.workflow}/bin/workflow";
        meta.description = "one-shot workflow runner";
      };

      cleanup = {
        type = "app";
        program = toString (pkgs.writeScript "cleanup-nextflow" ''
          #!${pkgs.bash}/bin/bash
          set -e
          ROOT=$(git rev-parse --show-toplevel)
          rm -rf "$ROOT"/outputs
        '');
        meta.description = "one-shot workflow cleanup";
      };

      serve = {
        type = "app";
        program = toString (pkgs.writeScript "serve-page" ''
          #!${pkgs.bash}/bin/bash
          set -euo pipefail

          ROOT=$(git rev-parse --show-toplevel)

          echo "📂 Serving from: $ROOT"
          echo "🌐 http://127.0.0.1:8989"

          exec ${pkgs.miniserve}/bin/miniserve \
            -t "Inducible RNA Regulator" \
            -i 127.0.0.1 \
            -p 8989 \
            --dirs-first \
            --enable-zip \
            --enable-tar-gz \
            --show-wget-footer \
            "$ROOT/outputs/experiments"
        '');
        meta.description = "one-shot working copy serve app (browse+download)";
      };
    };
  };
}
