library(shiny)
library(bslib)
library(r2d3)
library(tidyverse)
library(readxl)
library(openxlsx)
library(shinyjs)

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
    
    scen_mort_long
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
    
    descender_usage <- as.numeric(str_remove(input$scenario_choice,"%"))/100
    print(descender_usage)
    fishsaved <- scen_data %>% 
      left_join(discards_historic) %>%
      mutate(max_benefit = m_diff_max*discards,                  # max benefit in this scenario (thousands of fish)
             inc_benefit = max_benefit/(100-base_desc_pct),  # incremental benefit in thousands of fish
             calcd_benefit=max_benefit*descender_usage)
    
    #print("fish saved")
    #print(fishsaved$discards)

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
    ylabel = "Millions"
    chartdata <- scenariodata()
    if(scenariodata()$value[1] < .5){
      chartdata$value <- chartdata$value*1000
      ylabel <- "Thousands"
    }
    if(scenariodata()$value[1]==0){
      NULL
    }else{
      title <-paste0(if(length(input$region_scenario)==1){paste0(input$region_scenario[1]," ")}else{""},input$fishery_scenario," Released Alive with ",input$scenario_choice," of")
      r2d3(data=chartdata, script = "barchart.js", options =  list(scenario = input$scenario_choice,
                                                                        xLabel = "",
                                                                        yLabel = ylabel,
                                                                        title = title,
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
      "With a ", span(class = "narrative_emphasis",input$scenario_choice), " descender device usage rate, fish survival would have increased by ", 
      span(class = "narrative_emphasis", 
           paste0(
             if(round((scenariodata()$value[2]/scenariodata()$value[1]-1)*100,0)==0){
               "<1"
             }else{
               round((scenariodata()$value[2]/scenariodata()$value[1]-1)*100,0)
             },
           "%")),
      if(input$years_scenario[1]==input$years_scenario[2]){paste0(" in ",input$years_scenario[1],".")}else{paste0(" from ",input$years_scenario[1]," to ",input$years_scenario[2],".")},
    )
    }
  })

  output$fish_saved_text <- renderUI({
    if(scenariodata()$value[1]==0){
      NULL
    }else{
      amount <- (scenariodata()$value[2]-scenariodata()$value[1])*1000000
      div(id = "fish-saved-block",
          if(input$fishery_scenario=="Red Snapper"){
            div(class = "fish-saved-image snapper")
          }else if(input$fishery_scenario=="Gag"){
            div(class = "fish-saved-image gag")
          }else{
            div(class = "fish-saved-image grouper")
          },
          div(id = "fish-saved-amount",
              format(if(amount<1000){round(amount,-2)}else{round(amount,-3)},
                big.mark=",")
          ),
          div(id = "fish-saved-title",
              paste0(input$fishery_scenario, " Saved"))
      )
    }
  })
  
  
  source_historical_data <- reactive(({
    read.csv('historical data.csv') %>%
      group_by(species,region,year) %>%
      summarise(discards = sum(discards),
                dead_disc = sum(dead_disc),
                landings = sum(landings)) %>%
      as_data_frame()
  }))
  
  historicaldata<-reactive({
    
    input_length <- length(input$fishery_historical)*length(input$region_historical)
    print(input_length)
    hist_data_filtered <- source_historical_data()%>%
      filter(species %in% input$fishery_historical,
             year >= input$years_historical[1],
             year <= input$years_historical[2],
             #sector1 %in% input$sector_historical | sector2 %in% input$sector_historical,
             region %in% input$region_historical
             )%>%
      add_count(year) %>%
      mutate(complete = (n == input_length))
    
    print(hist_data_filtered,n=200)
    
    #filter based on user inputs
    summed_data <- hist_data_filtered %>% group_by(year) %>%
      summarise(tot_discards = sum(discards),
                tot_dead = sum(dead_disc),
                tot_landings = sum(landings),
                type = "",
                yearnumeric = 0,
                complete = sum(complete)>0
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
    print('region hist')
    print(input$region_historical)
    print(length(input$region_historical))
    title <- paste0(if(length(input$region_historical)==1){paste0(input$region_historical[1]," ")}else{""},input$fishery_historical," Released and Kept")
    subtitle <- if(input$years_historical[1]==input$years_historical[2]){input$years_historical[1]}else{paste0(input$years_historical[1]," - ",input$years_historical[2])}
    
    r2d3(data=historicaldata(), script = "areachart.js",options = list(title = title,
                                                                       subtitle = subtitle,
                                                                       yLabel = "Millions",
                                                                       x_min = input$years_historical[1],
                                                                       x_max = input$years_historical[2]
                                                                       ))
  })
  
  
  
  
  output$historicaldatadownload <- downloadHandler(
    filename = function() {
      paste0('Historical Data', '.xlsx')
    },
    content = function(file) {

      data <- select(read.csv('historical data.csv'),!(fill:sector2))
      

      #write to the excel file
      fname <- "Historical Data Template.xlsx"
      wb <- openxlsx::loadWorkbook(fname)
      writeData(wb,"Sheet1",data,startRow=2,startCol=1,colNames=F)

      openxlsx::saveWorkbook(wb, file,overwrite = T)
      
      removeModal()
      
    }
  )
  
  ##adjust slider input when selected species changes:
  observeEvent(c(input$fishery_historical),{
    hist_data_filtered <- source_historical_data()%>%
      filter(species %in% input$fishery_historical)
    print(hist_data_filtered)
    maxyear <- max(hist_data_filtered$year)
    minyear <- min(hist_data_filtered$year)
    #update year slider
    if(maxyear == -Inf){return(0)}
    # inputhighvalue <- if(input$years_historical[2] > maxyear){maxyear}else if(input$years_historical[2] < minyear){minyear}else{input$years_historical[2]}
    # inputlowvalue <- if(input$years_historical[1] > maxyear){maxyear}else if(input$years_historical[1] < minyear){minyear}else{input$years_historical[1]}
    
    gulf_years <- filter(hist_data_filtered, region == "Gulf")$year
    label_gulf <- paste0("Gulf (",min(gulf_years),"-",max(gulf_years),")")
    atlantic_years <- filter(hist_data_filtered, region == "Atlantic")$year
    label_atlantic <- paste0("Atlantic (",min(atlantic_years),"-",max(atlantic_years),")")
    
    #update region
    print(input$years_historical[2])
    hist_data_yearfiltered <- source_historical_data()%>%
      filter(species %in% input$fishery_historical,
                                     year >= minyear,
                                     year <= maxyear)
    
    updateSliderInput(session, "years_historical",value = c(minyear,maxyear),
                      min = minyear, max = maxyear)
    
    updateCheckboxGroupInput(session,"region_historical",choices = setNames(c("Gulf", "Atlantic"), c(label_gulf, label_atlantic)), selected = unique(hist_data_yearfiltered$region))
    
    #disable
    # updateCheckboxGroupInput(session,"region_historical",selected = unique(hist_data_yearfiltered$region))
    # if(!"Atlantic"%in%hist_data_yearfiltered$region){
    #   disable(selector = "#region_historical input[value='Atlantic']")
    # }
    # if(!"Gulf"%in%hist_data_yearfiltered$region){
    #   disable(selector = "#region_historical input[value='Gulf']")
    # }
    
    
  })
  

  observeEvent(c(input$fishery_scenario),{
    print(274)
    hist_data_filtered <- source_historical_data()%>%
      filter(species %in% input$fishery_scenario)
    maxyear <- max(hist_data_filtered$year)
    minyear <- min(hist_data_filtered$year)
    #print(maxyear)
    if(maxyear == -Inf){return(0)}
    # inputhighvalue <- if(input$years_scenario[2] > maxyear){maxyear}else if(input$years_scenario[2] < minyear){minyear}else{input$years_scenario[2]}
    # inputlowvalue <- if(input$years_scenario[1] > maxyear){maxyear}else if(input$years_scenario[1] < minyear){minyear}else{input$years_scenario[1]}
    
    gulf_years <- filter(hist_data_filtered, region == "Gulf")$year
    label_gulf <- paste0("Gulf (",min(gulf_years),"-",max(gulf_years),")")
    atlantic_years <- filter(hist_data_filtered, region == "Atlantic")$year
    label_atlantic <- paste0("Atlantic (",min(atlantic_years),"-",max(atlantic_years),")")
    
    updateSliderInput(session, "years_scenario",value = c(maxyear,maxyear),
                      min = minyear, max = maxyear)
    
    #update region
    scen_data_yearfiltered <- filter(source_historical_data(),
                                     species %in% input$fishery_scenario,
                                     year == maxyear)
    #print(scen_data_yearfiltered)
    print('re render region')
    updateCheckboxGroupInput(session,"region_scenario",choices = setNames(c("Gulf", "Atlantic"), c(label_gulf, label_atlantic)), selected = unique(scen_data_yearfiltered$region))
    
    # updateCheckboxGroupInput(session,"region_scenario",selected = unique(scen_data_yearfiltered$region))
    # if(!"Atlantic"%in%scen_data_yearfiltered$region){
    #   disable(selector = "#region_scenario input[value='Atlantic']")
    # }else{enable(selector = "#region_scenario input[value='Atlantic']")}
    # if(!"Gulf"%in%scen_data_yearfiltered$region){
    #   print('disable gulf')
    #   #runjs("$(\"#region_scenario input[value='Gulf']\").prop('disabled', true);")
    #   shinyjs::disable(id="region_scenario")
    #   shinyjs::disable(selector = "#region_scenario input[value='Gulf']")
    # }else{enable(selector = "#region_scenario input[value='Gulf']")}

  })
  
  #when region changes, update year options
  observeEvent(c(input$region_historical),ignoreInit = T,{
    hist_data_filtered <- source_historical_data()%>%
      filter(species %in% input$fishery_historical,
             region %in% input$region_historical)
    maxyear <- max(hist_data_filtered$year)
    minyear <- min(hist_data_filtered$year)
    #update year slider
    if(maxyear == -Inf){return(0)}
    inputhighvalue <- if(input$years_historical[2] > maxyear){maxyear}else if(input$years_historical[2] < minyear){minyear}else{input$years_historical[2]}
    inputlowvalue <- if(input$years_historical[1] > maxyear){maxyear}else if(input$years_historical[1] < minyear){minyear}else{input$years_historical[1]}
    updateSliderInput(session, "years_historical",value = c(inputlowvalue,inputhighvalue),
                      min = minyear, max = maxyear)
    
  })
  
  observeEvent(c(input$region_scenario),ignoreInit = T,{
    print(328)
    hist_data_filtered <- source_historical_data()%>%
      filter(species %in% input$fishery_scenario,
             region %in% input$region_scenario)
    maxyear <- max(hist_data_filtered$year)
    minyear <- min(hist_data_filtered$year)
    #update year slider
    if(maxyear == -Inf){return(0)}
    inputhighvalue <- if(input$years_scenario[2] > maxyear){maxyear}else if(input$years_scenario[2] < minyear){minyear}else{input$years_scenario[2]}
    inputlowvalue <- if(input$years_scenario[1] > maxyear){maxyear}else if(input$years_scenario[1] < minyear){minyear}else{input$years_scenario[1]}
    updateSliderInput(session, "years_scenario",value = c(inputlowvalue,inputhighvalue),
                      min = minyear, max = maxyear)
    
  })
  
  
  
  #when year changes, update region
  observeEvent(c(input$years_scenario),{
    print(347)
    hist_data_yearfiltered <- source_historical_data()%>%
      filter(species %in% input$fishery_scenario,
             year >= input$years_scenario[1],
             year <= input$years_scenario[2])
    region_options <- unique(hist_data_yearfiltered$region)
    selected_region <- if(input$region_scenario[1]%in%region_options){input$region_scenario}else{region_options}
    
    
    # updateCheckboxGroupInput(session,"region_scenario",selected = selected_region)
    # if(!"Atlantic"%in%region_options){
    #   disable(selector = "#region_scenario input[value='Atlantic']")
    # }else{enable(selector = "#region_scenario input[value='Atlantic']")}
    # if(!"Gulf"%in%region_options){
    #   disable(selector = "#region_scenario input[value='Gulf']")
    # }else{enable(selector = "#region_scenario input[value='Gulf']")}
    
    print('re render region')
    updateCheckboxGroupInput(session,"region_scenario",selected = selected_region)
    
    if(!"Atlantic"%in%region_options){
      disable(selector = "#region_scenario input[value='Atlantic']")
    }else{enable(selector = "#region_scenario input[value='Atlantic']")}
    if(!"Gulf"%in%region_options){
      print('disable gulf')
      #runjs("$(\"#region_scenario input[value='Gulf']\").prop('disabled', true);")
      shinyjs::disable(selector = "#region_scenario input[value='Gulf']")
    }else{enable(selector = "#region_scenario input[value='Gulf']")}
    
    
    #updateCheckboxGroupInput(session,"region_scenario",choices = region_options,selected = selected_region)
    
  })
  
  observeEvent(c(input$years_historical),ignoreInit = T,{
    hist_data_yearfiltered <- source_historical_data()%>%
      filter(species %in% input$fishery_historical,
             year >= input$years_historical[1],
             year <= input$years_historical[2])
    region_options <- unique(hist_data_yearfiltered$region)
    selected_region <- if(input$region_historical[1]%in%region_options){input$region_historical}else{region_options}
    
    updateCheckboxGroupInput(session,"region_historical",selected = selected_region)
    #updateCheckboxGroupInput(session,"region_historical",choices = region_options,selected = selected_region)
    
    #grey out if not applicable
    if(!"Atlantic"%in%region_options){
      disable(selector = "#region_historical input[value='Atlantic']")
    }else{enable(selector = "#region_historical input[value='Atlantic']")}
    if(!"Gulf"%in%region_options){
      print('disable gulf')
      #runjs("$(\"#region_scenario input[value='Gulf']\").prop('disabled', true);")
      shinyjs::disable(selector = "#region_historical input[value='Gulf']")
    }else{enable(selector = "#region_historical input[value='Gulf']")}
    
  })
  
  #make sure that region disabling works (need to do it when tab loads)
  observeEvent(c(input$navset,input$`toggle-filters-2`), {
    if(input$navset=="dd_panel"){
      hist_data_yearfiltered <- source_historical_data()%>%
        filter(species %in% input$fishery_scenario,
               year >= input$years_scenario[1],
               year <= input$years_scenario[2])
      region_options <- unique(hist_data_yearfiltered$region)
      
      if(!"Atlantic"%in%region_options){
        disable(selector = "#region_scenario input[value='Atlantic']")
      }else{enable(selector = "#region_scenario input[value='Atlantic']")}
      if(!"Gulf"%in%region_options){
        print('disable gulf')
        #runjs("$(\"#region_scenario input[value='Gulf']\").prop('disabled', true);")
        shinyjs::disable(selector = "#region_scenario input[value='Gulf']")
      }else{enable(selector = "#region_scenario input[value='Gulf']")}
    }
    
  })
  
  
  
  #make fishery filters sticky across tabs:
  
  observeEvent(input$fishery_historical,{
    updateRadioButtons(session,"fishery_scenario",selected = input$fishery_historical)
  })
  
  observeEvent(input$fishery_scenario,{
    updateRadioButtons(session,"fishery_historical",selected = input$fishery_scenario)
  })
  
  
}
