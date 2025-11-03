process FASTP {
    tag "${meta.id}"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_merged.fq.gz"), emit: merged
    tuple val(meta), path("*_unmerged_{F,R}.fq.gz"), emit: unmerged, optional: true
    path "*_fastp.{html,json}", emit: report

    script:
    def args = task.ext.args ?: ''
    def prefix = "${meta.base_name}"
    def fwd = reads[0]
    def rev = reads[1]

    """
    fastp \\
        -i ${fwd} \\
        -I ${rev} \\
        -o ${prefix}_unmerged_F.fq.gz \\
        -O ${prefix}_unmerged_R.fq.gz \\
        --merge \\
        --merged_out ${prefix}_merged.fq.gz \\
        --include_unmerged \\
        --average_qual 20 \\
        --length_required ${params.fastp.merge_min_length} \\
        --length_limit ${params.fastp.merge_max_length} \\
        --overlap_len_require ${params.fastp.merge_min_overlap} \\
        --overlap_diff_limit ${params.fastp.merge_max_diff_percent} \\
        -p \\
        -w ${task.cpus} \\
        -j ${prefix}_fastp.json \\
        -h ${prefix}_fastp.html \\
        --report_title "${prefix}" \\
        ${args}
    """
}
