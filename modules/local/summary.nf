process SUMMARY {
    //publishDir "$params.resultsDir", pattern: "results_summary.tsv"

    input:
    file ('*')

    output: 
    file ('summary.tsv')

    script:
    """
    cat "$results" > summary.tsv

    """
}
