process SELEXQC {
    tag "${meta.id}"
    publishDir "${params.outdir}/filtered", mode: 'copy', pattern: "*.filtered.fa"
    publishDir "${params.outdir}/qc", mode: 'copy', pattern: "*_mqc.json"

    input:
    tuple val(meta), path(merged_fq)

    output:
    tuple val(meta), path("${meta.id}.filtered.fa"), emit: filtered

    script:
    """
    selexqc \
        -i ${merged_fq} \
        -o ${meta.id} \
        -c ${params.library.docking_sequence} \
        --min-length ${params.selexqc.min_length} \
        --max-length ${params.selexqc.max_length} \
        --validation-mode and \
        --filter \
        --filter-format fasta \
        --threads ${task.cpus}
    """
}
