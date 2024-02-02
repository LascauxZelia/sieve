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
  log.info "=========================================================="
  log.info "=========================================================="
  log.info "========     SIEVE-NF  PIPELINE  VERSION 0.1    =========="
  log.info "=========================================================="
  log.info "=========================================================="
  log.info "Author                            : Zelia Bontemps"
  log.info "email                             : zelia.bontemps@imbim.uu.se"
  log.info "version                           : 0.1"
  log.info ""
}

def citationInfo() {
  log.info "========================= Citation ========================="
  log.info "Maybe one day we'll add :"
  log.info "XX pipeline is published in XX and available here:"
  log.info "doi:10."
  log.info ""
}

def startupMessage(){
  log.info "======================= File options ====================="
  log.info "Analysis accession file name      : $params.file_name"
  log.info ""
  log.info "====================== Filters options ===================="
  log.info "Biome name                        : $params.biome_name"
  log.info "Lineage                           : $params.lineage"
  log.info "Sample accession                  : $params.sample_accession"
  log.info "Instrument platform               : $params.instrument_platform"
  log.info "Instrument model                  : $params.instrument_model"
  log.info "Experiment type                   : $params.experiment_type"
  log.info "Study accession                   : $params.study_accession"
  log.info "Pipeline version                  : $params.pipeline_version"
  log.info "Check taxonomy class              : $params.taxonomyclass"
  log.info "Check taxonomy order              : $params.taxonomyorder"
  log.info "Check taxonomy phylum             : $params.taxonomyphylum"
  log.info "Check taxonomy family             : $params.taxonomyfamily"
  log.info "Check taxonomy genus              : $params.taxonomygenus"
  log.info "Check taxonomy species            : $params.taxonomyspecies"
  log.info "Megahit min contig lenght         : $params.min_contig_len"
  log.info "Megahit k-mer step                : $params.k_step"
  log.info "Megahit k-min                     : $params.k_min"
  log.info ""
  log.info "====================== Output options ======================"
  log.info "Main output dir (general)         : $params.resultsDir"
  log.info "Intermediate output dir           : $params.intermediateDir"
  log.info ""
  log.info "====================== Run options ======================="
  log.info "Pagination size                   : $params.page_size"
  log.info "Number of threads                 : $params.cpus"
  log.info "Binaries location (use default if singularity image is used)"
  log.info "Python 3 binary used              : $params.python3"
  log.info ""
  log.info ""
}

def helpMessage() {
  // Display help message
  log.info "========================== Usage ==========================="
  log.info ""
  log.info "Example:"
  log.info "nextflow run main.nf --experiment_type assembly"
  log.info "           --page_size 250"
  log.info "           --cpus 20"
  log.info ""
  log.info "Options:"
  log.info "--help, --h                       : Show this help and exit"
  log.info "================== Folder and file options ================="
  log.info "--result_folder"
  log.info "--data_folder"
  log.info "--01_file_name"
  log.info ""
  log.info "====================== Filters options ===================="
  log.info "--experiment_type                 : Experiment type (from mgnify API)"
  log.info "--biomes                          : Biomes types (from mgnify API)"
  log.info "--taxonomyclass                   : Taxonomy target at class level. "
  log.info "                                   If you want 1 add just the <name>"
  log.info "                                   If you want >1 add ["<name>","<name>"]"  
  log.info "--taxonomyorder                   : Same as taxonomyclass but at order level."
  log.info ""
  log.info "====================== Output options ======================"
  log.info "--rawdata_dir                     : Output dir for raw data"
  log.info "                                  (default 'raw_data)"
  log.info ""
  log.info "======================= Run options ========================"
  log.info "--page_size                       : Pagination size to save accession number"
  log.info "--cpus CPUs                       : Number of cpus to be used"
  log.info "Binaries location (use default if singularity image is used)"
  log.info "--python3 PYTHON3                 : Python 3 binary used"
  log.info ""
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
