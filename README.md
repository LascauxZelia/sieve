# SIEVE Pipeline
SIEVE is a bioinformatics filters-analysis pipeline for assembly, binning and annotation of metagenomes from EBI public database (database mining) or local user data.

Please check the documentation [here](https://rdv-sieve.readthedocs.io)

Pipeline summary
================

To analyse metagenomic datasets, users can input their own data (the pipeline will be in charge of the trimming) or filter and collect data from the European public database EBI using the MGnify API. 

The pipeline then:

* Check for the presence of genes of interest using [diamond](<https://github.com/bbuchfink/diamond>)
* Performs assembly using [MEGAHIT](<https://github.com/voutcn/megahit>) and predicts proteins-coding genes for the assemblies using [Prodigal](<https://github.com/hyattpd/Prodigalt>).
* Check for the presence of macromolecular secretion systems with [MacSyFinder](<https://github.com/gem-pasteur/macsyfinder>).
* Extract contigs of interest and assigns taxonomy using [CAT](<https://github.com/dutilh/CAT>)
* Performs metagenome binning using [MaxBin2](<https://sourceforge.net/projects/maxbin2/>) and [CONCOCT](<https://github.com/BinPro/CONCOCT>) and checks the quality of the genome bins using [miComplete](<https://bitbucket.org/evolegiolab/micomplete/src/master/>).
* Refines bins with [DAS Tool](<https://github.com/cmks/DAS_Tool>) 
* Assigns taxonomy to bins using [BAT](<https://github.com/dutilh/CAT>)

Futhermore, the pipeline creates various reports in the results directory specified, including a final table summarizing the main findings of the run.
A shiny app is available to visualise the main results. 

Basic usage
===========

```
   nextflow run . --resultsDir <OUTDIR> --cat_db <PATH/TO/CAT_database> --cat_taxonomy <PATH/TO/CAT_taxonomy>
```

NOTE:: If you are new to Nextflow, please refer to this [page](<https://www.nextflow.io/docs/latest/getstarted.html>) on how to set-up Nextflow.  
WARNING:: Please provide pipeline parameters via the command line or Nextflow config file ``nextflow.config``.  

For more details and further functionality, please refer to the usage and parameters documentation

Pipeline output
===============

To see the results of an example test run with a full size dataset refers to results tab on the Github pipeline page. For more details about the output files and reports, please refer to the output documentation.

Input
=====

The pipeline supports two types of input. 

Local data
----------

The user can enter their own data by adding the flag ``--local``. All raw reads must be in the same directory and have the same extension ``.fastq.gz``. 

In the same directory the user must add the samples files. The samples file specifies the samples, the name of the corresponding raw read files and the sequencing pair represented in these files, separated by tabs. A template is available [here](<https://github.com/LascauxZelia/sieve>). 

It has the format: ``sample,read_1,read_2,biome``. For more details please refer to the documentation.

WARNING:: The 'local data' input option only works with short reads. 

MGnify API
----------

The pipeline can be run with metagenomic data from the European public database EBI. The data are retrieved using [MGnify API](<https://www.ebi.ac.uk/metagenomics>).

The MGnify ressource: 
   "Microbiome research involves the study of all genomes present within a specific environment. The approach can provide unique insights into the complex processes performed by environmental micro-organisms and their relationship to their surroundings, to each other, and, in some cases, to their host.

   MGnify offers an automated pipeline for the analysis and archiving of microbiome data to help determine the taxonomic diversity and functional & metabolic potential of environmental samples. Users can submit their own data for analysis or freely browse all of the analysed public datasets held within the repository. In addition, users can request analysis of any appropriate dataset within the European Nucleotide Archive (ENA). User-submitted or ENA-derived datasets can also be assembled on request, prior to analysis."

If you use the MGnify API option as input please cite the article: Lorna Richardson, Ben Allen, Germana Baldi, Martin Beracochea, Maxwell L Bileschi, Tony Burdett, Josephine Burgin, Juan Caballero-Pérez, Guy Cochrane, Lucy J Colwell, Tom Curtis, Alejandra Escobar-Zepeda, Tatiana A Gurbich, Varsha Kale, Anton Korobeynikov, Shriya Raj, Alexander B Rogers, Ekaterina Sakharova, Santiago Sanchez, Darren J Wilkinson, Robert D Finn, MGnify: the microbiome sequence data analysis resource in 2023, Nucleic Acids Research, Volume 51, Issue D1, 6 January 2023, Pages D753–D759, https://doi.org/10.1093/nar/gkac1080

For more details, please refer to the [usage documentation](<https://rdv-sieve.readthedocs.io/en/latest/usage.html>)

Credits
=======

SIEVE pipeline was written by Zelia Bontemps, Andrei Gulliaev and Lionel Guy at Uppsala University (Departement of Medical Biochemistry and Microbiology).

We thank the MGnify team for the assistance in the developpement of this pipeline. 


Citation
========

If you use SIEVE, please cite the article: XXX
