#Data Directory README.md

## Files from Adena Collens (AC):
    - ac_papers_tocheck.csv
    - seq_papers_bib_1300.csv
    
## Files generated from AC data and used in this project:
    - groundtruth.csv 
        - N=500 ASM papers and associated metadata
        - hand-assigned for two variables (new_seq_data, availability)
        - ML training set
    - add_to500.csv
        - papers to add to groundtruth.csv to maintain training set of N=500 papers
        - randomly pulled from seq_papers_bib_1300.csv
        
## Files generated in this project:
    - subset *.csv files of groundtruth.csv
        - gt_subset_30.csv > small practice dataset of 30 papers
        - gt_availability_no.csv > N = 316 papers without data available
        - gt_availability_yes.csv > N = 184 papers with data available
        - gt_newseq_no.csv > N = 301 papers not containing new sequencing data 
        - gt_newseq_yes.csv > N = 199 papers containing new sequencing data
        
    - *.json files storing scraped text and tidytext tibbles
        - groundtruth.json
        - gt_subset_30.json 
        - gt_availability_no.json 
        - gt_availability_yes.json
        - gt_newseq_no.json 
        - gt_newseq_yes.json
        
    - linkrot *.csv files
        - groundtruth_linkcount.csv
        - groundtruth_links.csv
    
    
  
