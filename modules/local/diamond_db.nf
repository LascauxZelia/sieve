process DIAMOND_DB {

    input:
    val genes

    output:
    file 'references.dmnd'

    script:
      """
      cat "$genes"*.fasta > references.fasta
      diamond makedb --in references.fasta --db references.dmnd
      """
}