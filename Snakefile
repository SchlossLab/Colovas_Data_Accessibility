configfile: "config.yaml"

# start_seed = 2000
# nseeds = config["nseeds"]
# seeds = range(start_seed, start_seed + nseeds)

rule targets:
    input: 
      #"Data/ml_results/groundtruth/runs/glmnet_2000_new_seq_data_model.RDS"
      "Data/groundtruth_new_seq_data_preprocessed.RDS"

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
    output: 
        rds = "Data/{datasets}_{ml_variables}_preprocessed.RDS"
    shell:
        """
        {input.rscript} {input.metadata} {input.tokens} {wildcard.ml_variables} {output.rds}
        """

rule train_ml_set_seed:
    input:
        rds = "Data/{datasets}_{ml_variables}_preprocessed.RDS",
        seed = "2000",
        rscript = "Code/trainML.R",
    output:
        model="Data/ml_results/{dataset}/runs/{method}_{seed}_{ml_variables}_model.RDS",
        perf="Data/ml_results/{dataset}/runs/{method}_{seed}_{ml_variables}_performance.csv"
    shell:
        """
        {input.rscript} {input.rds} {input.seed} {wildcard.model} {wildcard.ml_variables} {output.model} {output.perf}
        """


# rule train_ml:
#     input: 
#         rds = "Data/{datasets}_preprocessed.RDS"
#         seed = 
#    output:
#         model="Data/ml_results/{dataset}/runs/{method}_{seed}_{ml_vars}_model.RDS",
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
        all_links = "Data/linkrot/{datasets}_alllinks.csv.gz",
        unique_links = "Data/linkrot/{datasets}_uniquelinks.csv.gz",
        metadata_links = "Data/linkrot/{datasets}_links_metadata.csv.gz"
    shell:
        """
        {input.rscript}  {input.html} {input.metadata} {output.all_links} {output.metadata_links}
        """
