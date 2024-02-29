process ACCESSION {

    publishDir "$params.resultsDir/accession", mode:'copy'

    input:
    val file_name
    val biome_name
    val lineage
    val experiment_type
    val study_accession
    val sample_accession
    val instrument_platform
    val instrument_model
    val pipeline_version
    val page_size

    output:
    file "${file_name}"

    script:
    """  
    #!/usr/bin/env python
    # -*- coding: utf-8 -*-

    import argparse
    import concurrent.futures
    import csv
    import sys
    import logging
    import threading
    import time
    from urllib.parse import urlencode

    from jsonapi_client import Filter, Session

    sys.setrecursionlimit(40000)

    limit = sys.getrecursionlimit() 

    API_BASE = "https://www.ebi.ac.uk/metagenomics/api/v1"

    ## Parse options
    ##scriptName = sys.argv.pop(0)
    file_name = "$file_name"
    biome_name = "$biome_name"
    lineage = "$lineage"
    experiment_type = "$experiment_type"
    study_accession = "$study_accession"
    sample_accession = "$sample_accession"
    instrument_platform = "$instrument_platform"
    instrument_model = "$instrument_model"
    pipeline_version = "$pipeline_version"
    page_size = "$page_size"

    print("Starting...")

    with open(file_name, "w") as csvfile:
        # CSV initialization
        fieldnames = [
            "accession",
            "version",
            "experiment",
            "biome"
        ]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        # API call
        with Session(API_BASE) as session:

            # configure the filters
            params={
                'ordering': 'accession',
                'page_size': page_size
            }

            if experiment_type != "null":
                params['experiment_type'] = experiment_type
            if study_accession != "null":
                params['study_accession'] = study_accession
            if pipeline_version != "null":
                params['pipeline_version'] = pipeline_version
            if instrument_platform != "null":
                params['instrument_platform'] = instrument_platform
            if instrument_model != "null":
                params['instrument_model'] = instrument_model
            if sample_accession != "null":
                params['sample_accession'] = sample_accession
            if lineage != "null":
                params['lineage'] = lineage
            if biome_name != "null":
                params['biome_name'] = biome_name

            print(params)

            api_filter = Filter(urlencode(params))

            print(api_filter)

            # sessions.iterate will take care of the pagination for us
            for analyses in session.iterate(
                "analyses", api_filter
            ):
                try:
                    row = {
                    "version": analyses.pipeline_version,
                    "accession": analyses.accession,
                    "experiment" : analyses.experiment_type,
                    "biome" : analyses.sample.biome.lineage
                    }
                    writer.writerow(row)
                    print(f"Done for {analyses}")
                except:
                    print('URL Error for', analyses)


            print(csvfile)
            print("Data retrieved from the API")
            
    """
}