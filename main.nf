#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    LascauxZelia/sieve
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/LascauxZelia/sieve
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE & PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Print help message if needed
if (params.help || params.h) {
    helpMessage()
    citationInfo()
    System.exit(0)
}else if ( !(params.resultsDir) ) {
  log.info "ERROR: no outpur directory given, will not continue"
  helpMessage()
  exit 0
}

citationInfo()
startupMessage()

def versionLogo() {
  log.info "================================================================================="
  log.info "================================================================================="
  log.info "======================     SIEVE-NF  PIPELINE  VERSION 0.1    ==================="
  log.info "================================================================================="
  log.info "================================================================================="
  log.info "Author                                        : Zelia Bontemps"
  log.info "email                                         : zelia.bontemps@imbim.uu.se"
  log.info "version                                       : 0.1"
  log.info ""
}

def citationInfo() {
  log.info "============================ Citation =========================================="
  log.info "XX pipeline is published in XX and available here:"
  log.info "doi:10."
  log.info ""
}

def startupMessage(){
  log.info "======================== Input options ========================================="
  log.info "No MGnify API                                : $params.noapi"
  log.info "Local data                                   : $params.local"
  log.info ""
  log.info "====================== Local data options ======================================"
  log.info "Single_end                                   : $params.single_end"
  log.info "Local_input                                  : $params.local_input"
  log.info "assembly_input                               : $params.assembly_input"
  log.info ""
  log.info "====================== Filters options ========================================="
  log.info "Analysis accession file name                 : $params.file_name"
  log.info "Biome name                                   : $params.biome_name"
  log.info "Lineage                                      : $params.lineage"
  log.info "Sample accession                             : $params.sample_accession"
  log.info "Instrument platform                          : $params.instrument_platform"
  log.info "Instrument model                             : $params.instrument_model"
  log.info "Experiment type                              : $params.experiment_type"
  log.info "Study accession                              : $params.study_accession"
  log.info "Pipeline version                             : $params.pipeline_version"
  log.info "Pagination size                              : $params.page_size"
  log.info "Check taxonomy class                         : $params.taxonomyclass"
  log.info "Check taxonomy order                         : $params.taxonomyorder"
  log.info "Check taxonomy phylum                        : $params.taxonomyphylum"
  log.info "Check taxonomy family                        : $params.taxonomyfamily"
  log.info "Check taxonomy genus                         : $params.taxonomygenus"
  log.info "Check taxonomy species                       : $params.taxonomyspecies"
  log.info ""
  log.info "====================== Diamond options ======================================="
  log.info "No diamond                                   : $params.nodiamond"
  log.info "Minimum number of reads alignments           : $params.diamond_min_align_reads"
  log.info ""
  log.info "====================== Assembly options ======================================"
  log.info "Megahit min contig lenght                    : $params.min_contig_len"
  log.info "Megahit k-mer step                           : $params.k_step"
  log.info "Megahit k-min                                : $params.k_min"
  log.info ""
  log.info ""
  log.info "====================== MacSyFinder options ==================================="
  log.info "No MacSyFinder                               : $params.nomacsyfinder"
  log.info "Model path                                   : $params.modelpath"
  log.info "Model name                                   : $params.model"
  log.info "Nomber of models                             : $params.nbmodel"
  log.info "Coverage                                     : $params.coverage"
  log.info "evalue                                       : $params.evalue"
  log.info ""
  log.info "====================== Binning options ======================================="
  log.info "No Maxbin2                                   : $params.nomaxbin2"
  log.info "No concoct                                   : $params.noconcoct"
  log.info "Markers (Maxbin2)                            : $params.markers"
  log.info "Probability threshold (Maxbin2)              : $params.probthreshold"
  log.info "Score threshold (Maxbin2)                    : $params.score_threshold"
  log.info "Chunk size (Concoct)                         : $params.chunk_size"
  log.info "Overlap size (Concoct)                       : $params.overlap_size"
  log.info "Megabin penalty (Concoct)                    : $params.megabin_penalty"
  log.info "Duplicate penalty (Concoct)                  : $params.duplicate_penalty"
  log.info "Completeness (miComplete)                    : $params.completeness"
  log.info "Redundancy (miComplete)                      : $params.redundancy"
  log.info ""
  log.info "====================== Classification options ================================"
  log.info "Absolute path for cat database (required)    : $params.cat_db"
  log.info "Absolute path for cat taxonomy (required)    : $params.cat_taxonomy"
  log.info "f (Min fraction classification supp.)        : $params.f"
  log.info "Classification on all the bins               : $params.class_all_bins"
  log.info ""
  log.info "====================== Output options ========================================"
  log.info "Main output dir (general)                    : $params.resultsDir"
  log.info "Publish dir mode                             : $params.publish_dir_mode"
  log.info ""
  log.info "====================== Run options =========================================="
  log.info "Help                                         : $params.help"
  log.info "Number of threads                            : $params.cpus"
  log.info "Binaries location (use default if singularity image is used)"
  log.info "Python 3 binary used                         : $params.python3"
  log.info ""
}

def helpMessage() {
  // Display help message
  log.info "========================== Usage ================================"
  log.info ""
  log.info "Example:"
  log.info "nextflow run main.nf "
  log info "           --resultsDir <OUTDIR> "
  log info "           --cat_db <PATH/TO/CAT_database> "
  log info "           --cat_taxonomy <PATH/TO/CAT_taxonomy> "
  log.info ""
  log.info "Options:"
  log.info "--help, --h                       : Show this help and exit"
  log.info "Please read the documentation: https://rdv-sieve.readthedocs.io"
  log.info ""
  log.info "==============================================================="
}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { SIEVE } from './workflows/sieve'

//
// WORKFLOW: Run main LascauxZelia/sieve analysis pipeline
//
workflow NF_SIEVE {
    SIEVE ()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
//
workflow {
    NF_SIEVE ()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
