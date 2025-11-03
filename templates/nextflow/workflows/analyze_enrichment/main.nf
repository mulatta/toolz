include { SEQTABLE } from './seqtable.nf'

workflow ANALYZE_ENRICHMENT {
    take:
    filtered_sequences // tuple(meta, fasta) from PROCESS_READS
    samplesheet // path to CSV with metadata

    main:
    // Read samplesheet and create enriched metadata
    metadata = Channel.fromPath(samplesheet)
        .splitCsv(header: true)
        .map { row ->
            def meta = [
                sample_id: row.sample_id,
                round: row.round,
                library: row.library,
                lib_structure: row.lib_structure ?: 'unknown',
                replicate: row.replicate,
                condition: row.condition,
                group: row.group ?: "${row.round}_${row.library}_${row.condition}",
            ]
            tuple(row.sample_id, meta)
        }

    // Join filtered sequences with metadata
    enriched_seqs = filtered_sequences
        .map { meta, fasta -> tuple(meta.id, fasta) }
        .join(metadata)
        .map { sample_id, fasta, meta -> tuple(meta, fasta) }

    // Generate sequence count tables
    SEQTABLE(enriched_seqs)

    emit:
    counts = SEQTABLE.out.parquet
}
