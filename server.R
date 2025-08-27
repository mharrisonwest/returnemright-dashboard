library(shiny)
library(bslib)
library(r2d3)
library(tidyverse)

server <- function(input, output, session) {
  
  output$scenariochart <- renderD3({
    r2d3(data=data.frame(group=c("Historical","50%"), value=c(1.6,1.8)), script = "barchart.js", options = list(xLabel = "",
                                                                                                                yLabel = "Millions",
                                                                                                                title = "Fish Released Alive with 25% of",
                                                                                                                title2 = "Anglers Using Descender Devices",
                                                                                                                subtitle = "2023"))
  })
  
  source_historical_data <- reactive(({
    read.csv('historical data.csv')
  }))
  
  historicaldata<-reactive({
    
    hist_data_filtered <- source_historical_data()%>%
      filter(species %in% input$fishery_historical
             )
    
    #filter based on user inputs
    summed_data <- hist_data_filtered %>% group_by(year) %>%
      summarise(tot_discards = sum(discards),
                tot_dead = sum(dead_disc),
                tot_landings = sum(landings),
                type = ""
      ) %>%
      pivot_longer(cols = tot_discards:tot_landings,
                   names_to = "series",
                   values_to = "value")%>%
      mutate(
        series = str_replace(series, "tot_discards","Released Alive"),
        series = str_replace(series, "tot_dead","Dead Upon Release"),
        series = str_replace(series, "tot_landings","Fish Kept"),
        year = str_replace(as.character(year),"20","'")
      )
    
    print(summed_data)
    
    summed_data$type <- sapply(summed_data$series,function(x){if(x=="Fish Kept"){"line"}else{"area"}})
    summed_data$value <- summed_data$value/1000
    return(summed_data)
  })
  
  output$historicalchart <- renderD3({
    r2d3(data=historicaldata(), script = "areachart.js",options = list(subtitle = "(2005-2023)"))
  })
  
}
