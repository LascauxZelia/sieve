process CAT { 
    publishDir "$params.resultsDir/contigs/classification/", pattern: "*_summary.txt"
    tag "$accession"

    input:
    tuple val(accession), val(experiment), val(biome), path(contig), path(reads)
    val cat_db
    val cat_taxonomy

    output: 
    tuple val(accession), path('*.alignment.diamond'), path('*.faa'), emit: classification
    path ('*_summary.txt'), emit: file_contig_classification

    script:
    """
    #Run classification of contigs
    CAT contigs -c "$contig" -d "$cat_db" -t "$cat_taxonomy" -n "$task.cpus" -o "$accession"

    #Add official name
    CAT add_names --only_official -i "$accession".contig2classification.txt -t "$cat_taxonomy" -o "$accession"classification_official_names.txt

    #Add non-official name
    CAT add_names -i "$accession".contig2classification.txt -t "$cat_taxonomy" -o "$accession"classification_names.txt

    #summarize results
    CAT summarise -c "$contig" -i "$accession"classification_official_names.txt -o "$accession"classification_summary.txt
    
    """
}
