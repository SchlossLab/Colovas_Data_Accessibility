configfile: "config.yaml"

rule targets:
    input: 
        "Data/gt_subset_30_clean_html.csv.gz",
         "Data/groundtruth_clean_html.csv.gz"


rule webscrape:
    input: 
       csv = "Data/{datasets}.csv",
       rscript = "Code/Webscrape.R"
    output: 
        "Data/{datasets}_html.csv.gz"
    shell: 
        """
        {input.rscript} {input.csv} {output}
        """

        

rule cleanHTML: 
    input:
      html = "Data/{datasets}_html.csv.gz",
      rscript = "Code/cleanHTML.R"
    output: 
        "Data/{datasets}_clean_html.csv.gz"
    shell: 
        """
        {input.rscript} {input.html} {output}
        """
        
