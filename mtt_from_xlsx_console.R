# check libraries availability 
usePackage <- function(p) 
{
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE, repos = 'https://cloud.r-project.org')
  require(p, character.only = TRUE)
}

requirments <- c('ggpubr', 'rstatix', 'readxl', 'reshape2') 

for (package_name in requirments) {
  usePackage(package_name)
}

# file import
print('Enter a pathway to the MTT data file in .xls or .xlsx format:')
data_pathway <- readLines(con = 'stdin', n =1)
data <- read_excel(data_pathway, col_names = TRUE, col_types = "numeric")

print('Columns 1, 12 and rows A and H will be excluded from the analysis')
data <- data[-c(1, 2, 9), -c(1, 2, 13)]

print(data)

# insert numbers of probes
print('Enter the number of target columns:')
columns_numbers <- as.numeric(readLines(con = 'stdin', n=1))

print('Enter the number of target rows:')
rows_numbers <- as.numeric(readLines(con = 'stdin', n=1))

data <- data[c(1:rows_numbers), c(1:columns_numbers)]

# named columns
print(paste('You should enter', columns_numbers, 'columns names as in your experiment'))
for (name in 1:columns_numbers) {
  print(paste('Enter name for', name, 'column:'))
  col_name <- readLines(con = 'stdin', n=1)
  colnames(data)[name] <- col_name
}

print(data)

# insert a control column and data standartization
print('Print a number of a reference (control) column:')
reference_column <- as.numeric(readLines(con = 'stdin', n=1))

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

table_for_stat <- melt(data)

print('Specify the title of the X axis:')
x_axis_title <- readLines(con = 'stdin', n=1)
print('Specify the title of the Y axis:')
y_axis_title <- readLines(con = 'stdin', n=1)
print('Specify the main title of plot:')
main_title <- readLines(con = 'stdin', n=1)

print('Paste the path to the directory to save the plot with file name at the end:')
plot_directiry <- readLines(con = 'stdin', n=1)
print('Please, type a file format (png, pdf, eps, ps, tex, jpeg, tiff, bmp, svg or wmf):')
file_type <- readLines(con = 'stdin', n=1)
print('Type a name of the plot file with its format:')
file_name <- readLines(con = 'stdin', n=1)

print('Specify statistic test wilcox.test (Mann-Whitney) or t.test:')
statistic_test <- readLines(con = 'stdin', n=1)

#build the plot
plotter <- function(file_name, plot_directiry, file_type, statistics, x_axis, y_axis, main_title) {
  plot <- ggplot(mtt_data_rel, aes(x = factor(samples, levels = colnames(data)), y = values)) +
  xlab(x_axis) +
  ylab(y_axis)+
  ggtitle(main_title) +
  
  geom_bar(stat = "identity", 
           group = 1, width=0.5,
           fill='white',
           color='black') +
  
  geom_errorbar(aes(ymin = values - sd_data_rel,
                    ymax = values + sd_data_rel),
                width = 0.2) +
  
  stat_compare_means(data = table_for_stat, aes(x = variable, y = value),
                          method = statistics,
                          ref.group = colnames(data)[reference_column],
                          label = "p.signif",
                          label.y = 1.2,
                          show.legend = TRUE)
  
  ggsave(
    filename = file_name,
    path = plot_directiry,
    plot = plot,
    device = file_type
  )
}

plotter(file_name, plot_directiry, file_type, statistic_test, x_axis_title, y_axis_title, main_title)
