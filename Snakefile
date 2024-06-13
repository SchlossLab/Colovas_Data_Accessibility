configfile: "config.yaml"

# start_seed = 2000
# nseeds = config["nseeds"]
# seeds = range(start_seed, start_seed + nseeds)

ncores = config["ncores"]

rule targets:
    input: 
        "Data/groundtruth.new_seq_data.preprocessed.RDS",
        "Data/gt_subset_30.new_seq_data.preprocessed.RDS"
     

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
        "Data/{datasets}.clean_html.csv.gz"
    shell: 
        """
        {input.rscript} {input.html} {output}
        """


rule tokenize: 
    input:
      html = "Data/{datasets}.clean_html.csv.gz",
      rscript = "Code/tokenize.R"
    output: 
        "Data/{datasets}.tokens.csv.gz"
    shell: 
        """
        {input.rscript} {input.html} {output}
        """      

rule ml_prep:
    input:
        tokens = "Data/{datasets}.tokens.csv.gz",
        rscript = "Code/MLprep.R",
        metadata = "Data/{datasets}.csv",
    output: 
        rds = "Data/{datasets}.{ml_variables}.preprocessed.RDS"
    params: 
        threads = ncores
    shell:
        """
        {input.rscript} {input.metadata} {input.tokens} {wildcards.ml_variables} {params.threads} {output.rds}
        """

rule train_ml_set_seed:
    input:
        rds = "Data/{datasets}.{ml_variables}.preprocessed.RDS",
        rscript = "Code/trainML.R",
    output:
        model="Data/ml_results/{dataset}/runs/{method}.{seed}.{ml_variables}.model.RDS",
        perf="Data/ml_results/{dataset}/runs/{method}.{seed}.{ml_variables}.performance.csv"
    params:
        seed = "2000"
    shell:
        """
        {input.rscript} {input.rds} {params.seed} {wildcards.model} {wildcards.ml_variables} {output.model} {output.perf}
        """
#wildcard.model is not mentioned in rule train_ml_set_seed
#Data/ml_results/groundtruth/runs/glmnet_2000_new_seq_data_model.RDS
#{dataset} =groundtruth
#{method} = glmnet
#likely change delimiter in the filenames use period or hyphen instead of underscore (pat likes periods)
#can also get ride of seed = 2000, and use wildcard.seed
#can also get advanced and tell it what kind of variable to be expecting
#will figure out seed from target filename : glmnet_2000_, it will understand the placeholder of the seed
#model output not mentioned in filename either
# inputs: are files, params: are different, params.seed would be a better way to do that 
#

        

rule link_rot: 
    input:
        html = "Data/{datasets}_html.csv.gz",
        rscript = "Code/LinkRot.R",
        metadata = "Data/{datasets}.csv"
    output: 
        all_links = "Data/linkrot/{datasets}_alllinks.csv.gz",
        #unique_links = "Data/linkrot/{datasets}_uniquelinks.csv.gz",
        metadata_links = "Data/linkrot/{datasets}_links_metadata.csv.gz"
    shell:
        """
        {input.rscript}  {input.html} {input.metadata} {output.all_links} {output.metadata_links}
        """
