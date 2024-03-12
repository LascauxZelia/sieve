process BAT { 
    publishDir "$params.resultsDir/bins/classification/", pattern: "*_sub_classification.csv"
    tag "$bin_name"

    input:
    tuple val(accession), val(experiment), val(biome), path(bin), val(quality), val(bin_name), path(alignment), path(faa)
    val cat_db
    val cat_taxonomy
    val f

    output:
    path ('*_sub_classification.csv')

    script:
    bin_name = bin.baseName
    """
    CAT bins -b "$bin" -f "$f" -d "$cat_db" -t "$cat_taxonomy" -p "$faa" -a "$alignment" -n "$task.cpus" --no_stars -o "${bin_name}_bat"
    
    #Add official names
    CAT add_names --only_official -i "${bin_name}_bat.bin2classification.txt" -t "$cat_taxonomy" -o "${bin_name}_bins_classification_official_names.txt"
    #Add non-official names
    CAT add_names -i "${bin_name}_bat.bin2classification.txt" -t "$cat_taxonomy" -o "${bin_name}_bins_classification_names.txt"

    #Replace 'no support' by 'na' and delete space
    sed -i 's/no support/na/g' "${bin_name}_bins_classification_official_names.txt" 

    #Extract the last 7 columns
    awk -v bin_name="$bin_name" '{print bin_name", "\$11","\$12","\$13","\$14","\$15","\$16","\$17}' "${bin_name}_bins_classification_official_names.txt" > "${bin_name}_sub_class.csv"
    awk -F, 'BEGIN {OFS=","} {if (NR==1) {gsub(" ", "_"); print "bin_name,superkingdom,phylum,class,order,family,genus,species"} else {print}}' "${bin_name}_sub_class.csv" | sed 's/ //g' > "${bin_name}_sub_classification.csv"
    """
}

