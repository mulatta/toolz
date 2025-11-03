include { FASTP } from './fastp.nf'
include { SELEXQC } from './selexqc.nf'
include { MULTIQC } from './multiqc.nf'

workflow PROCESS_READS {
    take:
    paired_reads

    main:
    FASTP(paired_reads)
    SELEXQC(FASTP.out.merged)

    qc_files = FASTP.out.report.collect()

    MULTIQC(qc_files)

    emit:
    merged = FASTP.out.merged
    filtered = SELEXQC.out.filtered
    reports = MULTIQC.out.html
    multiqc_data = MULTIQC.out.data
}
