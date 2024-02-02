/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// MODULE
//
include { ADAPTERREMOVAL as ADAPTERREMOVAL_PE             } from '../../modules/local/adapterremoval'
include { ADAPTERREMOVAL as ADAPTERREMOVAL_SE             } from '../../modules/local/adapterremoval'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    EXECUTE SUBWORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow LOCAL_DATA {
    main:

    ch_local_data = Channel.empty()

    if (!params.assembly_input){
        ch_input_csv = Channel
            .from(file(params.local_input))
            .splitCsv(header: true)
            .map { row -> 
                if (row.size() >=4){
                    def accession = row.sample
                    def r1 = row.read_1 ? file(row.read_1, checkIfExists: true) : false
                    def r2 = row.read_2 ? file(row.read_2, checkIfExists: true) : false
                    def experiment = 'metagenomic'
                    def biome = row.biome
                    def single_end = params.single_end
                    if (!r1) exit 1, "Invalid input samplesheet: read_1 can not be empty."
                    if (!r2 && !params.single_end) exit 1, "Invalid input samplesheet: single-end short reads provided, but command line parameter `--single_end` is false. Note that either only single-end or only paired-end reads must provided."
                    if (r2 && params.single_end) exit 1, "Invalid input samplesheet: paired-end short reads provided, but command line parameter `--single_end` is true. Note that either only single-end or only paired-end reads must provided."

                    if (params.single_end)
                        return [  single_end, accession, experiment, biome, r1 ]
                    else
                        return [  single_end, accession, experiment, biome, [r1, r2] ]
                } else {
                    exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects at least 4."
                }
            }

        ch_branch = ch_input_csv
            .branch {
                single: it[0] == true
                paired: it[0] == false
            }
        
        ADAPTERREMOVAL_PE ( ch_branch.paired, [] )
        ADAPTERREMOVAL_SE ( ch_branch.single, [] )

        ch_local_trimmed = Channel.empty()
        ch_local_trimmed = ch_local_trimmed.mix(ADAPTERREMOVAL_SE.out.singles_truncated, ADAPTERREMOVAL_PE.out.paired_truncated)

        ch_local_data = ch_local_trimmed

    }

    else {
        ch_assembly_input_csv = Channel
            .from(file(params.local_input))
            .splitCsv(header: true)
            .map { row -> 
                if (row.size() >=4){
                    def accession = row.sample
                    def r1 = row.read_1 ? file(row.read_1, checkIfExists: true) : false
                    def r2 = row.read_2 ? file(row.read_2, checkIfExists: true) : false
                    def experiment = 'assembly'
                    def biome = row.biome
                    if (!r1) exit 1, "Invalid input samplesheet: read_1 can not be empty."
                    if (!r2 && !params.assembly_input) exit 1, "Invalid input samplesheet:  assembly_input provided, but command line parameter `--assembly_input` is false."
                    if (r2 && params.single_end) exit 1, "Invalid input samplesheet: paired-end short reads provided, but command line parameter `--assembly_input` is true."

                    if (params.assembly_input)
                        return [  accession, experiment, biome, r1 ]
                } else {
                    exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects at least 4."
                }
            }
        
        ch_local_data = ch_assembly_input_csv
    }

    ch_local_data.view()

    emit:
    ch_local_data                        // channel: [val(accession), val(experiment), val(biome), path(reads)]

}