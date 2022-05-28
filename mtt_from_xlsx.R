# loading libraries
library(tidyverse)
library(ggpubr)
library(rstatix)
library(readxl)

# file import
#print('Enter a pathway to the MTT data file in .xlsx format:')
#data_pathway <- readLines(con = 'stdin', n =1)
data_pathway <- readline('Enter a pathway to the MTT data file in .xlsx format:')
data <- read_excel(data_pathway, col_names = TRUE, col_types = "numeric")

print('Columns 1, 12 and rows A and H will be excluded from the analysis')
data <- data[-c(1, 2, 9), -c(1, 2, 13)]

# insert numbers of probes
#print('Enter the number of target columns:')
#columns_numbers <- as.numeric(readLines(con = 'stdin', n=1))
columns_numbers <- as.numeric(readline('Enter the number of target columns:'))

#print('Enter the number of target rows:')
#rows_numbers <- as.numeric(readLines(con = 'stdin', n=1))
rows_numbers <- as.numeric(readline('Enter the number of target rows:'))

data <- data[c(1:rows_numbers), c(1:columns_numbers)]

# named columns
print(paste('You should enter', columns_numbers, 'columns names as in your experiment'))
for (name in 1:columns_numbers) {
  #print(paste('Enter name for', name, 'column:'))
  #col_name <- readLines(con = 'stdin', n=1)
  col_name <- readline(paste('Enter name for', name, 'column:'))
  colnames(data)[name] <- col_name
}

# insert a control column and data standartization
#print('Print a number of a reference (control) column:')
#reference_column <- as.numeric(readLines(con = 'stdin', n=1))
reference_column <- as.numeric(readline('Print a number of a reference (control) column:'))

# means calculation for control and other samples
mean_col <- as.vector(apply(data, 2, mean))
mean_col_control <- mean(mean_col[reference_column])

# mean standardization and SD calculation
mtt_data_rel <- as.vector(mean_col / mean_col_control)
mtt_data_rel <- data.frame(mtt_data_rel, row.names = colnames(data))

sd_mtt <- apply(data, 2, sd)
sd_data_rel <- as.vector(sd_mtt / mean_col_control)

x_axis_head <- readline('Specify the title of the X axis:')
y_axis_head <- readline('Specify the title of the Y axis:')

#build the plot
ggplot(mtt_data_rel, aes(x = factor(colnames(data), levels = colnames(data)), y = mtt_data_rel)) +
  xlab(x_axis_head) +
  ylab(y_axis_head)+
  geom_bar(stat = "identity", 
           group = 1, width=0.5,
           fill='white',
           color='black') +
  geom_signif(comparisons = list(c("Control", "35 nm + 1 mM 2DF")), 
              map_signif_level=TRUE) + 
  #stat_compare_means(method = 'anova')+ 
  geom_errorbar(aes(ymin = mtt_data_rel - sd_data_rel, ymax = mtt_data_rel + sd_data_rel), width = 0.2)
