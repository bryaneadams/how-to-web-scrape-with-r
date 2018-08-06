library(tidyverse)
library(rvest)
library(purrr)
library(stringr)


url="http://www.espn.com/nfl/statistics/team/_/stat/total/"

get_season_stats<-function(html){
  
  year=html%>%
    substr(start = nchar(.)-3,nchar(.) )%>%
    as.numeric()
  
  season_data<-html%>%
    read_html()%>%
    html_nodes("td")%>%
    html_text()%>%
    unlist()%>%
    matrix(ncol = 10, byrow = TRUE)%>%
    as.data.frame()
  
  names(season_data)<-  lapply(season_data[1,],as.character)
  season_data<-season_data%>%
    slice(-1)%>%
    mutate(Year=year)
  
}


scrape_write_table<-function(url, First_Year, Last_Year){
  
  list_of_pages<-str_c(url,'year/',First_Year:Last_Year)
  
  list_of_pages%>%
    #map applies the same function over the items of a list.
    map(get_season_stats)%>%
    bind_rows()%>%
    write_csv('stats.csv')
}

First_Year = 2010
Last_Year = 2011
scrape_write_table(url, First_Year, Last_Year)

NFL.Stats=read_csv('stats.csv')


#####################################
for(i in 1:length(list_of_pages)){
  
  get_season_stats(list_of_pages[i])
  print(i)
  
}

a<-get_season_stats(list_of_pages[8])
list_of_pages[8]
