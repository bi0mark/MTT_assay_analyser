# Data processing script for raw MTT analysis files

This simple R script is devoted to prosessing raw [MTT assay](https://en.wikipedia.org/wiki/MTT_assay) data on the fly.

## Dependencies

[R](https://www.r-project.org/) and addition packages:

  * readxl
  * reshape2
  * rstatix
  * ggpubr

## Input data format

Only one file can be processed per run. Raw data should be in .xlsx format (please, see [example_mtt_data](example_mtt_data.xls)) and correspond with location of the samples on the 96-well plate. Each column corresponds to each sample, wells B to G is a sample replicates. 

Rows A and H and columns 1 and 12 will not be considered in processing, because their data is incorrect due to the [edge effect](https://www.researchgate.net/publication/341902684_Evaluation_of_plate_edge_effects_in_in-vitro_cell_based_assay).

![](96_well_plate.jpg)

## User interactions

The script supports interaction with user:

  * Customize a number of samples (from 1 to 10)
  * Customize a number of samples replicates (from 1 to 6)
  * User-defined sample (columns) names
  * User-defined reference sample for measuring relative survival
  * User-defined titles of X and Y axis and a main plot title
  * Saving directory is user defined

## Output results
The output is a [barplot](plot.pdf) with error bars (standard deviation) and statistical significance (displayed as \*) based on T-test. Statistic difference is measure between reference sample and other samples.
