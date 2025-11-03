process MULTIQC {
    input:
    path reports

    output:
    path "multiqc.html", emit: html
    path "multiqc_data", emit: data

    when:
    !params.skip_multiqc

    script:
    def args = task.ext.args ?: ''
    """
    # Use work directory for tmp to avoid permission issues
    export TMPDIR=\$PWD/tmp_multiqc
    mkdir -p \$TMPDIR
    
    multiqc . \
        -n multiqc \
        -o . \
        --title "RNA Capture-SELEX Pipeline QC Report" \
        --comment "Quality control metrics for SELEX NGS data preprocessing" \
        --no-clean-up \
        ${args}
    
    # Cleanup
    rm -rf \$TMPDIR 2>/dev/null || true
    """
}
