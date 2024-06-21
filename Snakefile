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
    #     "Data/groundtruth.new_seq_data.preprocessed.RDS",
    #     "Data/gt_subset_30.new_seq_data.preprocessed.RDS", 
    #     "Data/groundtruth.availability.preprocessed.RDS",
    #     "Data/gt_subset_30.availability.preprocessed.RDS"
    #     "Data/ml_results/gt_subset_30/runs/glmnet.2000.new_seq_data.model.RDS",
    #     "Data/ml_results/groundtruth/runs/glmnet.2000.new_seq_data.model.RDS"
    #     "Data/linkrot/groundtruth_alllinks.csv.gz"
        "Figures/linkrot/groundtruth/alllinks_bystatus.png",
        "Figures/linkrot/groundtruth/links_byjournal.png", 
        "Figures/linkrot/groundtruth/links_byyear.png", 
        "Figures/linkrot/groundtruth/links_yearstatus.png", 
        "Figures/linkrot/groundtruth/alllinks_bytype.png"

     

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
        cpus = ncores
        #mem_mb = 200000
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

#Data/ml_results/groundtruth/runs/glmnet_2000_new_seq_data_model.RDS

#-------------------LINK-------ROT-----------------------------------------------------------

rule link_rot: 
    input:
        html = "Data/{datasets}.html.csv.gz",
        rscript = "Code/LinkRot.R",
        metadata = "Data/{datasets}.csv"
    output: 
        all_links = "Data/linkrot/{datasets}.alllinks.csv.gz",
        metadata_links = "Data/linkrot/{datasets}.linksmetadata.csv.gz"
    shell:
        """
        {input.rscript}  {input.html} {input.metadata} {output.all_links} {output.metadata_links}
        """
#can you make a rule all for the figures? 
rule all_lr_figures: 
    input: 
        "Figures/linkrot/{datasets}/links_byjournal.png",
        "Figures/linkrot/{datasets}/alllinks_bystatus.png",
        "Figures/linkrot/{datasets}/links_byyear.png"
        
rule lr_by_journal: 
    input: 
        rscript = "Code/linkrot/links_byjournal.R",
       # all_links = "Data/linkrot/{datasets}.alllinks.csv.gz",
        metadata_links = "Data/linkrot/{datasets}.linksmetadata.csv.gz"
    output:
        filename = "Figures/linkrot/{datasets}/links_byjournal.png"
    shell: 
        """
        {input.rscript} {input.metadata_links} {output.filename}
        """

rule lr_by_status:
    input: 
        rscript = "Code/linkrot/links_bystatus.R",
        all_links = "Data/linkrot/{datasets}.alllinks.csv.gz"
       #metadata_links = "Data/linkrot/{datasets}.linksmetadata.csv.gz"
    output:
        all_filename = "Figures/linkrot/{datasets}/alllinks_bystatus.png",
        unique_filename = "Figures/linkrot/{datasets}/uniquelinks_bystatus.png"
    shell: 
        """
        {input.rscript} {input.all_links} {output.all_filename} {output.unique_filename}
        """

rule lr_by_year: 
    input: 
        rscript = "Code/linkrot/links_byyear.R",
       # all_links = "Data/linkrot/{datasets}.alllinks.csv.gz",
        metadata_links = "Data/linkrot/{datasets}.linksmetadata.csv.gz"
    output:
        filename = "Figures/linkrot/{datasets}/links_byyear.png"
    shell: 
        """
        {input.rscript} {input.metadata_links} {output.filename}
        """

rule lr_year_status:
    input: 
        rscript = "Code/linkrot/links_yearstatus.R",
        all_links = "Data/linkrot/{datasets}.alllinks.csv.gz",
        metadata_links = "Data/linkrot/{datasets}.linksmetadata.csv.gz"
    output: 
        filename = "Figures/linkrot/{datasets}/links_yearstatus.png"
    shell:
        """
        {input.rscript} {input.all_links} {input.metadata_links} {output.filename}
        """

rule lr_by_type:
    input: 
        rscript = "Code/linkrot/links_bytype.R",
        all_links = "Data/linkrot/{datasets}.alllinks.csv.gz"
       #metadata_links = "Data/linkrot/{datasets}.linksmetadata.csv.gz"
    output:
        all_filename = "Figures/linkrot/{datasets}/alllinks_bytype.png",
        unique_filename = "Figures/linkrot/{datasets}/uniquelinks_bytype.png"
    shell: 
        """
        {input.rscript} {input.all_links} {output.all_filename} {output.unique_filename}
        """
