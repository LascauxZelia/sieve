    process BIN_QUALITY_ANNOTATION { 
    tag "$accession"
    publishDir "$params.resultsDir/bins/quality", pattern: "*_bins_stats_quality.tab"
    publishDir "$params.resultsDir/bins/annotation", pattern: "*.faa"

    input:
    tuple val(accession), val(experiment), val(biome), path(bin)
    val completeness
    val redundancy

    output:
    tuple val(accession), val(experiment), val(biome), path(bin), env(quality), val(bin_name), emit: tuple_out
    path("*_bins_stats_quality.tab"), emit: quality_tab
    path('*.faa'), emit: bin_annotation
    tuple val(bin_name), val(accession), val(experiment), val(biome), env(bin_lenght), env(bin_gc), env(bin_completeness), env(bin_redundancy), env(bin_nbcontigs), emit: bin_stat

    script:
    bin_name = bin.baseName
    """
    cp "${bin}" "${bin_name}.fna"
    
    #Execute miComplete
    miComplete "${bin_name}.fna" --format 'fna' --hmms Bact105 > "${bin_name}_bins_stats_quality.tab"

    bin_lenght=\$(awk 'NR>3 { print \$2 }' "${bin_name}_bins_stats_quality.tab")
    bin_gc=\$(awk 'NR>3 { print \$3 }' "${bin_name}_bins_stats_quality.tab")
    bin_completeness=\$(awk 'NR>3 { print \$5 }' "${bin_name}_bins_stats_quality.tab")
    bin_redundancy=\$(awk 'NR>3 { print \$6 }' "${bin_name}_bins_stats_quality.tab")
    bin_nbcontigs=\$(awk 'NR>3 { print \$7 }' "${bin_name}_bins_stats_quality.tab")

    quality=\$(awk '
        NR>3 {
            if (\$5 >= "$completeness" && \$6 <= "$redundancy") {
                print "good_quality"
            } else {
                print "bad_quality"
            }
        }
    ' "${bin_name}_bins_stats_quality.tab")

    prep_summary="stats"
    """
}
