training_datasets = {
    "groundtruth" : "Data/groundtruth.csv",
    "gt_subset_30" : "Data/gt_subset_30.csv",
}

# practice_datasets = { 
#     "1935-7885_alive" : "Data/1935-7885.csv", 
#     "1098-5530_small" : "Data/1098-5530_small.csv",
# }

new_datasets = {
    "0095-1137" : "Data/0095-1137_metadata.RDS", #jcb
    "1098-5336" : "Data/1098-5336_metadata.RDS", #aem
    "1098-5514" : "Data/1098-5514_metadata.RDS", #jv
    "1098-5522" : "Data/1098-5522_metadata.RDS", #i&i
    "1098-5530" : "Data/1098-5530_metadata.RDS", #jb
    "1098-6596" : "Data/1098-6596_metadata.RDS", #aac
    "1935-7885" : "Data/1935-7885_metadata.RDS", #jmbe
    "2150-7511" : "Data/2150-7511_metadata.RDS", #mbio
    "2165-0497" : "Data/2165-0497_metadata.RDS", #mspec
    "2379-5042" : "Data/2379-5042_metadata.RDS", #msph
    "2379-5077" : "Data/2379-5077_metadata.RDS", #msys
    "2576-098X" : "Data/2576-098X_metadata.RDS" #mra
}

alive_datasets = {
    "0095-1137_alive" : "Data/0095-1137_metadata.RDS", #jcb
    "1098-5336_alive" : "Data/1098-5336_metadata.RDS", #aem
    "1098-5514_alive" : "Data/1098-5514_metadata.RDS", #jv
    "1098-5522_alive" : "Data/1098-5522_metadata.RDS", #i&i
    "1098-5530_alive" : "Data/1098-5530_metadata.RDS", #jb
    "1098-6596_alive" : "Data/1098-6596_metadata.RDS", #aac
    "1935-7885_alive" : "Data/1935-7885_metadata.RDS", #jmbe
    "2150-7511_alive" : "Data/2150-7511_metadata.RDS", #mbio
    "2165-0497_alive" : "Data/2165-0497_metadata.RDS", #mspec
    "2379-5042_alive" : "Data/2379-5042_metadata.RDS", #msph
    "2379-5077_alive" : "Data/2379-5077_metadata.RDS", #msys
    "2576-098X_alive" : "Data/2576-098X_metadata.RDS" #mra

}

  
ml_variables = [
  "new_seq_data",
  "data_availability"
]
  
method = [
  "glmnet",
  "rf",
  "xgbTree"
]


mtry_dict = {
    "new_seq_data" : 300, 
    "data_availability" : 200
}
  

ncores = 1
seeds = list(range(1, 101))

ruleorder: ml_prep_predict > ml_prep_train

rule targets:
    input:
        # expand("Data/groundtruth.{ml_variables}.zscoretable_filtered.csv", 
        #  ml_variables = ml_variables)
        expand("Data/1935-7885_alive.{ml_variables}.preprocessed_predict.RDS", 
        ml_variables = ml_variables)
        # expand("Data/groundtruth.{ml_variables}.preprocessed.RDS", 
        # ml_variables = ml_variables)
        # "Data/1935-7885_alive.tokens.csv.gz"
        #expand("Data/papers/{datasets}.csv", datasets = datasets),
       # expand("Data/doi_linkrot/{datasets}.alive.csv", datasets = datasets)
        # "Data/{datasets}.{ml_variables}.preprocessed.RDS"
    

        # "Data/1935-7885_alive.html.csv.gz"
        # expand("Data/1935-7885.{ml_variables}.preprocessed.RDS", 
        # ml_variables = ml_variables), 
        # "Data/linkrot/1935-7885.alllinks.csv.gz"

        
rule rds_to_csv: 
    input: 
        rds = "Data/{datasets}_metadata.RDS",
        rscript = "Code/rds_to_csv.R"
    output: 
        "Data/papers/{datasets}.csv"
    shell: 
        """
        {input.rscript} {input.rds} {output}
        """

rule doi_linkrot: 
    input: 
        csv = "Data/papers/{datasets}.csv", 
        rscript = "Code/doi_linkrot.R"
    output:
        "Data/doi_linkrot/{datasets}.alive.csv",
        "Data/doi_linkrot/{datasets}.dead.csv"
    params: 
        filepath = "Data/doi_linkrot/{datasets}"
    shell: 
        """
        {input.rscript} {input.csv} {params.filepath}
        """

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

