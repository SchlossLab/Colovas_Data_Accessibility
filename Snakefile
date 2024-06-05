configfile: "config.yaml"

rule targets:
    input: 
        "Data/gt_subset_30_tokens.csv.gz",
       # "Data/groundtruth_tokens.csv.gz"


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


rule tokenize: 
    input:
      html = "Data/{datasets}_clean_html.csv.gz",
      rscript = "Code/tokenize.R"
    output: 
        "Data/{datasets}_tokens.csv.gz"
    shell: 
        """
        {input.rscript} {input.html} {output}
        """      

# rule ml_prep:
#     input:
#         tokens = "Data/{datasets}_tokens.csv.gz",
#         rscript = "Code/MLprep.R",
#         metadata = "Data/{datasets}.csv"
#         ml_vars = "{ml_variables}"
#     shell:
#         """
#         {input.rscript} {input.metadata} {input.ml_vars} {input.tokens} {output}
#         """

rule link_rot: 
    input:
        html = "Data/{datasets}_html.csv.gz",
        rscript = "Code/LinkRot.R",
        metadata = "Data/{datasets}.csv"
    output: 
        all_links = "Data/linkrot/{datasets}_alllinks.csv.gz"
        unique_links = "Data/linkrot/{datasets}_uniquelinks.csv.gz"
        metadata_links = "Data/linkrot/{datasets}_links_metadata.csv.gz"
    shell:
        """
        {input.rscript}  {input.html} {input.metadata} {output.all_links} 
        {output.metadata_links}
        """
