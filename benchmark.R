#benchmark to 2015 data

outputResults <- TRUE

directory <- getwd()
outputdir <- paste0(directory, "/income_benchmark")

if (!dir.exists(outputdir)){
    dir.create(outputdir)
}

library(tidyverse)
path <- "modeledData_2015.csv"
data <- read_csv(path)
data <- data %>% group_by(STATE) %>% filter(row_number()==1)
data$X1 <- NULL
data$threshold <- qexp(0.99, rate=data$param)
comp <- readRDS("comp_epi.rds") %>% as_tibble()
comp$states <- as.character(comp$states)
data$epi.income <- comp$epi.income[match(data$COUNTYNAME, comp$states)]

data$dev <- (abs(data$epi.income - data$threshold) / data$epi.income)*100

p1 <- ggplot(data, aes(x=threshold,y=epi.income)) + geom_point() + xlab("Estimated Income") + ylab("EPI Income") + ggtitle("Minimum Income to be considered top 1% in States")

p2 <- ggplot(data, aes(dev)) + geom_histogram(bins=12) + xlab("Percent Deviation of Estimate From Truth") + ylab("Frequency")  + ggtitle("Errors of Estimation Represented As Histogram")

guess <- data %>% arrange(desc(threshold)) %>% select(STATE)
truth <- data %>% arrange(desc(epi.income)) %>% select(STATE)
ranks <- data.frame(corr.rank=match(guess$STATE, truth$STATE), rank=c(1:51))

#spearman is even higher, like 0.91
cor <- round(cor(data$threshold, data$epi.income, method="pearson"),2)
p3 <- ggplot(ranks, aes(x=rank,y=corr.rank)) + geom_point() + xlab("Ordered Rank of EPI Income Results by State") + ylab("Corresponding Rank of State From Estimate") + geom_abline(slope=1,intercept=0,linetype="dashed") + ggtitle(paste0("Pearson Correlation Between Estimated Ranks and EPI Results: ",cor))

outputfile <- paste0(outputdir,"/output.pdf")
pdf(outputfile)
p1
p2
p3
dev.off()

saveRDS(data, paste0(outputdir,"/data.rds"))
