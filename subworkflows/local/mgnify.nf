/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// MODULE: Installed directly from nf-core/modules
//
include { ACCESSION                      } from '../../modules/local/accession'
include { TAXONOMY                       } from '../../modules/local/taxonomy'
include { DOWNLOAD                       } from '../../modules/local/download'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    EXECUTE SUBWORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow MGNIFY {
    take:
    file_name // file name (set as default in nextflow.config file)

    main:
    ch_accession = ACCESSION (
        file_name, params.biome_name, params.lineage, params.experiment_type, params.study_accession, params.sample_accession, params.instrument_platform, params.instrument_model, params.pipeline_version, params.page_size
    )

    if (params.taxonomyphylum == "null" && params.taxonomyclass == "null" && params.taxonomyorder == "null" && params.taxonomyfamily == "null" && params.taxonomygenus == "null" && params.taxonomyspecies == "null"){
            ch_taxonomy = ch_accession
            | splitCsv(header: true)
            | map { row -> [row.accession, row.experiment, row.biome]}
    }
    else {
        ch_split_accession = ch_accession
            | splitCsv(header: true)
            | map { row -> [row.accession, row.version, row.experiment, row.biome]}
            
        TAXONOMY(params.taxonomyphylum, params.taxonomyclass, params.taxonomyorder, params.taxonomyfamily, params.taxonomygenus, params.taxonomyspecies, ch_split_accession)
        
        ch_taxonomy = TAXONOMY.out.tax_id
            | splitCsv(header: true)
            | map { row -> [row.accession, row.experiment, row.biome]}
    }


    ch_download = DOWNLOAD(ch_taxonomy, params.resultsDir)

    emit:
    ch_download                              // channel: [val(accession), val(experiment), val(lineage), path(reads)]

}
