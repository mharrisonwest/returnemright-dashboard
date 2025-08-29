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
      column(4, style= "width:320px", wellPanel(
                         h3("Filters"),
                         
                         checkboxGroupInput(
                           "fishery_historical",
                           "Fishery",
                           choices = list("Red Snapper" = "Red Snapper", "Gag" = "Gag", "Red Grouper" = "Red Grouper"),
                           selected = "Red Snapper"
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
                           choices = list("Atlantic" = "Atlantic", "Gulf" = "Gulf"),
                           selected = c("Atlantic","Gulf")
                         ),
                         
                         checkboxGroupInput(
                           "sector_historical",
                           "Sector",
                           choices = list("For Hire (Charter & Headboats)" = "For Hire", "Private" = "Private"),
                           selected = c("For Hire","Private")
                         )
                         
      )),
      
      ##Graph Section##
      column(8, style= "max-width:800px", wellPanel(
            d3Output("historicalchart")             
      ))
      
    )
    
    ),##End Historical Panel##
    nav_panel("Descender Device Use",
              
              
    
              ##DD Use Panel##
              fluidRow(
                
                ##Filters Section##
                column(4, style= "width:320px", wellPanel(
                  h3("Filters"),
                  
                  h4(style="width: 140px","% of Anglers Using Descender Devices"),
                  div(class = "radio-button",
                      tags$input(type = "radio",name="scenario_choice", id="scenario_1", value=.25, checked="checked"),
                      tags$label('for'="scenario_1","25%"),
                      tags$input(type = "radio",name="scenario_choice", id="scenario_2", value=.5),
                      tags$label('for'="scenario_2","50%"),
                      br(),
                      tags$input(type = "radio",name="scenario_choice", id="scenario_3", value=.75),
                      tags$label('for'="scenario_3","75%"),
                      tags$input(type = "radio",name="scenario_choice", id="scenario_4", value=1),
                      tags$label('for'="scenario_4","100%")
                      
                  ),
                  tags$script(HTML("
                  $(document).on('shiny:connected', function(event) {
                      setTimeout(function() {
                        var checked = $('input[name=\"scenario_choice\"]:checked').val();
                        Shiny.setInputValue('scenario_choice', checked, {priority: 'event'});
                      }, 50);
                    });
                    $(document).on('change', 'input[name=\"scenario_choice\"]', function() {
                      Shiny.setInputValue('scenario_choice', this.value);
                    });
                  ")),
                  
                  checkboxGroupInput(
                    "fishery_scenario",
                    "Fishery",
                    choices = list("Red Snapper" = "Red Snapper", "Gag" = "Gag", "Red Grouper" = "Red Grouper"),
                    selected = "Red Snapper"
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
                    choices = list("Atlantic" = "Atlantic", "Gulf" = "Gulf"),
                    selected = c("Atlantic","Gulf")
                  ),
                  
                  checkboxGroupInput(
                    "sector_scenario",
                    "Sector",
                    choices = list("For Hire (Charter & Headboats)" = "For Hire", "Private" = "Private"),
                    selected = c("For Hire","Private")
                  )
                  
                )),
                
                ##Graph Section##
                column(5,wellPanel(style = "padding:0",
                  ##d3 scenario chart here
                  d3Output(height = "500px", "scenariochart")
                  
                )),
                
                ##Text Section##
                column(3,style = "padding:0", wellPanel(style = "margin:auto",
                  div(id = "fish-saved-block",
                    div(id = "fish-saved-title",
                      "Total Fish Saved"),
                    div(id = "fish-saved-amount",
                        uiOutput("fish_saved_text")
                        )
                  ),
                  br(),
                  div(id = "fish-saved-narrative",
                      uiOutput("selected_scenario")
                  )

                  
                ))
                
                
              )
             
    ),##End DD Use Panel##
    nav_panel("About", "About page content")
  )
  
)