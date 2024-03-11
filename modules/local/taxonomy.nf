process TAXONOMY {
    publishDir "$params.resultsDir/taxonomy", pattern: "*_taxonomy_details.csv"
    tag "$accession"

    input:
    val taxonomy_phylum
    val taxonomy_class
    val taxonomy_order
    val taxonomy_family
    val taxonomy_genus
    val taxonomy_species
    tuple val(accession), val(version), val(experiment), val(biome)

    output:
    path('*_ID_to_download.csv'), optional: true, emit: tax_id
    path('*_taxonomy_details.csv'), optional: true, emit: taxo_detail

    script:
    """
    #!/usr/bin/env python
    # -*- coding: utf-8 -*-

    ## Libraries 
    import csv
    import sys
    import os.path
    from pathlib import Path 
    import pandas 
    import urllib3
    from urllib.parse import urlencode, urlparse
    from urllib.request import urlretrieve
    from jsonapi_client import Session, Filter

    from jsonapi_client import Filter, Session

    API_BASE = "https://www.ebi.ac.uk/metagenomics/api/v1"

    ## Parse options
    taxonomyphylum = "$taxonomy_phylum"
    taxonomyclass = "$taxonomy_class"
    taxonomyorder = "$taxonomy_order"
    taxonomyfamily = "$taxonomy_family"
    taxonomygenus =  "$taxonomy_genus"
    taxonomyspecies = "$taxonomy_species"
    accession = "$accession"
    version = "$version"
    experiment = "$experiment"
    biome = "$biome"

    rows = []

    if float(version) > 3.0:
        ## Call API
        with Session(API_BASE) as session:
            print(f"Processing {accession} - {version}")
            for ssu_taxa in session.iterate(
                f"analyses/{accession}/taxonomy/ssu"
            ):
                if (
                ## Check if theses orders are present in accesion
                    ssu_taxa.hierarchy.get('phylum', '').lower() in [taxonomyphylum]
                    or
                    ssu_taxa.hierarchy.get('class','').lower() in [taxonomyclass]
                    or
                    ssu_taxa.hierarchy.get('order', '').lower() in [taxonomyorder]
                    or
                    ssu_taxa.hierarchy.get('family','').lower() in [taxonomyfamily]
                    or
                    ssu_taxa.hierarchy.get('genus','').lower() in [taxonomygenus]
                    or
                    ssu_taxa.hierarchy.get('species','').lower() in [taxonomyspecies]
                ):
                    print(f"For {accession} the nb of reads affiliated to {ssu_taxa.lineage} are : {ssu_taxa.count}")
                
                    try:
                        rows.append(                                
                            {
                            "accession": accession,
                            "name" : ssu_taxa.name,
                            "count":ssu_taxa.count,
                            "experiment": experiment,
                            "biome": biome
                            }
                        )
                        print(f"For {accession} the nb of reads affiliated to {ssu_taxa.name} are : {ssu_taxa.count}")
                    except:
                        print(f"Taxonomy for {accession}: not found")  
    else:
        ## Call API
        with Session(API_BASE) as session:
            print(f"Processing {accession} - {version}")
            for ssu_taxa in session.iterate(
                f"analyses/{accession}/taxonomy"
            ):
                if (
                ## Check if theses orders are present in accesion
                    ssu_taxa.hierarchy.get('phylum', '').lower() in [taxonomyphylum]
                    or
                    ssu_taxa.hierarchy.get('class','').lower() in [taxonomyclass]
                    or
                    ssu_taxa.hierarchy.get('order', '').lower() in [taxonomyorder]
                    or
                    ssu_taxa.hierarchy.get('family','').lower() in [taxonomyfamily]
                    or
                    ssu_taxa.hierarchy.get('genus','').lower() in [taxonomygenus]
                    or
                    ssu_taxa.hierarchy.get('species','').lower() in [taxonomyspecies]
                ):
                    print(f"For {accession} the nb of reads affiliated to {ssu_taxa.lineage} are : {ssu_taxa.count}")
                
                    try:
                        rows.append(                                
                            {
                            "accession": accession,
                            "name" : ssu_taxa.name,
                            "count":ssu_taxa.count,
                            "experiment": experiment,
                            "biome": biome
                            }
                        )
                        print(f"For {accession} the nb of reads affiliated to {ssu_taxa.name} are : {ssu_taxa.count}")
                    except:
                        print(f"Taxonomy for {accession}: not found")  
    
    # Create DataFrame
    data_frame = pandas.DataFrame(rows)
    print(data_frame)
    taxonomy_details = Path(f"{accession}_taxonomy_details.csv")
    data_frame.to_csv(taxonomy_details, index=False)
    print(f"CSV file created: {taxonomy_details}")
    
    if not data_frame.empty:
        # Sum counts per accession
        data_frame_sum = data_frame.groupby(["accession", "experiment", "biome"])["count"].sum().reset_index()

        # Filter accessions with non-zero count
        data_frame_filtered = data_frame_sum[data_frame_sum["count"] > 0]

        # Remove duplicates
        data_frame_filtered = data_frame_filtered.drop_duplicates(subset=["accession"])
            
        # Sort by count
        data_frame_filtered = data_frame_filtered.sort_values(["count"], ascending=False)
            
        # Create CSV file only if the filtered DataFrame is not empty
        result = Path(f"{accession}_ID_to_download.csv")
        data_frame_filtered.to_csv(result, index=False)
        print(f"CSV file created: {result}")

    else:
        print("No CSV file created as all counts are equal to zero.")

    """
}
