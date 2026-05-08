#!/bin/bash

# QIIME2 commands for PFOA microbiome project
# Author: Donglu Li

cd $RCAC_SCRATCH/PFOA/qiime2

module load biocontainers/default
module load qiime2/2024.10

# 1. DADA2 denoising
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs demux.qza \
  --p-trim-left-f 127 \
  --p-trim-left-r 20 \
  --p-trunc-len-f 244 \
  --p-trunc-len-r 249 \
  --o-table table.qza \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats stats-dada2.qza

# 2. Summarize DADA2 statistics
qiime metadata tabulate \
  --m-input-file stats-dada2.qza \
  --o-visualization stats-dada2.qzv

# 3. Build phylogenetic tree
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza

# 4. Core diversity metrics
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table.qza \
  --p-sampling-depth 467651 \
  --m-metadata-file sample-metadata.tsv \
  --output-dir core-metrics-results

# 5. Alpha diversity group significance
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/observed_features_vector.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization core-metrics-results/observed_features-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/shannon_vector.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization core-metrics-results/shannon-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/evenness_vector.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization core-metrics-results/evenness-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization core-metrics-results/faith-pd-group-significance.qzv

# 6. Beta diversity PERMANOVA
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/bray_curtis_distance_matrix.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column Group \
  --p-pairwise \
  --o-visualization core-metrics-results/bray-curtis-group-significance.qzv

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/jaccard_distance_matrix.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column Group \
  --p-pairwise \
  --o-visualization core-metrics-results/jaccard-group-significance.qzv

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column Group \
  --p-pairwise \
  --o-visualization core-metrics-results/unweighted-unifrac-group-significance.qzv

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column Group \
  --p-pairwise \
  --o-visualization core-metrics-results/weighted-unifrac-group-significance.qzv

# 7. Taxonomic classification
qiime feature-classifier classify-sklearn \
  --i-classifier silva-classifier-v3v4.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza

# 8. Taxa bar plot
qiime taxa barplot \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file sample-metadata.tsv \
  --o-visualization taxa-bar-plots-PFOA.qzv

# 9. ANCOM-BC at ASV level
qiime composition ancombc \
  --i-table table.qza \
  --m-metadata-file sample-metadata.tsv \
  --p-formula 'Group' \
  --o-differentials ancombc-group.qza

qiime composition da-barplot \
  --i-data ancombc-group.qza \
  --p-significance-threshold 0.01 \
  --o-visualization da-barplot-group.qzv

# 10. ANCOM-BC at genus level
qiime taxa collapse \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 6 \
  --o-collapsed-table table-l6.qza

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

# 11. Random Forest sample classifier
qiime sample-classifier classify-samples \
  --i-table table.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column Group \
  --p-optimize-feature-selection \
  --p-parameter-tuning \
  --p-estimator RandomForestClassifier \
  --p-n-estimators 100 \
  --p-random-state 123 \
  --output-dir rf-classifier