#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BAMSTATS } from '../../../../modules/nf-core/bamstats/main.nf'

workflow test_bamstats_no_annotation {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    BAMSTATS ( input, [] )
}

workflow test_bamstats_annotation {

    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]
    annotation = file(params.test_data['sarscov2']['genome']['genome_gtf'], checkIfExists: true)

    BAMSTATS ( input,  annotation )
}
