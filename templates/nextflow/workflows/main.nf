#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PROCESS_READS } from './process_reads/main.nf'
include { ANALYZE_ENRICHMENT } from './analyze_enrichment/main.nf'

workflow {
    log.info(
        """
    =====================================
    IRR Pipeline - RNA Capture-SELEX
    =====================================
    Sample dir   : ${params.sample_dir}
    Samplesheet  : ${params.samplesheet}
    Output dir   : ${params.outdir}
    =====================================
    """.stripIndent()
    )

    paired_reads = Channel.fromFilePairs("${params.sample_dir}/*_{F,R}.fq.gz", flat: true)
        .map { sample_id, file1, file2 ->
            def meta = [id: sample_id, base_name: sample_id]
            tuple(meta, [file1, file2])
        }

    PROCESS_READS(paired_reads)

    ANALYZE_ENRICHMENT(
        PROCESS_READS.out.filtered,
        file(params.samplesheet),
    )
}
