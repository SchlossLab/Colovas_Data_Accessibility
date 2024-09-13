datasets = {
  "groundtruth" : "Data/groundtruth.csv",
  "gt_subset_30" : "Data/gt_subset_30.csv"
}
  
ml_variables = [
  "new_seq_data",
  "data_availability"
]
  
method = [
  "glmnet",
  "rf",
  #"rpart2",
  "xgbTree"
]

# mtry_values = {
#     "new_seq_data" = 300, 
#     "data_availability" = 200
# }

mtry_dict = {
    "new_seq_data" : 300, 
    "data_availability" : 200
}
  

ncores = 1
seeds = list(range(1, 101))


rule targets:
    input:
        expand("Data/ml_results/groundtruth/rf/{ml_variables}/final/final.rf.{ml_variables}.102899.finalModel.RDS",
        ml_variables = ml_variables)


        # # all ml results  
        # # figures 
        # "Figures/linkrot/groundtruth/alllinks_bystatus.png",
        # "Figures/linkrot/groundtruth/links_byjournal.png", 
        # "Figures/linkrot/groundtruth/links_byyear.png", 
        # "Figures/linkrot/groundtruth/links_yearstatus.png", 
        # "Figures/linkrot/groundtruth/alllinks_bytype.png", 
        # "Figures/linkrot/groundtruth/alllinks_byhostname.png",
        # "Figures/linkrot/groundtruth/links_errorhostname.png"

     

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

# rule train_ml:
#     input:
#         rds = "Data/{datasets}.{ml_variables}.preprocessed.RDS", 
#         rscript = "Code/trainML.R",
#     output:
#         model="Data/ml_results/{datasets}/{method}/{method}.{seeds}.{ml_variables}.model.RDS", 
#         perf="Data/ml_results/{datasets}/{method}/{method}.{seeds}.{ml_variables}.performance.csv", 
#         #"Data/ml_results/gt_subset_30/glmnet/glmnet.10.new_seq_data.model.RDS"
#     # params:
#     #     seeds = seeds
#     shell:
#         """
#         {input.rscript} {input.rds} {wildcards.seeds} {wildcards.method} {wildcards.ml_variables} {output.model} {output.perf}
#         """

# rule glmnet: 
#     input:
#         rds = "Data/{datasets}.{ml_variables}.preprocessed.RDS", 
#         rscript = "Code/trainML_glmnet.R",
#     output:
#         model="Data/ml_results/{datasets}/glmnet/glmnet.{seeds}.{ml_variables}.model.RDS", 
#         perf="Data/ml_results/{datasets}/glmnet/glmnet.{seeds}.{ml_variables}.performance.csv", 
#     shell:
#         """
#         {input.rscript} {input.rds} {wildcards.seeds} {wildcards.ml_variables} {output.model} {output.perf}
#         """

rule rf: 
    input:
        rds = "Data/{datasets}.{ml_variables}.preprocessed.RDS", 
        rscript = "Code/trainML_rf.R",
        rdir = "Data/ml_results/{datasets}/rf/{ml_variables}"
    output:
        "Data/ml_results/{datasets}/rf/{ml_variables}/rf.{ml_variables}.{seeds}.model.RDS", 
        "Data/ml_results/{datasets}/rf/{ml_variables}/rf.{ml_variables}.{seeds}.performance.csv", 
        "Data/ml_results/{datasets}/rf/{ml_variables}/rf.{ml_variables}.{seeds}.hp_performance.csv"
        #"Data/ml_results/{datasets}/rf/rf.{seeds}.{ml_variables}.prediction.csv", 
    shell:
        """
        {input.rscript} {input.rds} {wildcards.seeds} {wildcards.ml_variables} {input.rdir}
        """

# rule xgbTree: 
#     input:
#         rds = "Data/{datasets}.{ml_variables}.preprocessed.RDS", 
#         rscript = "Code/trainML_xgbTree.R",
#     output:
#         model="Data/ml_results/{datasets}/xgbTree/xgbTree.{seeds}.{ml_variables}.model.RDS", 
#         perf="Data/ml_results/{datasets}/xgbTree/xgbTree.{seeds}.{ml_variables}.performance.csv", 
#     resources: 
#         mem_mb = 20000
#     shell:
#         """
#         {input.rscript} {input.rds} {wildcards.seeds} {wildcards.ml_variables} {output.model} {output.perf}
#         """


