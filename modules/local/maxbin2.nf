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

    # Capture the exit status of the MaxBin2 command
    maxbin_exit_status=\$?

    # Check if MaxBin2 ran successfully or encountered the expected error
    if [[ \$maxbin_exit_status -eq 0 || \$maxbin_exit_status -eq 1 ]]; then
        # MaxBin2 ran successfully or encountered the expected error(s)
        echo "MaxBin2 completed successfully for "$accession or encountered the expected error""      
    else
        # MaxBin2 encountered an unexpected error
        echo "Something went wrong with running MaxBin2 for "$accession". Error code: \$maxbin_exit_status"
    fi

    """
}