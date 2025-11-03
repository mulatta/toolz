process SEQTABLE {
    tag "${meta.round}_${meta.sample_id}"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("${meta.sample_id}.counts.parquet"), emit: parquet
    tuple val(meta), path("${meta.sample_id}.counts.csv"), emit: csv, optional: true

    script:
    """
    seqtable ${fasta} \
        -s .counts \
        --rpm

    mv *.counts.parquet ${meta.sample_id}.counts.parquet
    """
}
