library(shiny)
library(bslib)
library(r2d3)
library(tidyverse)

server <- function(input, output, session) {
  
  
  
  scenariodata <- reactive({
    print(source_historical_data())
    print(input$fishery_historical)
    print(input$years_scenario)
    print(input$sector_historical)
    print(input$region_scenario)
    hist_data_filtered <- source_historical_data() %>%
      filter(species %in% input$fishery_scenario,
             year >= input$years_scenario[1],
             year <= input$years_scenario[2],
             sector1 %in% input$sector_scenario | sector2 %in% input$sector_scenario,
             region %in% input$region_scenario
      )
    

    print(hist_data_filtered)
    #filter based on user inputs
    summed_data <- hist_data_filtered %>% group_by(year) %>%
      summarise(tot_discards = sum(discards),
                tot_dead = sum(dead_disc),
                tot_landings = sum(landings)
      ) %>%
      pivot_longer(cols = tot_discards:tot_landings,
                   names_to = "series",
                   values_to = "value")%>%
      mutate(
        series = str_replace(series, "tot_discards","Released Alive"),
        series = str_replace(series, "tot_dead","Dead Upon Release"),
        series = str_replace(series, "tot_landings","Fish Kept")
      )
    
    
    print(summed_data)
    summed_data$value <- summed_data$value/1000
    
    
    hist_tot <- sum(summed_data$value[summed_data$series == "Released Alive"])
    new_tot <- hist_tot + sum(summed_data$value[summed_data$series == "Dead Upon Release"])*.2*as.numeric(input$scenario_choice)
    return(data.frame(group=c("Historical","50%"), value=c(hist_tot,new_tot)))
    
  })
  
  output$scenariochart <- renderD3({
    print(scenariodata())
    print(input$scenario_choice)
    r2d3(data=scenariodata(), script = "barchart.js", options =  list(xLabel = "",
                                                                      yLabel = "Millions",
                                                                      title = "Fish Released Alive with 25% of",
                                                                      title2 = "Anglers Using Descender Devices",
                                                                      subtitle = if(input$years_scenario[1]==input$years_scenario[2]){input$years_scenario[1]}else{paste0(input$years_scenario[1]," - ",input$years_scenario[2])}))
  })
  
  #text associated with this:
  output$selected_scenario <- renderUI({
    div(
      "With a ", span(class = "narrative_emphasis",paste0(as.numeric(input$scenario_choice)*100,"%")), " Descender Device usage rate, fish survival would increase by ", span(class = "narrative_emphasis", paste0(round((scenariodata()$value[2]/scenariodata()$value[1]-1)*100,0),"%")), " in 2023."
    )
  })
  
  output$fish_saved_text <- renderUI({
    div(
      format(round((scenariodata()$value[2]-scenariodata()$value[1])*1000000,0),big.mark=",")
    )
  })
  
  source_historical_data <- reactive(({
    read.csv('historical data.csv')
  }))
  
  historicaldata<-reactive({
    hist_data_filtered <- source_historical_data()%>%
      filter(species %in% input$fishery_historical,
             year >= input$years_historical[1],
             year <= input$years_historical[2],
             sector1 %in% input$sector_historical | sector2 %in% input$sector_historical,
             region %in% input$region_historical
             )
    
    #filter based on user inputs
    summed_data <- hist_data_filtered %>% group_by(year) %>%
      summarise(tot_discards = sum(discards),
                tot_dead = sum(dead_disc),
                tot_landings = sum(landings),
                type = "",
                yearnumeric = 0,
      ) %>%
      pivot_longer(cols = tot_discards:tot_landings,
                   names_to = "series",
                   values_to = "value")%>%
      mutate(
        series = str_replace(series, "tot_discards","Released Alive"),
        series = str_replace(series, "tot_dead","Dead Upon Release"),
        series = str_replace(series, "tot_landings","Fish Kept"),
        yearnumeric = year,
        year = str_replace(as.character(year),"20","'")
      )
    
    print(summed_data)
    
    summed_data$type <- sapply(summed_data$series,function(x){if(x=="Fish Kept"){"line"}else{"area"}})
    summed_data$value <- summed_data$value/1000
    return(summed_data)
  })
  
  output$historicalchart <- renderD3({
    r2d3(data=historicaldata(), script = "areachart.js",options = list(subtitle = if(input$years_historical[1]==input$years_historical[2]){input$years_historical[1]}else{paste0(input$years_historical[1]," - ",input$years_historical[2])},
                                                                       x_min = input$years_historical[1],
                                                                       x_max = input$years_historical[2]
                                                                       ))
  })
  
  
  
}
