/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMS SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//include { paramsSummaryLog; paramsSummaryMap } from 'plugin/nf-validation'

//def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
//def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
//def summary_params = paramsSummaryMap(workflow)

// Print parameter summary log to screen
//log.info logo + paramsSummaryLog(workflow) + citation

//WorkflowSievemod.initialise(params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Builded from local
//
include { MGNIFY                         } from '../subworkflows/local/mgnify'
include { LOCAL_DATA                     } from '../subworkflows/local/local_data'

// MODULE: Installed from local

include { DIAMOND_DB                     } from '../modules/local/diamond_db'
include { DIAMOND                        } from '../modules/local/diamond'
include { ASSEMBLY as ASSEMBLY_AS        } from '../modules/local/assembly'
include { ASSEMBLY as ASSEMBLY_MG        } from '../modules/local/assembly'
include { CONTIGS_ANNOTATION             } from '../modules/local/contigs_annotation'
include { MACSYFINDER                    } from '../modules/local/macsyfinder'
include { CAT                            } from '../modules/local/cat'
include { CONTIGS_COVERAGE               } from '../modules/local/contigs_coverage'
include { MAXBIN2                        } from '../modules/local/maxbin2'
include { CONCOCT                        } from '../modules/local/concoct'
include { DASTOOL                        } from '../modules/local/DAStool'
include { BIN_QUALITY_ANNOTATION         } from '../modules/local/bin_quality'
include { BAT                            } from '../modules/local/bat'
include { STATS                          } from '../modules/local/stats'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow SIEVE {

    ch_reads = Channel.empty()

    if (!params.noapi){
        if (params.local){
            MGNIFY (params.file_name)
            LOCAL_DATA()
            ch_reads = ch_reads.mix(MGNIFY.out,LOCAL_DATA.out)
        }
        else {
            MGNIFY(params.file_name)
            ch_reads = MGNIFY.out
        }
    }
    else {
        LOCAL_DATA()
        ch_reads = LOCAL_DATA.out
    }

    //MODULE: Diamond

    if (!params.nodiamond){
        DIAMOND_DB(params.genes) 
        DIAMOND(ch_reads, DIAMOND_DB.out, params.cpus, params.diamond_min_align_reads)
        ch_pre_assembly = DIAMOND.out.map { row -> [row[0], row[1], row[2], row[3]] }
        //ch_pre_assembly.view()

    }
    else {
        ch_pre_assembly = ch_reads
    }

    //MODULE: Assembly

    ch_branch_assembly = ch_pre_assembly
        .branch {
            metagenomic: it[1] == "metagenomic"
            assembly: it[1] == "assembly"
        }
        
    ASSEMBLY_MG ( ch_branch_assembly.metagenomic, params.min_contig_len, params.k_step, params.k_min)
    ASSEMBLY_AS ( ch_branch_assembly.assembly, params.min_contig_len, params.k_step, params.k_min)

    ch_assembly = Channel.empty()
    ch_assembly = ch_assembly.mix(ASSEMBLY_MG.out.metagenomic, ASSEMBLY_AS.out.assembly)

    //MODULE: Annotation (contigs)
    CONTIGS_ANNOTATION(ch_assembly)

    //MODULE: MacSyFinder

    if (!params.nomacsyfinder){
        MACSYFINDER(CONTIGS_ANNOTATION.out.annotation, params.modelpath, params.model, params.nbmodel, params.coverage, params.evalue)
        ch_contigs = MACSYFINDER.out
    }
    else {
        ch_contigs = ch_assembly
    }

    ch_contigs = ch_contigs.combine(ch_reads, by: [0,1,2])

    //MODULE: CAT (contigs classification)
    CAT(ch_contigs,params.cat_db, params.cat_taxonomy)
    
    //MODULE: CONTIG_COVERAGE (BWA)
    CONTIGS_COVERAGE(ch_contigs)

    //MODULE: MAXBIN2, CONCOCT and DASTOOL - BINNING
    if (!params.nomaxbin2 && !params.noconcoct){
        ch_maxbin2 = MAXBIN2(CONTIGS_COVERAGE.out, params.markers, params.probthreshold)
            //.ifEmpty (exit 1, "No bins from Maxbin2, please resume the pipeline with '--nomaxbin2'")

        ch_concoct = CONCOCT(CONTIGS_COVERAGE.out, params.chunk_size, params.overlap_size)
            //.ifEmpty (exit 1, "No bins from Concoct, please resume the pipeline with '--noconcoct'") 

        ch_combined_binning = ch_contigs.combine(ch_maxbin2, by: [0,1,2])
            .combine(ch_concoct, by: [0,1,2])

        ch_dastool = DASTOOL(ch_combined_binning, params.score_threshold, params.megabin_penalty, params.duplicate_penalty)
        //ch_dastool.view()

        selected_channel = ch_dastool
    }
    if (!params.nomaxbin2 && params.noconcoct){
        ch_maxbin2 = MAXBIN2(CONTIGS_COVERAGE.out, params.markers, params.probthreshold)
        selected_channel = ch_maxbin2
    }
    if (params.nomaxbin2 && !params.noconcoct){
        ch_concoct = CONCOCT(CONTIGS_COVERAGE.out, params.chunk_size, params.overlap_size) 
        selected_channel = ch_concoct.map { row -> [row[0], row[1], row[2], row[4]] }
    }

    //MODULE: BIN_QUALITY_ANNOTATION (miComplete)
    BIN_QUALITY_ANNOTATION(selected_channel.transpose(),params.completeness, params.redundancy)

    ch_bins = BIN_QUALITY_ANNOTATION.out.tuple_out
        | branch {
            good: it[4] == "good_quality"
            bad: it[4] == "bad_quality"
        }

    //MODULE: BIN CLASSIFICATION (BAT)
    if (!params.class_all_bins){
        BAT(ch_bins.good.transpose().combine(CAT.out.classification, by: [0]), params.cat_db, params.cat_taxonomy, params.f)
    }
    else {
        BAT(BIN_QUALITY_ANNOTATION.out.tuple_out.transpose().combine(CAT.out.classification, by: [0]), params.cat_db, params.cat_taxonomy, params.f)
    }

    ch_stats = BAT.out.splitCsv(header: true)
        | map { row -> [row.bin_name, row.superkingdom, row.phylum, row.class, row.order, row.family, row.genus, row.species]}
        | combine(BIN_QUALITY_ANNOTATION.out.bin_stat, by: [0])
    
    //MODULE: STATS (Producing the final output file)
    STATS(ch_stats).collectFile(name: 'results.tsv', sort: true, storeDir: params.resultsDir, skip: 1, keepHeader: true)

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {

    println ( workflow.success ? """
        Pipeline execution summary
        ---------------------------
        Completed at: ${workflow.complete}
        Duration    : ${workflow.duration}
        Success     : ${workflow.success}
        workDir     : ${workflow.workDir}
        exit status : ${workflow.exitStatus}
        """ : """
        Failed: ${workflow.errorReport}
        exit status : ${workflow.exitStatus}
        """
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
