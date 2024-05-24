    process MAXBIN2 { 
    tag "$accession"

    input:
    tuple val(accession), val(experiment), val(biome), path(contig), path(ab), path(alignment)
    val markers
    val probthreshold
    //val bin

    //when: bin == 'maxbin2' || bin == ['maxbin2', 'concoct']

    output: 
    tuple val(accession), val(experiment), val(biome), path('*.fasta'), optional: true

    script:
    """
    #MaxBin2
    run_MaxBin.pl -contig "$contig" -abund "$ab" -out "$accession"_maxbin -thread "$task.cpus" -markerset "$markers" -prob_threshold "$probthreshold"  || true

    """
}
