import pandas as pd 

training_datasets = {
    "groundtruth" : "Data/new_groundtruth.csv"
}


new_datasets = {
    "1098-5530" : "Data/1098-5530_metadata.RDS", #jb
    "1935-7885" : "Data/1935-7885_metadata.RDS", #jmbe
    "2150-7511" : "Data/2150-7511_metadata.RDS", #mbio
    "2165-0497" : "Data/2165-0497_metadata.RDS", #mspec
    "2379-5042" : "Data/2379-5042_metadata.RDS", #msph
    "2379-5077" : "Data/2379-5077_metadata.RDS", #msys
    "2576-098X" : "Data/2576-098X_metadata.RDS", #mra
    "0095-1137" : "Data/0095-1137_metadata.RDS", #jcb
    "1098-5336" : "Data/1098-5336_metadata.RDS", #aem
    "1098-5514" : "Data/1098-5514_metadata.RDS", #jv
    "1098-5522" : "Data/1098-5522_metadata.RDS", #i&i
    "1098-6596" : "Data/1098-6596_metadata.RDS", #aac
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

#import list of dois with their url 
dois = pd.read_csv("Data/all_api_dois.csv.gz", header = 0, names = ["url", "doi"], skiprows = 0)
doi_lookup = dict(zip(dois["doi"], dois["url"]))


ncores = 1
seeds = list(range(1, 101))


rule targets:
    input:
        expand("Data/ml_prep/groundtruth.{ml_variables}.zscoretable_filtered.csv", ml_variables = ml_variables)
        # expand("Data/ml_results/groundtruth/rf/{ml_variables}/best/best.rf.{ml_variables}.{seeds}.model.RDS",
        # ml_variables = ml_variables, seeds = 102899)
        # expand("Data/ml_results/groundtruth/rf/{ml_variables}/final/final.rf.{ml_variables}.102899.finalModel.RDS", 
        # ml_variables = ml_variables) 


rule all_papers: 
    input: 
        rscript = "Code/get_all_papers.R",
        papers = expand("Data/papers/{datasets}.csv", datasets = new_datasets)
    output: 
        "Data/papers/all_papers.csv.gz"
    params: 
        paper_dir = "Data/papers"
    shell: 
        """
        {input.rscript} {params.paper_dir} {output} 
        """
        

rule indiv_dois:
    output:
        doi = "Data/html/{doi}.html"
    group:
        "get_doi"
    resources:
        mem_mb = 8000
    params:
        url = lambda wildcards, output: doi_lookup[wildcards.doi]
    shell:
        """
        wget "{params.url}" --save-headers -O "{output.doi}" || echo "Error: Download {params.url} failed"
        """


rule make_predictions: 
    input: 
        rscript = "Code/html_to_prediction.R",
        html = "Data/html/{doi}.html"
    output: 
        predicted = "Data/predicted/{doi}.csv"
    group: 
        "get_html"
    resources: 
        mem_mb = 8
    shell: 
        """
        {input.rscript} "{input.html}" "{output.predicted}"
        """

rule combine_predictions: 
    input: 
        rscript = "Code/combine_predictions.R",
    output: 
        "Data/final/predicted_results.csv.gz"
    resources: 
        mem_mb = 40000
    params: 
        p_dir = "Data/predicted"
    shell: 
        """
        {input.rscript} {params.p_dir} {output}
        """
#20250220 - this rule replaces webscrape, cleanHTML, tokenize
rule train_tokens: 
    input: 
        rscript = "Code/train_html_tokens.R",
        metadata = "Data/new_groundtruth_metadata.csv.gz"
    output: 
        "Data/groundtruth/{datasets}.tokens.csv.gz"
    resources: 
        mem_mb = 40000
    shell: 
        """
        {input.rscript} {input.metadata} {output}
        """   


rule ml_prep_train:
    input:
        rscript = "Code/ml_preprocess.R",
        tokens = "Data/groundtruth/groundtruth.tokens.csv.gz",
        metadata = "Data/new_groundtruth.csv",
    output: 
        rds = "Data/preprocessed/groundtruth.{ml_variables}.preprocessed.RDS",
        ztable = "Data/ml_prep/groundtruth.{ml_variables}.zscoretable.csv.gz",
        tokenlist = "Data/ml_prep/groundtruth.{ml_variables}.tokenlist.RDS", 
        containerlist = "Data/ml_prep/groundtruth.{ml_variables}.container_titles.csv"
    shell:
        """
        {input.rscript} {input.metadata} {input.tokens} {wildcards.ml_variables} {output.rds} {output.ztable} {output.tokenlist} {output.containerlist}
        """


rule ztable: 
    input: 
        rscript = "Code/ztable_prep.R",
        ztable = "Data/ml_prep/groundtruth.{ml_variables}.zscoretable.csv.gz", 
        tokenlist = "Data/ml_prep/groundtruth.{ml_variables}.tokenlist.RDS", 
        containerlist = "Data/ml_prep/groundtruth.{ml_variables}.container_titles.csv"
    output: 
        ztable = "Data/ml_prep/groundtruth.{ml_variables}.zscoretable_filtered.csv", 
        tokens = "Data/ml_prep/groundtruth.{ml_variables}.tokens_to_collapse.csv"
    shell: 
        """
        {input.rscript} {input.ztable} {input.tokenlist} {input.containerlist} {output.ztable} {output.tokens}
        """


rule rf: 
    input:
        rscript = "Code/trainML_rf.R",
        rds = "Data/preprocessed/groundtruth.{ml_variables}.preprocessed.RDS", 
        rdir = "Data/ml_results/groundtruth/rf/{ml_variables}"
    output:
        "Data/ml_results/groundtruth/rf/{ml_variables}/rf.{ml_variables}.{seeds}.model.RDS", 
        "Data/ml_results/groundtruth/rf/{ml_variables}/rf.{ml_variables}.{seeds}.performance.csv", 
        "Data/ml_results/groundtruth/rf/{ml_variables}/rf.{ml_variables}.{seeds}.hp_performance.csv"
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
        rds = "Data/preprocessed/groundtruth.{ml_variables}.preprocessed.RDS", 
        rscript = "Code/trainML_rf_bestmtry.R",
        rdir = "Data/ml_results/groundtruth/rf/{ml_variables}"
    output:
        "Data/ml_results/groundtruth/rf/{ml_variables}/best/best.rf.{ml_variables}.102899.model.RDS", 
        "Data/ml_results/groundtruth/rf/{ml_variables}/best/best.rf.{ml_variables}.102899.bestTune.csv", 
        "Data/ml_results/groundtruth/rf/{ml_variables}/best/best.rf.{ml_variables}.102899.hp_performance.csv" 
    resources: 
        mem_mb = 40000 
    shell:
        """
        {input.rscript} {input.rds} {wildcards.ml_variables} {input.rdir}
        """

rule final_model: 
    input:
        rds = "Data/preprocessed/groundtruth.{ml_variables}.preprocessed.RDS", 
        rscript = "Code/trainML_rf_finalmodel.R",
        rdir = "Data/ml_results/groundtruth/rf/{ml_variables}"
    output:
        "Data/ml_results/groundtruth/rf/{ml_variables}/final/final.rf.{ml_variables}.102899.finalModel.RDS",
        "Data/ml_results/groundtruth/rf/{ml_variables}/final/final.rf.{ml_variables}.102899.model.RDS"
    params: 
        mtry_value = lambda wildcards : mtry_dict[wildcards.ml_variables]
    resources: 
        mem_mb = 20000 
    shell:
        """
        {input.rscript} {input.rds} {wildcards.ml_variables} {params.mtry_value} {input.rdir}
        """

#20250310- i think html_to_prediction replaces this rule
# rule ml_prep_predict:
#     input:
#         rscript = "Code/ml_prep_predict.R",
#         tokens = "Data/tokens/{datasets}.tokens.csv.gz",
#         metadata = "Data/doi_linkrot/alive/{datasets}.csv",
#         ztable = "Data/ml_prep/groundtruth.{ml_variables}.zscoretable.csv.gz", 
#         tokenlist = "Data/ml_prep/groundtruth.{ml_variables}.tokenlist.RDS", 
#         containerlist = "Data/ml_prep/groundtruth.{ml_variables}.container_titles.RDS"
#     output: 
#         rds = "Data/preprocessed/{datasets}.{ml_variables}.preprocessed_predict.RDS"
#     resources: 
#         mem_mb = 40000 
#     shell:
#         """
#         {input.rscript} {input.metadata} {input.tokens} {input.ztable} {input.tokenlist} {input.containerlist} {output.rds}
#         """


rule predict: 
    input: 
        rscript = "Code/predict.R",
        da = "Data/preprocessed/{datasets}.data_availability.preprocessed_predict.RDS",
        nsd = "Data/preprocessed/{datasets}.new_seq_data.preprocessed_predict.RDS", 
        metadata = "Data/doi_linkrot/alive/{datasets}.csv"
    output: 
        "Data/predicted/{datasets}.data_predicted.RDS"
    shell: 
        """
        {input.rscript} {input.da} {input.nsd} {input.metadata} {output}
        """



###---------------geting dois from multiple apis---------------------------------

rule scopus: 
    input: 
        rscript = "Code/doi_gathering_scopus_via_httr.R"
    output: 
        "Data/scopus/scopus_{datasets}.csv.gz"
    shell: 
        """
        {input.rscript} {wildcards.datasets} 
        """

rule wos: 
    input: 
        rscript = "Code/doi_gathering_wos_via_httr.R"
    output: 
        "Data/wos/wos_{datasets}.csv.gz"
    group: 
        "wos"
    shell: 
        """
        {input.rscript} {wildcards.datasets} 
        """


rule ncbi: 
    output: 
        "Data/ncbi/ncbi_{datasets}.csv.gz"
    shell: 
        """
        esearch -db pubmed -query "{wildcards.datasets}" | efetch -format csv > "{output}"
        """

rule crossref: 
    input: 
        rscript = "Code/doi_gathering_crossref.R"
    output: 
        "Data/crossref/crossref_{datasets}.csv.gz"
    group:
        "crossref"
    shell: 
        """
        {input.rscript} {wildcards.datasets} 
        """

#-------------------LINK-------ROT-----------------------------------------------------------
# 20241024 - will need to double check filenames here 

rule link_rot: 
    input:
        rscript = "Code/LinkRot.R"
    output: 
        "Data/linkrot/all_links.csv.gz"
    params: 
        html_dir = "Data/html"
    resources: 
        mem_mb = 40000
    shell:
        """
        {input.rscript} {params.html_dir} {output}
        """
        
# 20241001 - i think a lot of these have roughly identical code
# could combine into one file and just tell it what kind of variables 
# to graph, have to look at figures again and remove non-useful figs  

rule lr_by_journal: 
    input: 
        rscript = "Code/linkrot/links_byjournal.R",
        all_links = "Data/linkrot/{datasets}/{datasets}.alllinks.csv.gz",
        metadata_links = "Data/linkrot/{datasets}/{datasets}.linksmetadata.csv.gz"
    output:
        filename = "Figures/linkrot/{datasets}/links_byjournal.png"
    shell: 
        """
        {input.rscript} {input.all_links} {input.metadata_links} {output.filename}
        """

rule lr_by_year: 
    input: 
        rscript = "Code/linkrot/links_byyear.R",
        # all_links = "Data/linkrot/{datasets}/{datasets}.alllinks.csv.gz",
        metadata_links = "Data/linkrot/{datasets}/{datasets}.linksmetadata.csv.gz"
    output:
        filename = "Figures/linkrot/{datasets}/links_byyear.png"
    shell: 
        """
        {input.rscript} {input.metadata_links} {output.filename}
        """

rule lr_year_status:
    input: 
        rscript = "Code/linkrot/links_yearstatus.R",
        all_links = "Data/linkrot/{datasets}/{datasets}.alllinks.csv.gz",
        metadata_links = "Data/linkrot/{datasets}/{datasets}.linksmetadata.csv.gz"
    output: 
        filename = "Figures/linkrot/{datasets}/links_yearstatus.png"
    shell:
        """
        {input.rscript} {input.all_links} {input.metadata_links} {output.filename}
        """

rule lr_by_type:
    input: 
        rscript = "Code/linkrot/links_bytype.R",
        all_links = "Data/linkrot/{datasets}/{datasets}.alllinks.csv.gz"
        # metadata_links = "Data/linkrot/{datasets}/{datasets}.linksmetadata.csv.gz"
    output:
        unique_filename = "Figures/linkrot/{datasets}/uniquelinks_bytype.png"
    shell: 
        """
        {input.rscript} {input.all_links} {output.unique_filename}
        """

rule lr_by_hostname:
    input: 
        rscript = "Code/linkrot/links_byhostname.R",
        all_links = "Data/linkrot/{datasets}/{datasets}.alllinks.csv.gz"
        # metadata_links = "Data/linkrot/{datasets}/{datasets}.linksmetadata.csv.gz"
    output:
        filename = "Figures/linkrot/{datasets}/longlasting_byhostname.png"
    shell: 
        """
        {input.rscript} {input.all_links} {output.filename}
        """

rule lr_error_hostname: 
    input: 
        rscript = "Code/linkrot/links_errorhostname.R",
        all_links = "Data/linkrot/{datasets}/{datasets}.alllinks.csv.gz"
        # metadata_links = "Data/linkrot/{datasets}/{datasets}.linksmetadata.csv.gz"
    output:
        filename = "Figures/linkrot/{datasets}/links_errorhostname.png"
    shell: 
        """
        {input.rscript} {input.all_links} {output.filename}
        """