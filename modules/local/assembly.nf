process ASSEMBLY { 
    tag "$accession"

    input:
    tuple val(accession), val(experiment), val(biome), path(reads)
    val min_contig_len
    val kstep
    val kmin    

    output: 
    tuple val(accession), val(experiment), val(biome), path ('*_assembly_MG.fasta'), optional: true, emit: metagenomic
    tuple val(accession), val(experiment), val(biome), path ('*_assembly_AS.fasta'), optional: true, emit: assembly

    script:
    if (experiment == "assembly") {
        """
        mv "$reads" "${accession}"_assembly_AS.fasta
        """
    } 
    else {
        """
        megahit -t "$task.cpus" --min-contig-len "$min_contig_len" --k-step "$kstep" --k-min "$kmin" -o "${accession}_megahit" -r "$reads"
        mv "${accession}_megahit/final.contigs.fa" "${accession}_assembly_MG.fasta"
        """
    }

}