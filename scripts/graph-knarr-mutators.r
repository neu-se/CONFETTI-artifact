library(readr)
library(ggplot2)
library(tidyr)
library(xtable)

load_file <- function(bmName){
  df <- read_csv(paste("aws-scripts/results-",bmName,"-knarr-z3.csv",sep = ""))
  df['successRate.charHint'] <- 100*df['inputsSavedBy_CharHint']/df['inputsCreatedBy_CharHint']
  df['successRate.singleStringHint'] <- 100*df['inputsSavedBy_StrHint']/df['inputsCreatedBy_StrHint']
  df['successRate.multiStringHint'] <- 100*df['inputsSavedBy_MultipleStrHint']/df['inputsCreatedBy_MultipleStrHint']
  df['successRate.extendedDictionary'] <- 100*df['countOfSavedInputsWithExtendedDictionaryHints']/df['countOfCreatedInputsWithExtendedDictionaryHints']
  df['successRate.random'] <- 100*df['inputsSavedBy_Random']/df['inputsCreatedBy_Random']
  df['successRate.z3'] <- 100*df['inputsSavedBy_Z3']/df['inputsCreatedBy_Z3']

  return(df)
}
getLastRow <- function(dat){
  return(subset(dat,`# unix_time` == max(dat$`# unix_time`)))
}
bms <- c('ant', 'bcelgen', 'maven', 'closure', 'rhino')

#data <- lapply(bms,load_file)
final_stats <- as.data.frame(t(sapply(data,getLastRow)), row.names=bms)
# successStats <- pivot_longer(final_stats, cols=starts_with("successRate"), names_to="measure", values_to = "successRate", names_prefix="successRate.")
