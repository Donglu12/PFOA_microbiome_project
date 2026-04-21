#!/bin/bash

#SBATCH --nodes=1
#SBATCH -n 12
#SBATCH -p cpu
#SBATCH --mem=20G
#SBATCH --time=04:00:00
#SBATCH --job-name PFOA_assignment6
#SBATCH -A microbiome

echo "Start time"
date

cd $RCAC_SCRATCH/PFOA/qiime2

pwd
ls

module load biocontainers
module load qiime2

# taxonomy
qiime feature-classifier classify-sklearn \
--i-classifier silva-classifier-v3v4.qza \
--i-reads rep-seqs.qza \
--o-classification taxonomy.qza

# taxa barplot（作业第1部分）
qiime taxa barplot \
--i-table table.qza \
--i-taxonomy taxonomy.qza \
--m-metadata-file sample-metadata.tsv \
--o-visualization taxa-bar-plots-PFOA.qzv

# ANCOM-BC（ASV level）
qiime composition ancombc \
 --i-table table.qza \
 --m-metadata-file sample-metadata.tsv \
 --p-formula 'Group' \
 --o-differentials ancombc-group.qza

qiime composition da-barplot \
  --i-data ancombc-group.qza \
  --p-significance-threshold 0.01 \
  --o-visualization da-barplot-group.qzv

# collapse to genus
qiime taxa collapse \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 6 \
  --o-collapsed-table table-l6.qza

# ANCOM-BC（genus level）
qiime composition ancombc \
  --i-table table-l6.qza \
  --m-metadata-file sample-metadata.tsv \
  --p-formula 'Group' \
  --o-differentials l6-ancombc-group.qza

qiime composition da-barplot \
  --i-data l6-ancombc-group.qza \
  --p-significance-threshold 0.01 \
  --p-level-delimiter ';' \
  --o-visualization l6-da-barplot-group.qzv

echo "End time"
date
