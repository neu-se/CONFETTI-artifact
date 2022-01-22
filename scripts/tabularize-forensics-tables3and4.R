library(readr)
library(ggplot2)
library(tidyr)
library(xtable)
library(plyr)
library(dplyr)
options(scipen=999)

args = commandArgs(trailingOnly=TRUE)
if (length(args)!=2) {
  stop("Usage: Rscript scripts/tabularize-forensics-tables3and4.R fuzzStatsCSVFile forensicsOutputDir")
}
fuzzStatsCSVFileName <- args[1]
forensicsOutputDir <- args[2]

forensics <- ldply(Sys.glob(paste0(forensicsOutputDir, "/*.forensics-1k.csv")), read.csv, header=TRUE)
forensics$numStringsTotal <- forensics$inputSizeBytes

forensics$numGlobalDictHintsPerByte <- forensics$numGlobalDictHints/forensics$inputSizeBytes
forensics$numGlobalDictHintsPerString <- forensics$numGlobalDictHints/forensics$numStringsTotal
forensics$numStringHintsPerString <- forensics$numStringHints/forensics$numStringsTotal
forensics$numZ3HintsPerString <- forensics$numZ3Hints/forensics$numStringsTotal
forensics$numCharHintsPerString <- forensics$numCharHints/forensics$numStringsTotal
forensics$numAnyStrGuidancePerString <- (forensics$numStringHints + forensics$numCharHints + forensics$numZ3Hints + forensics$numGlobalDictHints)/forensics$numStringsTotal

forensics$experiment <- as.factor(forensics$experiment)
forensics$app <- as.factor(forensics$app)

fuzz_stats <- read_csv(fuzzStatsCSVFileName)
fuzz_stats$experiment <- as.factor(fuzz_stats$experiment)
fuzz_stats$bm <- as.factor(fuzz_stats$bm)

fuzz_stats['successRate.charHint'] <- 100*fuzz_stats['inputsSavedBy_CharHint']/fuzz_stats['inputsCreatedBy_CharHint']
fuzz_stats['successRate.singleStringHint'] <- 100*fuzz_stats['inputsSavedBy_StrHint']/fuzz_stats['inputsCreatedBy_StrHint']
fuzz_stats['successRate.multiStringHint'] <- 100*fuzz_stats['inputsSavedBy_MultipleStrHint']/fuzz_stats['inputsCreatedBy_MultipleStrHint']
fuzz_stats['successRate.extendedDictionary'] <- 100*fuzz_stats['countOfSavedInputsWithExtendedDictionaryHints']/fuzz_stats['countOfCreatedInputsWithExtendedDictionaryHints']
fuzz_stats['successRate.random'] <- 100*fuzz_stats['inputsSavedBy_Random']/fuzz_stats['inputsCreatedBy_Random']
fuzz_stats['successRate.z3'] <- 100*fuzz_stats['inputsSavedBy_Z3']/fuzz_stats['inputsCreatedBy_Z3']

grouped_stats <- fuzz_stats %>% group_by(bm) %>%
  summarise(totalInputs=sum(total_inputs), 
            successRate.z3=100*sum(inputsSavedBy_Z3)/sum(inputsCreatedBy_Z3),
            successRate.charHint=100*sum(inputsSavedBy_CharHint)/sum(inputsCreatedBy_CharHint),
            successRate.stringHint=100*sum(inputsSavedBy_StrHint+inputsSavedBy_MultipleStrHint)/sum(inputsCreatedBy_StrHint+inputsCreatedBy_MultipleStrHint),
            successRate.global=100*sum(countOfSavedInputsWithExtendedDictionaryHints)/sum(countOfCreatedInputsWithExtendedDictionaryHints),
            successRate.Random=100*sum(inputsSavedBy_Random)/sum(inputsCreatedBy_Random))

