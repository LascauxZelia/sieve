process CONTIGS_COVERAGE { 
    tag "$accession"

    input:
    tuple val(accession), val(experiment), val(biome), path(contig), path(reads)

    output: 
    tuple val(accession), val(experiment), val(biome), path(contig), path("*_abundance.txt"), path("*_aln.sorted.*")

    script:
    """
    #Create bwa index
    bwa index "$contig" -p "$accession"_index
    
    #Align reads with bwa mem
    bwa mem -t "$task.cpus" -P "$accession"_index "$reads" > "$accession"_aln.sam
    
    #Convert and sort sam to bam file
    samtools view -b -@ "$task.cpus" "$accession"_aln.sam  > "$accession"_aln.bam
    samtools sort -@ "$task.cpus" "$accession"_aln.bam > "$accession"_aln.sorted.bam
    
    #Index BAM file
    samtools index "$accession"_aln.sorted.bam
    
    #Output per contig coverage for maxbin2
    pileup.sh in="$accession"_aln.sam out="$accession"_cov.txt
    
    #Generate abundance file from mapped reads
    awk '{print \$1"\t"\$5}' "$accession"_cov.txt | grep -v '^#' > "$accession"_abundance.txt

    """
}