#!/bin/sh -l

#SBATCH --nodes=1                    ##number of requested nodes (a node is a group of CPUs)
#SBATCH -n 12		             ##number of requested CPUs
#SBATCH --time=04:00:00              ##time requested
#SBATCH --job-name MP-pipeline       ##name of job
#SBATCH -A microbiome                ##name of the queue you are using. Could be scholar or microbiome if you are on snyder
#SBATCH -p cpu
#########################################################################

echo "Start time"
date +"%d %B %Y %H:%M:%S"

#step 1, cd into the proper directory. This directory must already exist

cd /scratch/bell/li5875/PFOA/qiime2

pwd

module load biocontainers
module load qiime2
module list

qiime phylogeny align-to-tree-mafft-fasttree \
 --i-sequences rep-seqs.qza \
 --o-alignment aligned-rep-seqs.qza \
 --o-masked-alignment masked-aligned-rep-seqs.qza \
 --o-tree unrooted-tree.qza \
 --o-rooted-tree rooted-tree.qza

qiime diversity core-metrics-phylogenetic \
 --i-phylogeny rooted-tree.qza \
 --i-table table.qza \
 --p-sampling-depth 467651 \
 --m-metadata-file sample-metadata.tsv \
 --output-dir core-metrics-results

qiime diversity alpha \
 --i-table table.qza \
 --p-metric chao1 \
 --o-alpha-diversity core-metrics-results/chao1_vector.qza



qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization core-metrics-results/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/evenness_vector.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization core-metrics-results/evenness-group-significance.qzv

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column Group \
  --o-visualization core-metrics-results/unweighted-unifrac-Group-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column Group \
  --o-visualization core-metrics-results/weighted-unifrac-Group-significance.qzv \
  --p-pairwise


echo "End time"
date +"%d %B %Y %H:%M:%S"

