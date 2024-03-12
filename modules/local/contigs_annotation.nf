process CONTIGS_ANNOTATION { 
    publishDir "$params.resultsDir/contigs_annotation/", pattern: "*.faa"
    publishDir "$params.resultsDir/contigs_annotation/", pattern: "*.txt"
    tag "$accession"

    input:
    tuple val(accession), val(experiment), val(biome), path(assembly)

    output: 
    tuple val(accession), val(experiment), val(biome), path(assembly), path('*.faa'), emit: annotation
    path ('*.faa'), emit: faa_file
    path ('*.txt'), emit: txt_file

    script:
    """
    prodigal -a "${accession}_contigs_proteins.faa" -d "${accession}_genes.fas" -i "$assembly" -m -p meta -o "${accession}_contigs_prodigal_output.txt"
    """
}
