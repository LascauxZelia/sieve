process DOWNLOAD {
    tag "$accession"

    input:
    tuple val(accession), val(experiment), val(biome)
    val outputDir

    output:
    tuple val(accession), val(experiment), val(biome), path('*.fastq.gz')

    script:
    """
    #!/usr/bin/env python
    # -*- coding: utf-8 -*-

    ## Libraries 
    import os
    from urllib.request import urlretrieve
    from jsonapi_client import Session

    API_BASE = "https://www.ebi.ac.uk/metagenomics/api/v1"

    accession = '$accession'
    experiment = '$experiment'
    lineage = "$biome"
    outputDir = "$outputDir"

    def download_and_concatenate(session, accession, experiment):
        if experiment == "metagenomic":
            label = 'Processed nucleotide reads'
        elif experiment == "assembly":
            label = 'Processed contigs'
        else:
            label = None

        file_list = []
        for download in session.iterate(f"analyses/{accession}/downloads"):
            if (label and download.description.label == label
                    and
                    download.file_format.name == 'FASTA'):
                try:
                    local_file = "{}.fastq.gz".format(download.alias)
                    print(f"Downloading file for {accession}:", download.alias)
                    urlretrieve(download.links.self.url, local_file)
                    file_list.append(local_file)
                except Exception as e:
                    print(f'Error for {accession}: {str(e)}')

        # Concatenate files for the analysis
        if file_list:
            try:
                output_file = "{}.fastq.gz".format(accession)
                cat_command = "cat {} > {}".format(" ".join(file_list), output_file)
                os.system(cat_command)

                # Remove individual files
                for file in file_list:
                    rm_command = "rm {}".format(file)
                    os.system(rm_command)

                print(f"Concatenation and removal completed for accession {accession}.")
            except Exception as e:
                print(f'Error during concatenation for accession {accession}: {str(e)}')
        else:
            print(f"No files to concatenate for accession {accession}.")

    # Example usage
    with Session(API_BASE) as session:
        download_and_concatenate(session, accession, experiment)
    
    print("Done")
    """
}