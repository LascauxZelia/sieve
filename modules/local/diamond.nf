process DIAMOND {
    tag "$accession"

    input:
    tuple val(accession), val(experiment), val(biome), path(reads)
    file ref_db
    val cpus
    val min_align_reads

    output:
    tuple val(accession), val(experiment), val(biome), path(reads), path("*.daa"), optional: true

    script:
    """
    #Input
    ref_db="$ref_db"
    cpus="$cpus"
    diamond_min_align_reads="$min_align_reads"
    accession="$accession"
    file_path="$reads"

    # Execute diamond blastx
    diamond blastx -q "$reads" --db "$ref_db" -f 100 --unal 0 --id 85 -e 1e-6 --out "$accession".daa --threads "$task.cpus"

    # Check number of alignments in DAA file
    align_count=\$(diamond view --daa "$accession".daa | wc -l)

    if [ ! "\$align_count" -gt "$min_align_reads" ]; then
        rm "$accession".daa
    fi

    """
}


