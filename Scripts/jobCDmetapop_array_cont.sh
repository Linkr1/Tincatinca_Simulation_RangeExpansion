#!/bin/bash
#SBATCH --job-name=array_continuous_0513
#SBATCH --time=5-00:00
#SBATCH --output=test_%A_%a.out
#SBATCH --array=1-100
#SBATCH --mail-type=BEGIN,END,FAIL,ARRAY_TASKS
#SBATCH --mail-user=thais@bernos.fr
#SBATCH --mem=20G
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --output=slurm_array_continuous_0513.txt

name=$(sed -n "$SLURM_ARRAY_TASK_ID"p Allfiles.txt)

module load nixpkgs/16.09 python/2.7.14 scipy-stack/2017b

INPUT=$(basename "$name") # This will grab the file.csv
DIR=$(dirname "$name")/  # This will grab the directory and then add the "/"

echo ""
echo "Job Array ID / Job ID: $SLURM_ARRAY_JOB_ID / $SLURM_JOB_ID"
echo "This is job $SLURM_ARRAY_TASK_ID out of $SLURM_ARRAY_TASK_COUNT jobs."
echo ""

python ../../CDMetaPOP_MultiSpecies_v2.48_CD/src/CDmetaPOP.py $DIR $INPUT OUT_cont_

echo "finished $name"
