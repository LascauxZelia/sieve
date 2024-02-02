process STATS {
    //publishDir "$params.resultsDir", pattern: "results_summary.tsv"

    input:
    tuple val(bin_name), val(superkingdom), val(phylum), val(classt), val(order), val(family), val(genus), val(species), val(accession), val(experiment), val(biome), val(bin_lenght), val(bin_gc), val(bin_completeness), val(bin_redundancy), val(bin_nbcontigs)

    output: 
    file ('results_summary.tsv')

    script:
    """
    echo -e ""$bin_name"\\t"$superkingdom"\\t"$phylum"\\t"$classt"\\t"$order"\\t"$family"\\t"$genus"\\t"$species"\\t"$accession"\\t"$experiment"\\t"$biome"\\t"$bin_lenght"\\t"$bin_gc"\\t"$bin_completeness"\\t"$bin_redundancy"\\t"$bin_nbcontigs"" >> results_summary.tsv
    sed -i '1i bin_name\\tsuperkingdom\\tphylum\\tclass\\torder\\tfamily\\tgenus\\tspecies\\taccession\\texperiment\\tbiome\\tbin_length\\tbin_gc\\tbin_completeness\\tbin_redundancy\\tbin_nb_contigs' results_summary.tsv
    """
}
