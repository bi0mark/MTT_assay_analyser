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
  * Saving directory and file name is user-defined
  * File type (png, eps, ps, tex (pictex), pdf, jpeg, tiff, bmp, svg or wmf) is also user-defined

## Output results
The output is a barplot with errorbars (standart deviation) and statistic significance (displayed as \*) based on T-test. Statictic differrence is measure between reference sample and other samples.

![](plot)
