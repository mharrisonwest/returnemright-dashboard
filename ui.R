library(shiny)
library(bslib)
library(r2d3)
library(tidyverse)

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "stylesheet.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css?family=Montserrat:700"),
    tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css?family=Montserrat:300")
  ),
  
  navset_pill( 
    nav_panel("Historical Discards",
    ##Historical Panel##
    fluidRow(
      
      div(class = "responsive-container",
          
          #toggle buttom (mobile only)
          tags$button(
            id = "toggle-filters",
            class = "mobile-toggle",
            "Show Filters"
          ),
      
      ##Filters Section##
      column(4,id = "filters-panel", class = "filters-panel", wellPanel(
                         h3("Filters"),
                         radioButtons(
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
                         )
                         
                         # checkboxGroupInput(
                         #   "sector_historical",
                         #   "Sector",
                         #   choices = list("For Hire" = "For Hire", "Private" = "Private"),
                         #   selected = c("For Hire","Private")
                         # )
                         
      )),
      
      ##Graph Section##
      column(8,id = "graph-panel", class = "graph-panel", style= "max-width:800px; aspect-ratio: 16 / 9;", wellPanel(
            d3Output("historicalchart")             
      ))
      )
      
    )
    
    ),##End Historical Panel##
    
    
    nav_panel("Descender Device Use",
              ##DD Use Panel##
              fluidRow(
                
                div(class = "responsive-container",
                    
                    #toggle buttom (mobile only)
                    # tags$button(
                    #   id = "toggle-filters-2",
                    #   class = "mobile-toggle",
                    #   "Show Filters"
                    # ),
                
                ##Filters Section##
                column(4, id = "filters-panel-2", class = "filters-panel", wellPanel(
                  h3("Filters"),
                  
                  h4(style="width: 320px","% of Anglers Using Descender Devices"),
                  div(class = "radio-button",
                      tags$input(type = "radio",name="scenario_choice", id="scenario_1", value=.25, checked="checked"),
                      tags$label('for'="scenario_1","25%"),
                      tags$input(type = "radio",name="scenario_choice", id="scenario_2", value=.5),
                      tags$label('for'="scenario_2","50%"),
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
                  
                  # radioButtons("scenario_choice","Scenario",
                  #              choices = list("25%" = .25, "50%" = .5, "75%" = .75, "100%" = 1),
                  #              selected = .25
                  #              ),
                  
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
                    value = c(2023,2023),
                    ticks = FALSE,
                    sep = ""
                  ),
                  
                  checkboxGroupInput(
                    "region_scenario",
                    "Regions",
                    choices = list("Atlantic" = "Atlantic", "Gulf" = "Gulf"),
                    selected = c("Atlantic","Gulf")
                  )
                  
                  # checkboxGroupInput(
                  #   "sector_scenario",
                  #   "Sector",
                  #   choices = list("For Hire" = "For Hire", "Private" = "Private"),
                  #   selected = c("For Hire","Private")
                  # )
                  
                )),
                
                div(id = "scenario-main-content",
                  ##Graph Section##
                  column(6,style="padding:0", wellPanel(style = "padding:0",
                    ##d3 scenario chart here
                    uiOutput("nodatatext"),
                    d3Output(height = "500px", "scenariochart")
                  )),
                  ##Text Section##
                  column(5, wellPanel(style = "margin:auto;padding:0",
                    uiOutput("fish_saved_text"),
                    br(),
                    div(id = "fish-saved-narrative",
                        uiOutput("selected_scenario")
                    )
                  ))
                )
                
              )
             
    )),##End DD Use Panel##
    
    ##about page panel##
    nav_panel("About",
              fluidRow(column(12,wellPanel(
                
                
                includeHTML("www/about-page.html"),
                
                
                
                
                
                
                downloadButton("historicaldatadownload", label = "Download Historical Data")
              )))
              )
  ),
  
  #new mobile viewing
  tags$script(HTML("
    document.addEventListener('DOMContentLoaded', function () {
      // Existing toggle for first tab
      var toggleBtn1 = document.getElementById('toggle-filters');
      var filters1 = document.getElementById('filters-panel');
      var graph1 = document.getElementById('graph-panel');
    
      var toggleBtn2 = document.getElementById('toggle-filters-2');
      var filters2 = document.getElementById('filters-panel-2');
      var mainContent2 = document.getElementById('scenario-main-content');
    
      function isMobile() {
        return window.innerWidth <= 768;
      }
    
      // Initial state for first tab
      if (isMobile()) {
        filters1.classList.add('mobile-hidden');
      }
    
      // Initial state for second tab
      if (isMobile()) {
        filters2.classList.add('mobile-hidden');
      }
    
      // Toggle function for first tab
      toggleBtn1.addEventListener('click', function () {
        if (!isMobile()) return;
        var filtersHidden = filters1.classList.contains('mobile-hidden');
        if (filtersHidden) {
          filters1.classList.remove('mobile-hidden');
          graph1.classList.add('mobile-hidden');
          toggleBtn1.textContent = 'Hide Filters';
        } else {
          filters1.classList.add('mobile-hidden');
          graph1.classList.remove('mobile-hidden');
          toggleBtn1.textContent = 'Show Filters';
        }
      });
    
      // Toggle function for second tab
      toggleBtn2.addEventListener('click', function () {
        if (!isMobile()) return;
        var filtersHidden = filters2.classList.contains('mobile-hidden');
        if (filtersHidden) {
          filters2.classList.remove('mobile-hidden');
          mainContent2.classList.add('mobile-hidden');
          toggleBtn2.textContent = 'Hide Filters';
        } else {
          filters2.classList.add('mobile-hidden');
          mainContent2.classList.remove('mobile-hidden');
          toggleBtn2.textContent = 'Show Filters';
          console.log('Re-binding Shiny on scenario-main-content');
          Shiny.bindAll(mainContent2);
        }
      });
    
      // Reset view on resize for both tabs
      window.addEventListener('resize', function () {
        if (!isMobile()) {
          filters1.classList.remove('mobile-hidden');
          graph1.classList.remove('mobile-hidden');
          toggleBtn1.style.display = 'none';
    
          filters2.classList.remove('mobile-hidden');
          mainContent2.classList.remove('mobile-hidden');
          toggleBtn2.style.display = 'none';
        } else {
          filters1.classList.add('mobile-hidden');
          graph1.classList.remove('mobile-hidden');
          toggleBtn1.style.display = 'block';
          toggleBtn1.textContent = 'Show Filters';
    
          filters2.classList.add('mobile-hidden');
          mainContent2.classList.remove('mobile-hidden');
          toggleBtn2.style.display = 'block';
          toggleBtn2.textContent = 'Show Filters';
        }
      });
    }); 
    
  "))

  
)