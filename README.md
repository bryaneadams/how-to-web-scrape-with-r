# Introduction to Web Scraping Data with R
This is a tutorial on how to scrape data from a webpage for Introduction to Probability and Statistics students.  It covers how to scrape data from one of the recommended scoures.  This is not the only method to collect the data, but provides instruction for one method.

#Getting Started

First we will need to download a tool to help with identifying the data you would like to scrap of the web.  If you know how to read HTML code well you will not need this program, but it still can make things easier.  One such program is called Selector Gadget and is found at the following link:  https://selectorgadget.com/ 

Selector Gadget is designed to work on Google Chrome, but it also works well on Fire Fox.  Once on the page scroll to the bottom and using one of the two options to download the SelectorGadget.



![](SelectorGadget.png "How to Install Selector Gadget")



Second, we will need to install the required packages in using the following lines of code:

```r
install.packages("rvest")
install.packages("tidyverse")
install.packages("purrr")
install.packages("stringr")
```

Once they are installed, the following lines of code will load the packages into your current file:

```R
library(tidyverse)
library(rvest)
library(purrr)
library(stringr)
```

For this tutorial we will be taking nfl data from espn.com.  Using the following link: http://www.espn.com/nfl/statistics/team/_/stat/total/

#Scraping the Data from One Page

To start we will read data from one page of the website.  In the past you would have highlighted the table and pasted it into Excel.  This works for one page and a nicely formatted table, but what if you wanted to do it for 10 or 100 pages.  R will make it much easier.

First we need to read the webpage.  The following lines of code first read the webpage's HTML Code, looks for "td" (more on this later), converts it to text and finally makes it into a data frame (a table of data).

```r
url = "http://www.espn.com/nfl/statistics/team/_/stat/total/"

season_data<-url%>%
    read_html()%>%
    html_nodes("td")%>%
    html_text()%>%
    matrix(ncol = 10, byrow = TRUE)%>%
    as.data.frame()
```

So where did the "td" come from ... SelectorGadget!

On the webpage click on SelectorGadeget, then click on the data you would like. See the image bellow for instructions:

![](SelectorGadget2.png)

Inside of the SelectorGadget tool you will see td.  This is a reference to the HTML code and is what will go into the ```html_nodes()``` function.  Every table is different, sometimes you will have longer sections, but in this case it is small.  To see where the "td" came from you would have to look at the html code.  In this case the table is barried in the HTML code and if you are not familiar with reading HTML you would not have been able to find the reference.

When the data is read from the webpage it comes a single string.  ```html_nodes()``` reads the data, ```html_text()``` converts the information to a string, and ``` matrix()``` breaks the string into a table.  n = 10 because that is the number of columns for each table.  No two strings are ever the same.  With practice you will get better at determining how to break the strings into usable tables.  Maybe one day someone will create the ```give_me_data_the_way_I_want_it()``` command.

#Reading Data from Multiple Pages

Next we will read multiple years of statistics.  The method for a single page would work, but you would have to keep changing the url.  First, we look out how the url changes when we select another year. It goes from http://www.espn.com/nfl/statistics/team/_/stat/total/ to http://www.espn.com/nfl/statistics/team/_/stat/total/year/2016.  This is a pretty simple change, we only need to add "year/2016" to the orginal url.  Luckily it also keeps the same format for the other years. Now we will create a list of urls for the years we want.

```r
First_Year = 2002
Last_Year = 2017

list_of_pages<-str_c(url,'year/',First_Year:Last_Year)
```

```str_c``` Creates a list of pages by taking the orginal url and adding year/2016 and so on for the range of selected years.  We now have a complete list of urls that we would like data from.  

Next we are going to make two functions that will make our code easier to use.  The first function ```scrape_write_table``` will create the list of webpages and then write the final data to a .csv.  The second function ```get_season_stats``` will scrape each webpage and return a table for that year.  Here is the code for the ```scrape_write_table``` function:

```r
scrape_write_table<-function(url, First_Year, Last_Year){
  
  list_of_pages<-str_c(url,'year/',First_Year:Last_Year)
  
  list_of_pages%>%
    #map applies the same function over the items of a list.
    map(get_season_stats)%>%
    bind_rows()%>%
    write_csv('stats.csv')
}
```

The function takes in three arguements:  your url, the first year and the last year of data you would like.  It creates the list of urls, as discussed earlier, and then calls the second function ```get_season_stats```.  With each scrape, it binds all the rows into a large table and when complete writes the .csv file.
