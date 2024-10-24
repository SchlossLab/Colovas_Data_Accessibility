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


rule targets:
    input:
        # "Data/webscrape/1935-7885.html.csv.gz"
        expand("Data/doi_linkrot/alive/{datasets}.csv",
        datasets = new_datasets), 
        #20241024 - need to do jmbe and mra next
        "Data/predicted/1935-7885.data_predicted.csv",
        "Data/predicted/2576-098X.data_predicted.csv"
        # "Data/doi_linkrot/alive/1935-7885.csv",
        # "Data/tokens/1935-7885.tokens.csv.gz"
        # expand("Data/2576-098X.alive.{ml_variables}.preprocessed_predict.RDS", 
        # ml_variables = ml_variables),
        # "Data/predicted/2576-098X.alive.data_predicted.csv",
        # "Data/predicted/1935-7885.alive.data_predicted.csv"

    

        
rule rds_to_csv: 
    input: 
        rscript = "Code/rds_to_csv.R",
        rds = "Data/metadata/{datasets}_metadata.RDS"
    output: 
        "Data/papers/{datasets}.csv"
    shell: 
        """
        {input.rscript} {input.rds} {output}
        """

rule doi_linkrot: 
    input: 
        rscript = "Code/doi_linkrot.R",
        csv = "Data/papers/{datasets}.csv"
    output:
        "Data/doi_linkrot/alive/{datasets}.csv",
        "Data/doi_linkrot/dead/{datasets}.csv"
    params: 
        filepath = "Data/doi_linkrot"
    shell: 
        """
        {input.rscript} {input.csv} {params.filepath} {wildcards.datasets}
        """

rule webscrape:
    input: 
        rscript = "Code/Webscrape.R",
        csv = "Data/doi_linkrot/alive/{datasets}.csv"
    output: 
        "Data/webscrape/{datasets}.html.csv.gz"
    shell: 
        """
        {input.rscript} {input.csv} {output}
        """


rule cleanHTML: 
    input:
        rscript = "Code/cleanHTML.R",
        html = "Data/webscrape/{datasets}.html.csv.gz"
    output: 
        "Data/cleanhmtl/{datasets}.cleanhtml.csv.gz"
    shell: 
        """
        {input.rscript} {input.html} {output}
        """


rule tokenize: 
    input:
        rscript = "Code/tokenize.R",
        html = "Data/cleanhmtl/{datasets}.cleanhtml.csv.gz"
    output: 
        "Data/tokens/{datasets}.tokens.csv.gz"
    shell: 
        """
        {input.rscript} {input.html} {output}
        """      


rule ml_prep_train:
    input:
        rscript = "Code/ml_preprocess.R",
        tokens = "Data/tokens/{datasets}.tokens.csv.gz",
        metadata = "Data/doi_linkrot/alive/{datasets}.csv",
    output: 
        rds = "Data/preprocessed/{datasets}.{ml_variables}.preprocessed.RDS",
        ztable = "Data/ml_prep/{datasets}.{ml_variables}.zscoretable.csv", 
        tokenlist = "Data/ml_prep/{datasets}.{ml_variables}.tokenlist.RDS", 
        containerlist = "Data/ml_prep/{datasets}.{ml_variables}.container_titles.RDS"
    shell:
        """
        {input.rscript} {input.metadata} {input.tokens} {wildcards.ml_variables} {output.rds} {output.ztable} {output.tokenlist} {output.containerlist}
        """

rule ztable: 
    input: 
        rscript = "Code/ztable_prep.R",
        ztable = "Data/ml_prep/groundtruth.{ml_variables}.zscoretable.csv", 
        tokenlist = "Data/ml_prep/groundtruth.{ml_variables}.tokenlist.RDS", 
        containerlist = "Data/ml_prep/groundtruth.{ml_variables}.container_titles.RDS"
    output: 
        "Data/ml_prep/{datasets}.{ml_variables}.zscoretable_filtered.csv"
    shell: 
        """
        {input.rscript} {input.ztable} {input.tokenlist} {input.containerlist} {output}
        """


rule ml_prep_predict:
    input:
        rscript = "Code/ml_prep_predict.R",
        tokens = "Data/tokens/{datasets}.tokens.csv.gz",
        metadata = "Data/doi_linkrot/alive/{datasets}.csv",
        ztable = "Data/ml_prep/groundtruth.{ml_variables}.zscoretable_filtered.csv", 
        tokenlist = "Data/ml_prep/groundtruth.{ml_variables}.tokenlist.RDS", 
        containerlist = "Data/ml_prep/groundtruth.{ml_variables}.container_titles.RDS"
    output: 
        rds = "Data/preprocessed/{datasets}.{ml_variables}.preprocessed_predict.RDS"
    shell:
        """
        {input.rscript} {input.metadata} {input.tokens} {input.ztable} {input.tokenlist} {input.containerlist} {output.rds}
        """


rule predict: 
    input: 
        rscript = "Code/predict.R",
        da = "Data/preprocessed/{datasets}.data_availability.preprocessed_predict.RDS",
        nsd = "Data/preprocessed/{datasets}.new_seq_data.preprocessed_predict.RDS", 
        metadata = "Data/doi_linkrot/alive/{datasets}.csv"
    output: 
        "Data/predicted/{datasets}.data_predicted.csv"
    shell: 
        """
        {input.rscript} {input.da} {input.nsd} {input.metadata} {output}
        """

rule rf: 
    input:
        rscript = "Code/trainML_rf.R",
        rds = "Data/preprocessed/{datasets}.{ml_variables}.preprocessed_predict.RDS", 
        rdir = "Data/ml_results/{datasets}/rf/{ml_variables}"
    output:
        "Data/ml_results/{datasets}/rf/{ml_variables}/rf.{ml_variables}.{seeds}.model.RDS", 
        "Data/ml_results/{datasets}/rf/{ml_variables}/rf.{ml_variables}.{seeds}.performance.csv", 
        "Data/ml_results/{datasets}/rf/{ml_variables}/rf.{ml_variables}.{seeds}.hp_performance.csv"
    resources: 
        mem_mb = 20000 
    shell:
        """
        {input.rscript} {input.rds} {wildcards.seeds} {wildcards.ml_variables} {input.rdir}
        """


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
    resources: 
        mem_mb = 20000 
    shell:
        """
        {input.rscript} {input.rds} {wildcards.ml_variables} {input.rdir}
        """

rule final_model: 
    input:
        rds = "Data/preprocessed/{datasets}.{ml_variables}.preprocessed.RDS", 
        rscript = "Code/trainML_rf_finalmodel.R",
        rdir = "Data/ml_results/{datasets}/rf/{ml_variables}"
    output:
        "Data/ml_results/{datasets}/rf/{ml_variables}/final/final.rf.{ml_variables}.{seeds}.finalModel.RDS",
        "Data/ml_results/{datasets}/rf/{ml_variables}/final/final.rf.{ml_variables}.{seeds}.model.RDS"
    params: 
        mtry_value = lambda wildcards : mtry_dict[wildcards.ml_variables]
    resources: 
        mem_mb = 20000 
    shell:
        """
        {input.rscript} {input.rds} {wildcards.ml_variables} {params.mtry_value} {input.rdir}
        """




#-------------------LINK-------ROT-----------------------------------------------------------
#20241024 - will need to double check filenames here 
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