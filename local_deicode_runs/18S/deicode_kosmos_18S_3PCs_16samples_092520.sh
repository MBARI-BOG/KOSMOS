#!/usr/bin/env bash

#Make biom file
biom convert -i ./kosmos_18S_16_asv_table_for_biom.txt -o table.from_txt_json.biom --table-type="OTU table" --to-json
#add metadata files to biom file
biom add-metadata -i table.from_txt_json.biom -o table.w_md.biom --observation-metadata-fp kosmos_18S_16_tax_table_for_biom.txt --sample-metadata-fp kosmos_18S_16_sample_data_for_biom.txt

#import into Qiime2
qiime tools import \
 --input-path table.w_md.biom \
 --output-path kosmos_18S_master.biom.qza \
 --type FeatureTable[Frequency]

#run DEICODE
qiime deicode rpca \
    --i-table kosmos_18S_master.biom.qza \
    --p-n-components 3 \
    --p-min-feature-count 10 \
    --p-min-sample-count 1000 \
    --o-biplot ordination.qza \
    --o-distance-matrix distance.qza

## Create biplot
qiime emperor biplot \
    --i-biplot ordination.qza \
    --m-sample-metadata-file kosmos_18S_16_sample_data_for_biom.txt \
    --m-feature-metadata-file kosmos_18S_16_tax_table_for_biom.txt \
    --o-visualization biplot.qzv \
    --p-number-of-features 8
    
# Create Qurro Visualization
qiime qurro loading-plot \
    --i-ranks ordination.qza \
    --i-table kosmos_18S_master.biom.qza \
    --m-sample-metadata-file kosmos_18S_16_sample_data_for_biom.txt \
    --m-feature-metadata-file kosmos_18S_16_tax_table_for_biom.txt \
    --o-visualization qurro_plot_deicoderank.qzv
    
# Run PERMANOVA
 qiime diversity beta-group-significance \
    --i-distance-matrix distance.qza \
    --m-metadata-file kosmos_18S_16_sample_data_for_biom.txt \
    --m-metadata-column group \
    --p-method permanova \
    --o-visualization 18S_station_significance.qzv