# 20240923 don't need a ruleorder statement because the pre-processed data 
# has no ml_var in fileneame

ruleorder: ml_prep_predict > ml_prep_train

# 20241001 - add new filename and add ztable 
# saving out to the train
rule ml_prep_train:
    input:
        tokens = "Data/{datasets}.tokens.csv.gz",
        rscript = "Code/ml_preprocess.R",
        metadata = "Data/{datasets}.csv",
    output: 
        rds = "Data/{datasets}.{ml_variables}.preprocessed.RDS",
        ztable = "Data/{datasets}.{ml_variables}.zscoretable.csv", 
        tokenlist = "Data/{datasets}.{ml_variables}.tokenlist.RDS", 
        containerlist = "Data/{datasets}.{ml_variables}.container_titles.RDS"
    shell:
        """
        {input.rscript} {input.metadata} {input.tokens} {wildcards.ml_variables} {output.rds} {output.ztable} {output.tokenlist} {output.containerlist}
        """

rule ztable: 
    input: 
        rscript = "Code/ztable_prep.R",
        ztable = "Data/groundtruth.{ml_variables}.zscoretable.csv", 
        tokenlist = "Data/groundtruth.{ml_variables}.tokenlist.RDS", 
        containerlist = "Data/groundtruth.{ml_variables}.container_titles.RDS"
    output: 
        "Data/{datasets}.{ml_variables}.zscoretable_filtered.csv"
    shell: 
        """
        {input.rscript} {input.ztable} {input.tokenlist} {input.containerlist} {output}
        """

rule ml_prep_predict:
    input:
        tokens = "Data/{datasets}.tokens.csv.gz",
        rscript = "Code/ml_prep_predict.R",
        metadata = "Data/{datasets}.csv",
        ztable = "Data/groundtruth.{ml_variables}.zscoretable_filtered.csv", 
        tokenlist = "Data/groundtruth.{ml_variables}.tokenlist.RDS", 
        containerlist = "Data/groundtruth.{ml_variables}.container_titles.RDS"
    output: 
        rds = "Data/{datasets}.{ml_variables}.preprocessed_predict.RDS"
    shell:
        """
        {input.rscript} {input.metadata} {input.tokens} {input.ztable} {input.tokenlist} {input.containerlist} {output.rds}
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
        "Data/ml_results/{datasets}/rf/{ml_variables}/final/final.rf.{ml_variables}.{seeds}.finalModel.RDS",
        "Data/ml_results/{datasets}/rf/{ml_variables}/final/final.rf.{ml_variables}.{seeds}.model.RDS"
    params: 
        mtry_value = lambda wildcards : mtry_dict[wildcards.ml_variables]
    shell:
        """
        {input.rscript} {input.rds} {wildcards.ml_variables} {params.mtry_value} {input.rdir}
        """
#-------------------LINK-------ROT-----------------------------------------------------------

# 20241001 - need to add unique to linkrot in saving the, 
# reason to have links and metadata separate 
# links is all links and then you'd have redundant metadata for papers
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
        
# 20241001 - i think a lot of these have roughly identical code
# could combine into one file and just tell it what kind of variables 
# to graph, have to look at figures again and remove non-useful figs  

rule lr_by_journal: 
    input: 
        rscript = "Code/linkrot/links_byjournal.R",
        all_links = "Data/linkrot/{datasets}.alllinks.csv.gz",
        metadata_links = "Data/linkrot/{datasets}.linksmetadata.csv.gz"
    output:
        filename = "Figures/linkrot/{datasets}/links_byjournal.png"
    shell: 
        """
        {input.rscript} {input.all_links} {input.metadata_links} {output.filename}
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
        unique_filename = "Figures/linkrot/{datasets}/uniquelinks_bytype.png"
    shell: 
        """
        {input.rscript} {input.all_links} {output.unique_filename}
        """

rule lr_by_hostname:
    input: 
        rscript = "Code/linkrot/links_byhostname.R",
        all_links = "Data/linkrot/{datasets}.alllinks.csv.gz"
       #metadata_links = "Data/linkrot/{datasets}.linksmetadata.csv.gz"
    output:
        filename = "Figures/linkrot/{datasets}/longlasting_byhostname.png"
    shell: 
        """
        {input.rscript} {input.all_links} {output.filename}
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