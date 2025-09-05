library(shiny)
library(bslib)
library(r2d3)
library(tidyverse)
library(readxl)

server <- function(input, output, session) {
  
  
  mortality_effects <- reactive({
    scenario_mort <- read_excel("DiscMortalityRates.xlsx",sheet = "scenarios")
    
    # rearrange to long format so there is one row per sector
    scen_mort_long <- scenario_mort %>%
      separate(sector,into=c("sector1","sector2","sector3"),sep=",") %>%
      pivot_longer(cols=c("sector1","sector2","sector3"),values_to="sector0") %>%
      mutate(sector = str_trim(sector0)) %>%
      filter(!is.na(sector)) %>%
      select(-name)
    
    
  })
  
  scenariodata <- reactive({
    #filter historical data
    discards_historic <- source_historical_data() %>%
      filter(species %in% input$fishery_scenario,
             year >= input$years_scenario[1],
             year <= input$years_scenario[2],
             #sector1 %in% input$sector_scenario | sector2 %in% input$sector_scenario,
             region %in% input$region_scenario
      )

    #apply scenario differences:
    scen_data <- mortality_effects()
    
    descender_usage <- as.numeric(input$scenario_choice)
    
    fishsaved <- scen_data %>% 
      left_join(discards_historic) %>%
      mutate(max_benefit = m_diff*discards,                  # max benefit in this scenario (thousands of fish)
             inc_benefit = max_benefit/(100-base_desc_pct),  # incremental benefit in thousands of fish
             calcd_benefit=max_benefit*descender_usage)
    
    print("fish saved")
    print(fishsaved$discards)

    # print(hist_data_filtered)
    # #filter based on user inputs
    # summed_data <- hist_data_filtered %>% group_by(year) %>%
    #   summarise(tot_discards = sum(discards),
    #             tot_dead = sum(dead_disc),
    #             tot_landings = sum(landings)
    #   ) %>%
    #   pivot_longer(cols = tot_discards:tot_landings,
    #                names_to = "series",
    #                values_to = "value")%>%
    #   mutate(
    #     series = str_replace(series, "tot_discards","Released Alive"),
    #     series = str_replace(series, "tot_dead","Dead Upon Release"),
    #     series = str_replace(series, "tot_landings","Fish Kept")
    #   )
    # 
    # 
    # print(summed_data)
    # summed_data$value <- summed_data$value/1000

    hist_tot <- sum(fishsaved$discards,na.rm=TRUE)/1000
    new_tot <- hist_tot + sum(fishsaved$calcd_benefit,na.rm=TRUE)/1000
    return(data.frame(group=c("Historical","50%"), value=c(hist_tot,new_tot)))
    
  })
  
  output$scenariochart <- renderD3({
    if(scenariodata()$value[1]==0){
      NULL
    }else{
      r2d3(data=scenariodata(), script = "barchart.js", options =  list(scenario = paste0(as.numeric(input$scenario_choice)*100,"%"),
                                                                        xLabel = "",
                                                                        yLabel = "Millions",
                                                                        title = paste0("Fish Released Alive with ",as.numeric(input$scenario_choice)*100,"% of"),
                                                                        title2 = "Anglers Using Descender Devices",
                                                                        subtitle = if(input$years_scenario[1]==input$years_scenario[2]){input$years_scenario[1]}else{paste0(input$years_scenario[1]," - ",input$years_scenario[2])}))
      
    }
    
  })
  
  output$nodatatext <- renderUI({
    if(scenariodata()$value[1]==0){
      div(class = "nodatasection", "No data is available for selected filters")
    }else{NULL}
  })

  #text associated with this:
  output$selected_scenario <- renderUI({
    if(scenariodata()$value[1]==0){
      NULL
    }else{
    div(
      "With a ", span(class = "narrative_emphasis",paste0(as.numeric(input$scenario_choice)*100,"%")), " Descender Device usage rate, fish survival would increase by ", span(class = "narrative_emphasis", paste0(round((scenariodata()$value[2]/scenariodata()$value[1]-1)*100,0),"%")),
      if(input$years_scenario[1]==input$years_scenario[2]){paste0(" in ",input$years_scenario[1])}else{paste0(" from ",input$years_scenario[1]," to ",input$years_scenario[2])},"."
    )
    }
  })

  output$fish_saved_text <- renderUI({
    if(scenariodata()$value[1]==0){
      NULL
    }else{
      div(id = "fish-saved-block",
          div(id = "fish-saved-title",
              "Total Fish Saved"),
          div(id = "fish-saved-amount",
              format(round((scenariodata()$value[2]-scenariodata()$value[1])*1000000,-3),big.mark=",")
          )
      )
    }
  })
  
  
  source_historical_data <- reactive(({
    read.csv('historical data.csv')
  }))
  
  historicaldata<-reactive({
    hist_data_filtered <- source_historical_data()%>%
      filter(species %in% input$fishery_historical,
             year >= input$years_historical[1],
             year <= input$years_historical[2],
             #sector1 %in% input$sector_historical | sector2 %in% input$sector_historical,
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
                                                                       yLabel = "Millions",
                                                                       x_min = input$years_historical[1],
                                                                       x_max = input$years_historical[2]
                                                                       ))
  })
  
  
  output$historicaldatadownload <- downloadHandler(
    filename = function() {
      paste0('Historical Data', '.xlsx')
    },
    content = function(con) {
      data <- source_historical_data()
      write.csv(data, con)
    }
  )
  
  
  
}
