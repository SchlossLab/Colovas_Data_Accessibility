datasets = {
  "groundtruth" : "Data/groundtruth.csv",
  "gt_subset_30" : "Data/gt_subset_30.csv"
}
  
ml_variables = [
  "new_seq_data",
  "availability"
]
  
method = [
  "glmnet",
  "rf",
  "rpart2",
  "xgbTree"
]
  
nseeds = 10
ncores = 1

# start_seed = 2000
# nseeds = config["nseeds"]
# seeds = range(start_seed, start_seed + nseeds)


rule targets:
    input: 
        "Data/groundtruth.new_seq_data.preprocessed.RDS",
        "Data/gt_subset_30.new_seq_data.preprocessed.RDS"
        # "Data/ml_results/gt_subset_30/runs/glmnet.2000.new_seq_data.model.RDS",
        # "Data/ml_results/groundtruth/runs/glmnet.2000.new_seq_data.model.RDS"
        # "Data/linkrot/groundtruth_alllinks.csv.gz"
     

rule webscrape:
    input: 
       csv = "Data/{datasets}.csv",
       rscript = "Code/Webscrape.R"
    output: 
        "Data/{datasets}.html.csv.gz"
    shell: 
        """
        {input.rscript} {input.csv} {output}
        """

        

rule cleanHTML: 
    input:
      html = "Data/{datasets}.html.csv.gz",
      rscript = "Code/cleanHTML.R"
    output: 
        "Data/{datasets}.cleanhtml.csv.gz"
    shell: 
        """
        {input.rscript} {input.html} {output}
        """


rule tokenize: 
    input:
      html = "Data/{datasets}.cleanhtml.csv.gz",
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
    resources: 
        cpus = ncores,
        mem_mb = 200000
    shell:
        """
        {input.rscript} {input.metadata} {input.tokens} {wildcards.ml_variables} {resources.cpus} {output.rds}
        """
# Code/MLprep.R "Data/gt_subset_30.csv" "Data/gt_subset_30.tokens.csv.gz" "new_seq_data" 16 "Data/gt_subset_30.new_seq_data.preprocessed.RDS"
#Code/MLprep.R "Data/groundtruth.csv" "Data/groundtruth.tokens.csv.gz" "new_seq_data" 32 "Data/groundtruth.new_seq_data.preprocessed.RDS"

rule train_ml_set_seed:
    input:
        rds = "Data/{datasets}.{ml_variables}.preprocessed.RDS",
        rscript = "Code/trainML.R",
    output:
        model="Data/ml_results/{datasets}/runs/{method}.{seed}.{ml_variables}.model.RDS",
        perf="Data/ml_results/{datasets}/runs/{method}.{seed}.{ml_variables}.performance.csv"
    params:
        seed = "2000"
    shell:
        """
        {input.rscript} {input.rds} {params.seed} {wildcards.method} {wildcards.ml_variables} {output.model} {output.perf}
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
        
# rule lr_by_journal:
#     input: 
#         all_links = "Data/linkrot/{datasets}_alllinks.csv.gz",
#         metadata_links = "Data/linkrot/{datasets}_links_metadata.csv.gz"
#     output: 
#         filename = "Figures/linkrot/{datasets}/links_byjournal.png"
#     shell: 
#         """
#         {input.rscript} {input.metadata_links} {output.filename}
#         """
      
# rule lr_by_status: 
#    input: 
#         all_links = "Data/linkrot/{datasets}_alllinks.csv.gz",
#         metadata_links = "Data/linkrot/{datasets}_links_metadata.csv.gz"
#     output: 
#         filename = "Figures/linkrot/{datasets}/links_bystatus.png"
#     shell: 
#         """
#         {input.rscript} {input.metadata_links} {output.filename}
#         """

# rule lr_template: 
#    input: 
#         all_links = "Data/linkrot/{datasets}_alllinks.csv.gz",
#         metadata_links = "Data/linkrot/{datasets}_links_metadata.csv.gz"
#     output: 
#         filename = "Figures/linkrot/{datasets}/links_bystatus.png"
#     shell: 
#         """
#         {input.rscript} {input.metadata_links} {output.filename}
#         """