rule merge_results_figs: 
    input: 
        rscript = "Code/combine_models.R",
        filepath = "Data/ml_results/{datasets}/{method}/{ml_variables}"
    output: 
        "Figures/ml_results/{datasets}/{method}/hp_perf.{method}.{ml_variables}.png"
    resources: 
        mem_mb = 20000 
    shell: 
        """
        {input.rscript} {input.filepath} {wildcards.method} {wildcards.ml_variables} {output}
        """
    
rule auroc: 
    input: 
        rscript = "Code/auroc_fig.R",
        filepath = "Data/ml_results/{datasets}/{method}/{ml_variables}"
    output: 
        "Figures/ml_results/{datasets}/{method}/auroc.{ml_variables}.png"
    resources: 
        mem_mb = 20000 
    shell: 
        """
        {input.rscript} {input.filepath} {wildcards.method} {wildcards.ml_variables} {output}
        """

#   "Data/ml_results/groundtruth/rf/data_availability/best.rf.data_availability.44.bestTune.csv",
#         "Data/ml_results/groundtruth/rf/data_availability/best.rf.data_availability.44.model.RDS",
#         "Data/ml_results/groundtruth/rf/new_seq_data/best.rf.new_seq_data.49.bestTune.csv", 
#         "Data/ml_results/groundtruth/rf/new_seq_data/best.rf.new_seq_data.49.model.RDS"

rule best_mtry: 
    input:
        rds = "Data/{datasets}.{ml_variables}.preprocessed.RDS", 
        rscript = "Code/trainML_rf_bestmtry.R",
        rdir = "Data/ml_results/{datasets}/rf/{ml_variables}"
    output:
        "Data/ml_results/{datasets}/rf/{ml_variables}/best/best.rf.{ml_variables}.{seeds}.model.RDS", 
        "Data/ml_results/{datasets}/rf/{ml_variables}/best/best.rf.{ml_variables}.{seeds}.bestTune.csv", 
        "Data/ml_results/{datasets}/rf/{ml_variables}/best/best.rf.{ml_variables}.{seeds}.hp_performance.csv" 
    shell:
        """
        {input.rscript} {input.rds} {wildcards.ml_variables} {input.rdir}
        """

## 20240911 - needs way to make sure ml_variables correspond to mtry values

rule final_model: 
    input:
        rds = "Data/{datasets}.{ml_variables}.preprocessed.RDS", 
        rscript = "Code/trainML_rf_finalmodel.R",
        rdir = "Data/ml_results/{datasets}/rf/{ml_variables}"
    output:
        "Data/ml_results/{datasets}/rf/{ml_variables}/final/final.rf.{ml_variables}.{seeds}.finalModel.csv",
        "Data/ml_results/{datasets}/rf/{ml_variables}/final/final.rf.{ml_variables}.{seeds}.finalModel.RDS",
        "Data/ml_results/{datasets}/rf/{ml_variables}/final/final.rf.{ml_variables}.{seeds}.model.RDS"
    params: 
        mtry_value = lambda wildcards : mtry_dict[wildcards.ml_variables]
    shell:
        """
        {input.rscript} {input.rds} {wildcards.ml_variables} {params.mtry_value} {input.rdir}
        """
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

rule lr_by_hostname:
    input: 
        rscript = "Code/linkrot/links_byhostname.R",
        all_links = "Data/linkrot/{datasets}.alllinks.csv.gz"
       #metadata_links = "Data/linkrot/{datasets}.linksmetadata.csv.gz"
    output:
        all_filename = "Figures/linkrot/{datasets}/alllinks_byhostname.png",
        unique_filename = "Figures/linkrot/{datasets}/uniquelinks_byhostname.png"
    shell: 
        """
        {input.rscript} {input.all_links} {output.all_filename} {output.unique_filename}
        """

rule lr_error_hostname: 
    input: 
        rscript = "Code/linkrot/links_errorhostname.R",
        all_links = "Data/linkrot/{datasets}.alllinks.csv.gz",
       # metadata_links = "Data/linkrot/{datasets}.linksmetadata.csv.gz"
    output:
        filename = "Figures/linkrot/{datasets}/links_errorhostname.png"
    shell: 
        """
        {input.rscript} {input.all_links} {output.filename}
        """