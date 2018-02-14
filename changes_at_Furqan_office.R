if (!require(rvest)) install.packages('rvest')
library(rvest)
if (!require(selectr)) install.packages('selectr')
library(selectr)
if (!require(dplyr)) install.packages('dplyr')
library(dplyr)
if (!require(stringr)) install.packages('stringr')
library(stringr)
if (!require(here)) install.packages('here')
library(here)

currdir <- here()
setwd(currdir)
# setwd("E:/Dropbox/Furqan's Personal/R")
url <- "https://coinmarketcap.com/all/views/all/"
currpage <- read_html(url)

currtable <- currpage %>% html_node(xpath='//table[@id="currencies-all"]') %>% html_table()

currtable$Name <- gsub('[^a-zA-z][ ]{1}', '', x = currtable$Name)
currtable$`Market Cap` <- gsub('[^0-9]', '', x = currtable$`Market Cap`)
currtable$Price <- str_extract(currtable$Price, '[.0-9]+')
currtable$Price <- as.numeric(currtable$Price)
currtable$`Market Cap` <- as.numeric(currtable$`Market Cap`)

bitcoinsheet <- read.csv('./Source/bitcoinneeded.csv')
bitcoinsheet$Exact.Name <- str_trim(bitcoinsheet$Exact.Name)
USDTsheet <- read.csv('./Source/USDTneeded.csv')
USDTsheet$Exact.Name <- str_trim(USDTsheet$Exact.Name)
bitcoinfiltered <- subset(currtable, Symbol %in% bitcoinsheet$Currency)
dupindex <- which(duplicated(bitcoinfiltered$Symbol) | duplicated(bitcoinfiltered$Symbol, fromLast=TRUE))

# bitcoinfiltered2 <- bitcoinfiltered[-(dupindex[!(bitcoinfiltered[dupindex,2] %in% bitcoinsheet$`Exact Name`)]),]
bitcoinfiltered$Name <- str_replace(bitcoinfiltered$Name, pattern="\n", replace=" ")

bitcoinfiltered2 <- bitcoinfiltered[-(dupindex[which(!(bitcoinfiltered[dupindex,2] %in% bitcoinsheet$Exact.Name))]),]

USDTfiltered <- subset(currtable, Symbol %in% USDTsheet$Currency)
dupindex2 <- which(duplicated(USDTfiltered$Symbol) | duplicated(USDTfiltered$Symbol, fromLast=TRUE))

USDTfiltered$Name <- str_replace(USDTfiltered$Name, pattern="\n", replace=" ")
USDTfiltered2 <- USDTfiltered[-(dupindex2[which(!(USDTfiltered[dupindex2,2] %in% USDTsheet$Exact.Name))]),]

bitcoinout <- select(bitcoinfiltered2, Symbol, Price, rank=`#`, `Market Cap`)

# bitcoinout$Price <- str_extract(bitcoinout$Price, '[.0-9]+')

USDTout <- select(USDTfiltered2, Symbol, Price, rank=`#`, `Market Cap`)
# USDTout$Price <- str_extract(USDTout$Price, '[.0-9]+')
# bitcoinout$Price <- as.numeric(bitcoinout$Price)
# bitcoinout$`Market Cap` <- as.numeric(bitcoinout$`Market Cap`)
# USDTout$Price <- as.numeric(USDTout$Price)
# USDTout$`Market Cap` <- as.numeric(USDTout$`Market Cap`)

TotalMarCap <- c('Total Market Cap:', sum(currtable$`Market Cap`, na.rm = T))

# lastrow <- data.frame('', '', '', sum(currtable$`Market Cap`, na.rm = T))
# names(lastrow) <- names(bitcoinout)
# bitcoinout <- rbind(bitcoinout, lastrow)
# USDTout <- rbind(USDTout, lastrow)
# write.csv(bitcoinout, file=paste('bitcoin', Sys.time(), '.csv'))
# write.csv(USDTout, file=paste('USDT', Sys.time(), '.csv'))
write.csv(bitcoinout, file="bitout.csv")
write.csv(USDTout, file='USDTout.csv')
write.csv(TotalMarCap, file='MarCap.csv')