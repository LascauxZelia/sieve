process ADAPTERREMOVAL { 
    tag "$accession"

    input:
    tuple val(single_end), val(accession), val(experiment), val(biome), path(reads)
    path(adapterlist)

    output:
    tuple val(accession), val(experiment), val(biome), path("*_trimSE.fastq.gz"), optional: true, emit: singles_truncated
    tuple val(accession), val(experiment), val(biome), path("*_trimPE.fastq.gz"), optional: true, emit: paired_truncated

    script:
    def args = task.ext.args ?: ''
    def list = adapterlist ? "--adapter-list ${adapterlist}" : ""

    if (single_end == true) {
        """
        AdapterRemoval  \\
            --file1 $reads \\
            $args \\
            $list \\
            --basename $accession \\
            --threads $task.cpus \\
            --seed 42 \\
            --gzip

        ensure_fastq() {
            if [ -f "\${1}" ]; then
                mv "\${1}" "\${1::-13}_trimSE.fastq.gz"
            fi

        }
        
        ensure_fastq '${accession}.truncated.gz'
        """
    } else {
        """
        AdapterRemoval  \\
            --file1 ${reads[0]} \\
            --file2 ${reads[1]} \\
            $args \\
            $list \\
            --basename $accession \\
            --threads $task.cpus \\
            --collapse \\
            --seed 42 \\
            --gzip

        ensure_fastq() {
            if [ -f "\${1}" ]; then
                mv "\${1}" "\${1::-23}_trimPE.fastq.gz"
            fi

        }

        ensure_fastq '${accession}.collapsed.truncated.gz'
        """
    }

}