totalsByExperiment <- forensics %>% group_by(app,experiment) %>% summarize(inputs = n(),
                inputsWithZ3Hints=sum(numZ3Hints>0),
                inputsWithCharHints=sum(numCharHints >0),
                inputsWithStringHints=sum(numStringHints >0),
                inputsWithGlobalDictHints=sum(numGlobalDictHints > 0),
                # inputsGlobalDictHintsExtraPowerful=sum(numChildrenSameCovAndCounts == 0 & numGlobalDictHints > 0),
                # avgNumberStrings=mean(numStringsTotal),
                # avgPercentageStrsWithZ3Hint=100*mean(numZ3HintsPerString, na.rm=TRUE),
                # avgPercentageStrsWithCharHint=100*mean(numCharHintsPerString, na.rm=TRUE),
                # avgPercentageStrsWithStrHint=100*mean(numStringHintsPerString, na.rm=TRUE),
                # avgPercentageStrsWithGlobalDictHint=100*mean(numGlobalDictHintsPerString, na.rm=TRUE),
                # avgPercentageStrsWithAnyGuidance=100*mean(numAnyStrGuidancePerString, na.rm=TRUE),
                )



# write.csv(totalsByExperiment,file = "knarr-forensics-exp.csv")

totalsByApp <- totalsByExperiment %>% select(-experiment) %>% group_by(app) %>%  summarise_all(sum) 
# write.csv(totalsByApp,file = "knarr-forensics-app.csv")

totalsPrint <- merge(grouped_stats,totalsByApp,by.x="bm",by.y="app")
totalsPrint$successRate.z3 <- paste(round(totalsPrint$successRate.z3, digits=2),"%", sep="")
totalsPrint$successRate.charHint <- paste(format(round(totalsPrint$successRate.charHint, digits=2), nsmall=2),"%", sep="")
totalsPrint$successRate.stringHint <- paste(format(round(totalsPrint$successRate.stringHint, digits=4), nsmall=4),"%", sep="")
totalsPrint$successRate.global <- paste(round(totalsPrint$successRate.global, digits=4),"%", sep="")
totalsPrint$successRate.Random <- paste(round(totalsPrint$successRate.Random, digits=4),"%", sep="")

# totalsPrint$avgPercentageStrsWithGlobalDictHint <- paste(round(totalsPrint$avgPercentageStrsWithGlobalDictHint, digits=2),"%", sep="")
# totalsPrint$avgPercentageStrsWithStrHint <- paste(round(totalsPrint$avgPercentageStrsWithStrHint, digits=2),"%", sep="")
# totalsPrint$avgPercentageStrsWithCharHint <- paste(round(totalsPrint$avgPercentageStrsWithCharHint, digits=2),"%", sep="")
# totalsPrint$avgPercentageStrsWithZ3Hint <- paste(round(totalsPrint$avgPercentageStrsWithZ3Hint, digits=2),"%", sep="")
# totalsPrint$avgPercentageStrsWithAnyGuidance <- paste(round(totalsPrint$avgPercentageStrsWithAnyGuidance, digits=2),"%", sep="")
# 
print(xtable(totalsPrint,digits=c(0,0,0,0,0,0,0,0,0,0,0,0,0)),format.args=list(big.mark=","), include.rownames=FALSE)

forensicsPrint <- forensics  %>%
  filter(numGlobalDictHints >0) %>% 
  mutate(bin=
           case_when(numChildrenLessCov + numChildrenSameCovLessCounts == 0 ~ "Trivially", 
                     numChildrenLessCov + numChildrenSameCovLessCounts > 0 & numChildrenLessCov + numChildrenSameCovLessCounts < 1000 ~ "Eventually",
                     TRUE~"Never")) %>% 
  group_by(app,bin) %>%
  summarise(matching=n()) %>%
  pivot_wider(names_from = bin,values_from= matching) %>% 
  mutate_if(is.numeric, funs(ifelse(is.na(.), 0, .)))  %>%
  mutate(Total = Trivially+Eventually+Never) 

forensicsPrint$`TriviallyPercent` <- paste("(",round(100*forensicsPrint$`Trivially`/forensicsPrint$Total,digits=2),"%)",sep="")
forensicsPrint$`EventuallyPercent` <- paste("(",format(round(100*forensicsPrint$`Eventually`/forensicsPrint$Total,digits=2),nsmall=2),"%)",sep="")
forensicsPrint$`NeverPercent` <- paste("(",round(100*forensicsPrint$`Never`/forensicsPrint$Total,digits=2),"%)",sep="")
forensicsPrint <- forensicsPrint %>% select(-Total) %>%  relocate(app,Trivially,TriviallyPercent,Eventually,EventuallyPercent,Never,NeverPercent)

print(xtable(forensicsPrint, digits=0),format.args=list(big.mark=","), include.rownames=FALSE)

