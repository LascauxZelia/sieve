process MACSYFINDER { 
    tag "$accession"

    cpus 2
    maxForks 5

    input:
    tuple val(accession), val(experiment), val(biome), path(assembly), path(faa)
    val (modelpath)
    val (model)
    val (nbmodel)
    val (coverage)
    val (evalue)

    output: 
    tuple val(accession), val(experiment), val(biome), path('*_contig.fasta'), optional: true

    script:
    """
    if [ "$model" == "TXSScan" ]; then
        macsydata install -u TXSScan
    elif [ "$model" == "TFFscan" ]; then
        macsydata install -u TFFscan
    elif [ "$model" == "CONJscan" ]; then
        macsydata install -u CONJscan
    elif [ "$model" == "CasFinder" ]; then
        macsydata install -u CasFinder
    else
        cp -r "$modelpath" ~/.macsyfinder/models/
    fi

    result_file="macsyfinder_results.tsv"

    # Dataframe to save all accession value
    suffix_array=()

    # Execute MacSyfinder
    mkdir -p 'out_macsyfinder' || exit 1

    suffix_array+=("$accession")

    macsyfinder \
    --db-type ordered_replicon \
    --models "$model" "$nbmodel" \
    --profile-suffix .hmm \
    --sequence-db "$faa" \
    --replicon-topology circular \
    --i-evalue-sel 1e"$evalue" \
    --coverage-profile "$coverage" \
    --worker "$task.cpus" \
    --out-dir "out_macsyfinder"/"$accession";

    if [ -s "out_macsyfinder/"$accession"/all_best_solutions.tsv" ]; then
        cut -f 3 "out_macsyfinder/"$accession"/all_best_solutions.tsv" | tail -n +6 | sort | uniq > "out_macsyfinder/"$accession"_pre_contig_names.txt"
        awk -F'_' 'NR>1{print \$1"_"\$2}' "out_macsyfinder/"$accession"_pre_contig_names.txt" > "$accession"_contig_names.txt
        #If the contig_name file is empty, remove it. 
        if [ ! -s "$accession"_contig_names.txt ]; then
            rm "$accession"_contig_names.txt
        fi
    else
        echo "MacSyFinder output doesn't exist"
    fi

    # Check if the *_contig_name.txt file exists
    if [ -f "$accession"_contig_names.txt ]; then
        # Remove duplicates from the *_contig_name.txt file
        awk '!seen[\$0]++' "$accession"_contig_names.txt > "$accession"_contig_names_deduplicated.txt
   
        # Execute the seqtk subseq command
        seqtk subseq "$assembly" "$accession"_contig_names_deduplicated.txt > "$accession"_contig.fasta
        echo "Command executed for "$accession""

        # Optionally, you can remove the deduplicated file if you don't need it
        #rm "$accession"_contig_names_deduplicated.txt
    else
        echo "The contig_names.txt file does not exist"
    fi

    """
}