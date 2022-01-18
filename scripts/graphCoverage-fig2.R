library(readr)
library(ggplot2)
library(tidyr)
library(xtable)
library(plyr)
library(dplyr)
library("fs")
library(viridis)
library(gridExtra)
library(forcats)

bms <- c('ant', 'bcelgen', 'maven', 'closure', 'rhino')
targets <- c('knarr-z3-no-global-hint','knarr-z3', 'jqf')
files<-basename(Sys.glob("/home/icse22ae/confetti-artifact/generated/coverage/*-coverage.csv"))
getBm <- function(filename){
  for(bm in bms){
    if(grepl(bm, filename))
      return(bm)
  }
}
getTarget <- function(filename){
  for(target in targets){
    if(grepl(target, filename))
      return(target)
  }
}
getExperiment <- function(filename){
  for(file in files){
    if(grepl(file,filename))
      return(file)
  }
}
read_coverage <- function(filename){
  ret <- read.csv(filename, header=TRUE)
  ret$experiment <- getExperiment(filename)
  ret$bm <- getBm(filename)
  ret$config <- getTarget(filename)
  ret
}


cov <- ldply(Sys.glob("/home/icse22ae/confetti-artifact/generated/coverage/*-coverage.csv"), read_coverage)
cov$experiment <- as.factor(cov$experiment)
cov$bm <- as.factor(cov$bm)
cov$config <- as.factor(cov$config)
cov$expID <- as.integer(cov$experiment)
#rhino <- read_coverage("coverage-all/aug24-400gb-md5-e9adb15377179f2fd9c7ac66ecdc5cfb-rhino-knarr-z3-5-coverage.csv")
#rhino <- subset(df, bm=="rhino")

summary <- cov %>% 
  group_by(bm,config,time) %>% 
  summarise(avg=mean(cov),min=min(cov),max=max(cov),Margin_Error = qt(0.95 + (1 - 0.95)/2, df = length(cov) - 1) * sd(cov)/sqrt(length(cov))
) %>% 
  # filter(config != "knarr-z3-no-global-hint") %>%
  mutate(config = factor(config, levels=c("knarr-z3","knarr-z3-no-global-hint","jqf")), lowerBound=avg-Margin_Error, upperBound=avg+Margin_Error)

summaryKnarrVsDict <- cov %>% 
  group_by(bm,config,time) %>% 
  summarise(avg=mean(cov),min=min(cov),max=max(cov)) %>% 
  filter(config != "jqf") %>%
  mutate(config = factor(config, levels=c("knarr-z3","knarr-z3-no-global-hint")))

createPlot <- function(toPlot){
  ggplot(data=subset(summary,bm==toPlot),
         aes(x=time,y=avg, group=config, color=config))  +
    geom_ribbon(aes(ymin=min,ymax=max, group=config, fill=config), linetype = 0, alpha=0.3)+ 
    geom_line(size=0.35) +
    scale_fill_manual(values=c("#1394C4","black","#D30115")) +
    scale_color_manual(values=c("#1394C4","black","#D30115")) +
    guides(fill=FALSE, color=FALSE) + 
    theme_linedraw() +
    theme(text=element_text(size = 8), axis.title.x=element_blank(),
                             axis.title.y=element_blank())
    ggsave(paste(toPlot,"_branches_over_time.pdf",sep=""), units="cm", width=8, height=6)
}
createPlotWithLegend <- function(toPlot){
  ggplot(data=subset(summary,bm==toPlot),
         aes(x=time,y=avg, group=config, color=config))  +
    geom_ribbon(aes(ymin=min,ymax=max, group=config, fill=config), linetype = 0, alpha=0.3) +
    geom_line(size=0.35) +
    scale_fill_manual(values=c("#1394C4","black","#D30115")) +
    scale_color_manual(values=c("#1394C4","black","#D30115")) +
    xlab("Campaign Time (minutes)") +
    ylab("Branch Probes Covered") +
    guides(fill=FALSE, color=FALSE) +
    theme_linedraw() + 
    theme(text=element_text(size = 6), axis.line = element_line(colour = 'black', size = 0.01))
 ggsave(paste(toPlot,"_branches_over_time.pdf",sep=""), units="cm", width=8, height=6)
}
createPlot("ant")
createPlot("maven")
createPlot("closure")
createPlot("rhino")
createPlotWithLegend("bcelgen")