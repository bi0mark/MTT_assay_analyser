# loading libraries
library(ggpubr)
library(rstatix)
library(readxl)
library(reshape2)

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
mtt_data_rel <- data.frame(colnames(data), mtt_data_rel)
colnames(mtt_data_rel)[1] <- 'samples'
colnames(mtt_data_rel)[2] <- 'values'

sd_mtt <- apply(data, 2, sd)
sd_data_rel <- as.vector(sd_mtt / mean_col_control)

x_axis_head <- readline('Specify the title of the X axis:')
y_axis_head <- readline('Specify the title of the Y axis:')
main_title <- readline('Specify the main title of plot:')

table_for_stat <- melt(data)

plot_directiry <- readline('Paste the path to the directory to save the plot with file name at the end:')

#build the plot
pdf(path.expand(plot_directiry), width = 7, height = 8, bg = 'white', colormodel = 'cmyk', paper = 'A4')

ggplot(mtt_data_rel, aes(x = factor(samples, levels = colnames(data)), y = values)) +
  xlab(x_axis_head) +
  ylab(y_axis_head)+
  ggtitle(main_title) +
  
  geom_bar(stat = "identity", 
           group = 1, width=0.5,
           fill='white',
           color='black') +
  
  geom_errorbar(aes(ymin = values - sd_data_rel,
                    ymax = values + sd_data_rel),
                width = 0.2) +
  
  stat_compare_means(data = table_for_stat, aes(x = variable, y = value),
                          method = 't.test',
                          ref.group = colnames(data)[reference_column],
                          label = "p.signif",
                          label.y = 1.1)

dev.off()
