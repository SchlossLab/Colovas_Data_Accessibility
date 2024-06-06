configfile: "config.yaml"

start_seed = 2000
seeds = range(start_seed, start_seed + nseeds)

rule targets:
    input: 
      "Data/ml_results/groundtruth/runs/glmnet_2000_new_seq_data_model.Rds"
      


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

rule ml_prep:
    input:
        tokens = "Data/{datasets}_tokens.csv.gz",
        rscript = "Code/MLprep.R",
        metadata = "Data/{datasets}.csv",
        ml_vars = "{ml_variables}"
    output: 
        "Data/{datasets}_preprocessed.Rds"
    shell:
        """
        {input.rscript} {input.metadata} {input.ml_vars} {input.tokens} {output}
        """

rule train_ml_set_seed:
    input:
        rds = "Data/{datasets}_preprocessed.Rds"
        seed = 2000,
        ml_vars = "{ml_variables}",
        rscript = "Code/trainML.R",
   output:
        model="Data/ml_results/{dataset}/runs/{method}_{seed}_{ml_vars}_model.Rds",
        perf="Data/ml_results/{dataset}/runs/{method}_{seed}_{ml_vars}_performance.csv"
    shell:
        """
        {input.rscript} {input.rds} {input.seed} {input.ml_vars}
        {output.model} {output.perf}
        """


# rule train_ml:
#     input: 
#         rds = "Data/{datasets}_preprocessed.Rds"
#         seed = 
#    output:
#         model="Data/ml_results/{dataset}/runs/{method}_{seed}_{ml_vars}_model.Rds",
#         perf="Data/ml_results/{dataset}/runs/{method}_{seed}_{ml_vars}_performance.csv",
#         # test="Data/ml_results/{dataset}/runs/{method}_{seed}_{ml_vars}_test-data.csv",
#     shell: 
#         """
#         {input.rscript} {input.rds} {input.seed} {input.ml_vars} 
#         {output.model} {output.perf}
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
