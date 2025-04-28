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
        
## 20250402 - new_groundtruth criteria for paper selection
    - Must have metadata from crossref
    - new_seq_data(nsd) = "Is this paper about new sequencing data that has been generated?"
    - data_availability(da) = "Did this paper make sequencing data available online such as in NCBI, SRA, EMBL, etc?" 
    - A paper must be new_seq_data == "Yes" to have data_availability == "Yes". 
    - Papers cannot have nsd= No, da = Yes.
    - Papers that use sequencing as a confirmation of experimental technique are nsd = No, da = No
    - Papers that are about new computational or experimental tools (i.e. mothur) are nsd = No, da = No
    - Papers using microarray data are nsd = No, da = No
    - Papers using MLST are not in and of themselves sequencing papers and are nsd = No, da = No
    - Papers using qPCR only also are nsd = No, da = No 
    - Papers about protein sequencing; 
        - if they have actual nucleotide sequencing data are nsd = Yes, da = Yes if uploaded to a database
        - if they are only about protein structure, nsd = No, da = No, even if they have data uploaded, see above.
    - iRNA and pyrosequencing are nsd = No
    
  
