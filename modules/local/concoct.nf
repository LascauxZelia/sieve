    process CONCOCT { 
    tag "$accession"

    input:
    tuple val(accession), val(experiment), val(biome), path(contig), path(ab), path(alignment)
    val chunk_size
    val overlap_size
    //val bin

    //when: bin == 'concoct' || bin == ['maxbin2', 'concoct']

    output: 
    tuple val(accession), val(experiment), val(biome), path('*_concoct.contigs2bin.tsv'), path('*_concoct_bins/*.fa'), optional: true

    script:
    """
    #Concoct
    #Cut contigs into smaller parts
    cut_up_fasta.py "$contig" -c $chunk_size -o $overlap_size --merge_last -b "$accession"_contigs_10K.bed > "$accession"_contigs_10K.fasta
    
    #Generatel table with coverage depth information per sample and subcontig
    concoct_coverage_table.py "$accession"_contigs_10K.bed "$accession"_aln.sorted.bam > "$accession"_coverage_table.tsv
    
    #Run concoct
    concoct --composition_file "$accession"_contigs_10K.fasta --coverage_file "$accession"_coverage_table.tsv --basename "$accession"
    
    #Merge subcontig clustering into original contig clustering
    merge_cutup_clustering.py "$accession"_clustering_gt1000.csv > "$accession"_clustering_merged.csv
    
    #Extract bins as individual FASTA
    mkdir "$accession"_concoct_bins
    extract_fasta_bins.py "$contig" "$accession"_clustering_merged.csv --output_path "$accession"_concoct_bins
    
    #Preparing concoct file for DAS_TOOL
    sed "s/,/\\t"$accession"_concoct./g;" "$accession"_clustering_merged.csv | tail -n +2 > "$accession"_concoct.contigs2bin.tsv

    for i in "$accession"_concoct_bins/*.fa; do
        mv \${i} \${i/\\///${accession}_concoct.}
    done

    """
}