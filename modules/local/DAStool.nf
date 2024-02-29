    process DASTOOL { 
    tag "$accession"

    input:
    tuple val(accession), val(experiment), val(biome), path(contig), path(reads), path(maxbin), path(concoct_file), path(concoct)
    val score_threshold
    val megabin_penalty
    val duplicate_penalty
    //val bin 

    //when: bin == ['maxbin2', 'concoct']

    output: 
    tuple val(accession), val(experiment), val(biome), path('*_DASTool_bins/*'), optional: true

    script:
    """
    #Preparation of input files for DASTool 
   
    mkdir -p "$accession"_maxbin
    #Move all .fasta files to the directory
    cp *_maxbin.*.fasta "$accession"_maxbin/
    /opt/conda/envs/sieve/bin/Fasta_to_Contig2Bin.sh -i "$accession"_maxbin/ -e fasta > "$accession"_maxbin.contigs2bin.tsv
    
    DAS_Tool -i "$concoct_file","$accession"_maxbin.contigs2bin.tsv -l concoct,maxbin -c "$contig" -o "$accession" --write_bin_evals --write_bins --duplicate_penalty "$duplicate_penalty" --megabin_penalty "$megabin_penalty" --threads "$task.cpus" --score_threshold "$score_threshold" || true

    # Capture the exit status
    DAStool_exit_status=\$?

    # Check if DASTool ran successfully or encountered the expected error
    if [[ \$DAStool_exit_status -eq 1 ]]; then
        # DasTool ran successfully or encountered the expected error(s)
        echo "DAS Tool for "$accession" encountered an error, please check the log file in the working directory. Error code: \$DAStool_exit_status"      
    fi

    """
}
