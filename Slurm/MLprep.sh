#!/bin/bash

##################
####  Slurm preamble

#### #### ####  These are the most frequently changing options

####  Job name
#SBATCH --job-name=mlprep

####  Request resources here
####    These are typically, number of processors, amount of memory,
####    an the amount of time a job requires.  May include processor
####    type, too.

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8g
#SBATCH --time=100:00:00

 

####  Slurm account and partition specification here
####    These will change if you work on multiple projects, or need
####    special hardware, like large memory nodes or GPUs.

#SBATCH --account=pschloss99
#SBATCH --partition=standard

#### #### ####  These are the least frequently changing options

####  Your e-mail address and when you want e-mail

#SBATCH --mail-user=jocolova@med.umich.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Add a note here to say what software modules should be loaded.
# for this job to run successfully.
# It will be convenient if you give the actual load command(s), e.g.,
#
# module load R


####  End Slurm preamble
##################


####  Commands your job should run follow this line


#add internet access to the jobs!
source /etc/profile.d/http_proxy.sh

#conda env
source ~/miniforge3/etc/profile.d/conda.sh
conda activate data_acc
#git checkout main

cd $SLURM_SUBMIT_DIR
#R CMD BATCH Code/MLprep.R Slurm/20240613_2_mlprep_gtnewseqdata_glmnet.out
snakemake --profile config_files/ --rerun-incomplete

##  If you copied any files to /tmp, make sure you delete them here!
