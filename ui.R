library(shiny)
library(bslib)
library(r2d3)
library(tidyverse)

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "stylesheet.css")
  ),
  
  
  navset_pill( 
    nav_panel("Historical Discards",
    ##Historical Panel##
    fluidRow(
      
      ##Filters Section##
      column(4,wellPanel(
                         h3("Filters"),
                         
                         checkboxGroupInput(
                           "fishery_historical",
                           "Fishery",
                           choices = list("Red Snapper" = "snapper", "Gag" = "gag", "Red Grouper" = "grouper"),
                           selected = "snapper"
                         ),
                         
                         sliderInput(
                           "years_historical",
                           "Years",
                           min = 2005,
                           max = 2023,
                           value = c(2005, 2023),
                           ticks = FALSE,
                           sep = ""
                         ),
                         
                         checkboxGroupInput(
                           "region_historical",
                           "Regions",
                           choices = list("Atlantic" = "atlantic", "Gulf" = "gulf"),
                           selected = c("atlantic","gulf")
                         ),
                         
                         checkboxGroupInput(
                           "sector_historical",
                           "Sector",
                           choices = list("For Hire (Charter & Headboats)" = "forhire", "Private" = "private"),
                           selected = c("forhire","private")
                         )
                         
      )),
      
      ##Graph Section##
      column(8,wellPanel(
            d3Output("historicalchart")             
      ))
      
    )
    
    ),##End Historical Panel##
    nav_panel("Descender Device Use",
              
              
    
              ##DD Use Panel##
              fluidRow(
                
                ##Filters Section##
                column(4,wellPanel(
                  h3("Filters"),
                  
                  h4(style="width: 140px","% of Anglers Using Descender Devices"),
                  div(class = "radio-button",
                      tags$input(type = "radio",name="scenario_choice", id="scenario_1", value="25", checked="checked"),
                      tags$label('for'="scenario_1","25%"),
                      tags$input(type = "radio",name="scenario_choice", id="scenario_2", value="50"),
                      tags$label('for'="scenario_2","50%"),
                      br(),
                      tags$input(type = "radio",name="scenario_choice", id="scenario_3", value="75"),
                      tags$label('for'="scenario_3","75%"),
                      tags$input(type = "radio",name="scenario_choice", id="scenario_4", value="100"),
                      tags$label('for'="scenario_4","100%")
                      
                  ),
                  
                  checkboxGroupInput(
                    "fishery_scenario",
                    "Fishery",
                    choices = list("Red Snapper" = "snapper", "Gag" = "gag", "Red Grouper" = "grouper"),
                    selected = "snapper"
                  ),
                  
                  sliderInput(
                    "years_scenario",
                    "Years",
                    min = 2005,
                    max = 2023,
                    value = c(2005, 2023),
                    ticks = FALSE,
                    sep = ""
                  ),
                  
                  checkboxGroupInput(
                    "region_scenario",
                    "Regions",
                    choices = list("Atlantic" = "atlantic", "Gulf" = "gulf"),
                    selected = c("atlantic","gulf")
                  ),
                  
                  checkboxGroupInput(
                    "sector_scenario",
                    "Sector",
                    choices = list("For Hire (Charter & Headboats)" = "forhire", "Private" = "private"),
                    selected = c("forhire","private")
                  )
                  
                )),
                
                ##Graph Section##
                column(4,wellPanel(
                  ##d3 scenario chart here
                  d3Output("scenariochart")
                  
                )),
                
                ##Text Section##
                column(4,wellPanel(
                  "text here"

                  
                ))
                
                
              )
             
    ),##End DD Use Panel##
    nav_panel("About", "About page content")
  )
  
)