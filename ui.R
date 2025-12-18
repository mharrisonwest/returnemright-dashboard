library(shiny)
library(bslib)
library(r2d3)
library(tidyverse)
library(shinyWidgets)
library(shinyjs)

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "stylesheet.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css?family=Montserrat:600"),
    tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css?family=Montserrat:400"),
    tags$script(src = "https://kit.fontawesome.com/1001e1ad31.js",crossorigin="anonymous")
    #tags$style("body{font-family:Montserrat}")
  ),
  
  navset_pill( 
    id="navset",
    nav_panel(span(class="tab_label",tags$img(class = "tabicon", src = "historical.png"),"HISTORICAL DISCARDS"),value = "historical_panel",
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
                         radioButtons(
                           "fishery_historical",
                           "FISHERY",
                           choices = list("Red Snapper" = "Red Snapper", "Gag" = "Gag", "Red Grouper" = "Red Grouper"),
                           selected = "Red Snapper"
                         ),
                         
                         sliderInput(
                           "years_historical",
                           "YEARS",
                           min = 2005,
                           max = 2023,
                           value = c(2005, 2023),
                           ticks = FALSE,
                           sep = ""
                         ),
                         
                         checkboxGroupInput(
                           "region_historical",
                           "REGIONS",
                           choices = list("Atlantic" = "Atlantic", "Gulf" = "Gulf"),
                           selected = c("Atlantic")
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
    
    
    nav_panel(span(class="tab_label",tags$img(class = "tabicon", src = "ddusage.png"),"DESCENDER DEVICE USE"),value = "dd_panel",
              useShinyjs(),
              ##DD Use Panel##
              fluidRow(
                
                div(class = "responsive-container",
                    
                    #toggle buttom (mobile only)
                    tags$button(
                      id = "toggle-filters-2",
                      class = "mobile-toggle",
                      "Show Filters"
                    ),
                
                ##Filters Section##
                column(4, id = "filters-panel-2", class = "filters-panel", wellPanel(

                  
                  # radioButtons("scenario_choice","Scenario",
                  #              choices = list("25%" = .25, "50%" = .5, "75%" = .75, "100%" = 1),
                  #              selected = .25
                  #              ),
                  
                  radioButtons(
                    "fishery_scenario",
                    "FISHERY",
                    choices = list("Red Snapper" = "Red Snapper", "Gag" = "Gag", "Red Grouper" = "Red Grouper"),
                    selected = "Red Snapper"
                  ),
                  
                  sliderInput(
                    "years_scenario",
                    "YEARS",
                    min = 2005,
                    max = 2023,
                    value = c(2023,2023),
                    ticks = FALSE,
                    sep = ""
                  ),
                  
                  checkboxGroupInput(
                    "region_scenario",
                    "REGIONS",
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
                  
                  
                  column(5, id="scenario-panel-middle", wellPanel(style = "padding:0",
                                                        
                    # sliderInput(
                    #   "scenario_choice",
                    #   "% OF ANGLERS USING DESCENDER DEVICE",
                    #   min = 0,
                    #   max = 100,
                    #   post = "%",
                    #   step = 25,
                    #   value = 25,
                    #   sep = ""
                    # ),
                    wellPanel(id = "scenario-choice-panel",
                        
                      sliderTextInput(
                        inputId = "scenario_choice", 
                        label = div("% OF ANGLERS USING DESCENDER DEVICE",div(class = "tooltip",tags$img(class = "infoicon", src = "info.png"),
                                    tags$span(class="tooltiptext","The “% anglers using descender devices” slider lets you simulate how many additional fish would survive if that share of releases used a descending device. For example, selecting 50% estimates the added survival if half of releases used one. Adjust the slider to compare different adoption-rate scenarios."))
                        ), 
                        grid = TRUE, 
                        force_edges = TRUE,
                        choices = c(
                          "25%",
                          "50%",
                          "75%", 
                          "100%"
                        )
                      ),
                    ),
                    
                    ##d3 scenario chart here
                    uiOutput("fish_saved_text"),
                    #uiOutput("nodatatext")
                  )),
                  ##Text Section##
                  column(6, wellPanel(id="scenariochartpanel",
                    d3Output(height = "500px", "scenariochart"),
                    br(),
                    div(id = "fish-saved-narrative",
                        uiOutput("selected_scenario")
                    )
                    
                  ))
                )
                
              )
             
    )),##End DD Use Panel##
    
    ##about page panel##
    nav_panel(span(class="tab_label",tags$img(class = "tabicon", src = "info.png"),"ABOUT"),value = "about_panel",
              useShinyjs(),
              fluidRow(column(12,wellPanel(id="about-page",
                 column(7,
                        tags$button(class="accordion active",tags$i(class="fas fa-chevron-up accordion-arrow"),"About This Return ’Em Right Discard Dashboard"),
                        div(class="panel",style="display: block;",
                            p("This dashboard tool visualizes trends in recreational reef fish discards in the Gulf of America (formerly known as the Gulf of Mexico) and South Atlantic, and the benefits of using descending devices. "),
                            p("It shows historical patterns in releases and survival and provides science-based estimates of the potential benefits of adopting best release practices to reef fish fisheries. "),
                            p("The data presented in this dashboard are not collected directly by Return ’Em Right. They are compiled from federal and state monitoring programs and from fishery-independent studies. These data are synthesized and visualized here to improve accessibility and understanding of discard trends across regions and fisheries."),
                            p(tags$i("Developed by Return ‘Em Right with funding through the Deepwater Horizon Natural Resources Damage Assessment settlement. ")),
                            #close panel from bottom
                            tags$button(class="accordion-bottom",tags$i(class="fas fa-chevron-up accordion-arrow")),
                            
                        ),
                        
                        
                        tags$button(class="accordion",tags$i(class="fas fa-chevron-down accordion-arrow"),"How to Use This Dashboard"),
                        div(class="panel",
                            p("Here’s how to use the Return ‘Em Right Discard Dashboard to explore trends and simulate descending device benefits. "),
                            tags$ol(
                              tags$li(tags$b("Select filters"),
                                      p("At the top of the dashboard (left-hand side for desktop) you’ll see filter controls. These let you choose what data to view:"),
                                      tags$ul(
                                        tags$li("Fishery / Species – e.g. red snapper, gag, red grouper"),
                                        tags$li("Years – range of years to display"),
                                        tags$li("Region – Gulf and Atlantic"),
                                        tags$li("% of Anglers Using Descender Devices - (for the Descender Device Use tab) options like 25%, 50%, 75%, 100% ")
                                      ),
                                      br(),
                                      div(style = "margin-left:50px", tags$b("Example:"),"If you want to see trends for red snapper in the Gulf from 2005 to 2017, set “Fishery = Red Snapper,” “Region = Gulf,” “Years = 2005-2017.” Then move to tabs to see historical discard metrics and descending device simulation.")
                              ),
                              tags$li(tags$b("Historical Discards Tab"),
                                      p("Once filters are set, here you’ll see:"),
                                      tags$ul(
                                        tags$li("Time-series plots of dead upon release, released alive, and fish kept"),
                                        tags$li("If you hover over a year, you may see specific details for that year")
                                      ),
                                      tags$br()
                              ),
                              tags$li(tags$b("Descender Device Use Tab"),
                                      p("Switch to the “Descender Device Use” tab to explore simulation of maximum potential survival benefits under different adoption rate scenarios. "),
                                      tags$ul(
                                        tags$li("Use the same filters (species, years, region) or change them based on your interests"),
                                        tags$li("Then choose a “% anglers using descender devices” (say 50%)"),
                                        tags$li("The dashboard will estimate the additional number of fish surviving if that percentage of releases used a descending device"),
                                        tags$li("You can easily change between usage rates to compare results"),
                                      ),
                                      tags$br()
                              ),
                              tags$li(tags$b("Interpreting the Outputs"),
                                      p("Outputs from this tool can be used to assess how big a portion of discards die, how much descender device usage could improve post-release survival, and trends over time or differences across regions. "),
                                      tags$ul(
                                        tags$li("Dead upon release – fish estimated to die after release"),
                                        tags$li("Released alive – fish estimated to survive release"),
                                        tags$li("Fish kept – landings (fish retained or harvested)"),
                                        tags$li("Historical – number of estimated fish released alive based on stock assessments for the selected time period"),
                                        tags$li("Total fish saved – additional fish saved under descending device usage scenarios"),
                                      ),
                                      tags$br()
                                      
                              ),
                              tags$li(tags$b("Download Data"),
                                      p("Below you will find a link to download historical data. Click on this link to download the underlying data in a .xlsx format. Keeping in mind the limitations described above, you may use this data for reporting, further analysis, or presentations. "),
                                      a(id="download_data_excel","Download Historical Data")
                                      #downloadLink("historical_data_download_1", label = "Download Historical Data")
                              ),
                              tags$li(tags$b("Comparing Scenarios"),
                                      tags$ul(
                                        tags$li("Try different years to see how discard mortality has changed over time"),
                                        tags$li("Compare regions (Gulf vs. Atlantic) for the same species"),
                                        tags$li("In the Descender Device Use tab, see how survival benefits scale with increasing adoption"),
                                        tags$li("Use this to inform outreach and education efforts"),
                                      ),
                                      tags$br()
                                      
                              ),
                              tags$li(tags$b("Tips and Best Practices"),
                                      tags$ul(
                                        tags$li("Consider beginning with a specific year to see current rates, then zoom out to broader year ranges to see long-term trends"),
                                        tags$li("Always look at both historical and descender tabs as the baseline trends give context to the descender benefit"),
                                        tags$li("Exercise caution when interpreting results for years or species with limited data"),
                                        tags$li("Reference the other sections of the “About” tab to understand the assumptions and methods behind the calculations"),
                                      ),
                                      
                              ),
                              
                              
                            ),
                            #close panel from bottom
                            tags$button(class="accordion-bottom",tags$i(class="fas fa-chevron-up accordion-arrow")),
                            
                        ),
                        
                        tags$button(class="accordion",tags$i(class="fas fa-chevron-down accordion-arrow"),"Dashboard Methods and Data"),
                        div(class="panel",
                            p("The following sections explain how the discard, landings, and survival estimates were calculated for this tool. "),
                            h5("Historical Discards"),
                            p(tags$b("Data sources: "),"Data on annual discards (releases) and landings were provided by NOAA by year by sector and region (Table 1). These data were used as inputs by the most recent stock assessment for each species and region (Gulf of America [hereafter ‘Gulf’] or South Atlantic [hereafter ‘Atlantic’]). Additionally, Gulf estimates were categorized as open or closed season and by area (east, central, west) for red snapper only. Data were categorized by sectors and regions used for the stock assessments and are aggregated by region, sector, and season for the purpose of display in this tool. "),
                            p("The following estimates are displayed: "),
                            tags$ol(class = "small-list",
                                    tags$li("Dead Upon Release – the number of fish discarded that are estimated to have died. This was calculated by multiplying the discards by the discard mortality estimate used in the stock assessment. "),
                                    tags$li("Released Alive – The number of fish released that were estimated to live. This was calculated by subtracting the fish ‘dead upon release’ from the total discards. "),
                                    tags$li("Fish Kept – Landings provided by NOAA. "),
                            ),
                            
                            div(style="overflow-x: auto",
                                tags$table(
                                  tags$caption("Table 1. Summary of discard data provided and most recent stock assessment reference for each fishery and region."),
                                  tags$tbody(
                                    tags$tr(
                                      tags$th("Region"),
                                      tags$th("Species"),
                                      tags$th("Years"),
                                      tags$th("Sector categories"),
                                      tags$th("Stock assessment"),
                                    ),
                                    tags$tr(
                                      tags$td(rowspan=3,tags$b("Atlantic")),
                                      tags$td("Gag"),
                                      tags$td("1981-2019"),
                                      tags$td("Headboat, Private-Charter"),
                                      tags$td("SEDAR 71 (2021)"),
                                    ),
                                    tags$tr(
                                      #tags$td(class="placeholder"),
                                      tags$td("Red Grouper"),
                                      tags$td("1976-2015"),
                                      tags$td("Headboat, Private-Charter"),
                                      tags$td("SEDAR 53 (2016)"),
                                    ),
                                    tags$tr(
                                      #tags$td(class="placeholder"),
                                      tags$td("Red Snapper"),
                                      tags$td("1955-2023"),
                                      tags$td("Headboat, Private-Charter"),
                                      tags$td("SEDAR 73 (2021)"),
                                    ),
                                    tags$tr(
                                      tags$td(rowspan=3,tags$b("Gulf")),
                                      tags$td("Gag"),
                                      tags$td("1963-2019"),
                                      tags$td("Private, Charter, Headboat"),
                                      tags$td("SEDAR 72 (2021)"),
                                    ),
                                    tags$tr(
                                      #tags$td(class="placeholder"),
                                      tags$td("Red Snapper"),
                                      tags$td("1950-2019"),
                                      tags$td("Private, Charter, Headboat"),
                                      tags$td("SEDAR 74 (2023)"),
                                    ),
                                    tags$tr(
                                      #tags$td(class="placeholder"),
                                      tags$td("Red Grouper"),
                                      tags$td("1986-2022"),
                                      tags$td("General Recreational"),
                                      tags$td("SEDAR 88 (2025)"),
                                    ),
                                  )
                                )
                            ),

                            tags$br(),
                            h5("Descender Device Use"),
                            p("Information shown in this tab provides an estimate of the number of fish that would have survived release each year under different levels of descender device use. Estimates were derived by combining empirical data on fish condition at release with research comparing mortality rates between fish released with descending devices and those released at the surface. Using methods similar to Vecchio et al. (2020, 2022), which were incorporated into the most recent red snapper stock assessments, these data were used to estimate population-wide mortality rates under varying descending device-use scenarios. Observer data describing the frequency of fish released in different conditions were then applied to estimate potential benefits, assuming a linear relationship between survival benefit and device usage. Estimates are provided for specific years of data based on the historical releases reported (data from the ‘Historical Discards’ tab). "),
                            h5("Maximum Benefit Scenario (100% Use Across All Fisheries and Regions)"),
                            p("Because the underlying data used in this dashboard are not always directly comparable across species and regions, users cannot select all species, all regions, and all years at once. For example, red snapper data extend to 2019 in the Gulf, but to 2023 in the Atlantic. Some fisheries separate for-hire sectors, while others group them. "),
                            p("To address these differences, we developed a separate compiled estimate of what the potential benefits would be if:"),
                            tags$ul(
                              tags$li("All fisheries and regions were combined"),
                              tags$li("All years of available data were included, and"),
                              tags$li("All anglers used descending devices on every discard (100% adoption)"),
                            ),
                            p("This scenario represents the maximum potential benefit of what could be achieved. It is not selectable through the dashboard filters but is provided here as a benchmark for understanding the full potential scale of survival benefits. "),
                            p("Under these assumptions, the analysis estimates that ",span(style="font-weight:bold;text-decoration: underline;font-size:16px","34 MILLION")," additional fish could have survived under 100% descender use across all Gulf and Atlantic red snapper, red  grouper, and gag fisheries from 2005 to 2023. "),
                            h5("Quota Context: Understanding Total Fish Saved"),
                            p("To illustrate scale, the 2025 Gulf recreational red snapper quota was 7,991,900 lb (whole weight). Using a representative 8–11 lb average weight implies roughly 700,000 to 1 million fish equivalent. Comparing our “total fish saved” estimates to this order of magnitude shows how discard mortality (and potential savings from descender use) relate to what anglers are allowed to harvest."),
                            
                            #close panel from bottom
                            tags$button(class="accordion-bottom",tags$i(class="fas fa-chevron-up accordion-arrow")),
                            
                        ),
                        tags$button(class="accordion",tags$i(class="fas fa-chevron-down accordion-arrow"),"Data Limitations"),
                        div(class="panel",
                            p("While this dashboard provides the best available estimates, it does have limitations. "),
                            tags$ul(
                              tags$li("Data availability varies – not all species or regions have full coverage across the years of data displayed in the tool. "),
                              tags$li("Mortality rates uncertainty – rates are estimates and vary by fishing method, depth, and condition of fish upon release. Research studies were not available for all species; therefore, mortality rate differences for gag and red grouper were inferred from red snapper studies."),
                              tags$li("Survey differences – MRIP, SRHS, state programs, and observer data use different methods. Results should be interpreted with caution when comparing these estimates with other sources of data. "),
                              tags$li("Updates – data are updated annually at best and may not reflect the current season. "),
                              tags$li("Simplification for display –this dashboard shows data that have been aggregated across regions and/or fisheries for accessibility."),
                            ),
                            #close panel from bottom
                            tags$button(class="accordion-bottom",tags$i(class="fas fa-chevron-up accordion-arrow")),
                            
                            
                        ),
                        tags$button(class="accordion",tags$i(class="fas fa-chevron-down accordion-arrow"),"Supporting Resources"),
                        div(class="panel",
                            p("Links to research, stock assessments, and Return ‘Em Right sources can be found here:"),
                            tags$ul(
                              tags$li(tags$a(href = "https://returnemright.org/",target="blank","Return ‘Em Right website")),
                              tags$li(tags$a(href = "https://sedarweb.org/sedar-assessments/",target="blank","Stock Assessments documents")," for red snapper, red grouper, and gag. Specific documents that were especially helpful for this effort include: ",
                                      tags$ul(class = "links-sublist",
                                              tags$li(tags$a(href = "https://sedarweb.org/documents/sedar-90-dw-15-a-meta-analysis-of-immediate-and-delayed-discard-mortality-of-red-snapper-lutjanus-campechanus-in-the-gulf-of-america-formerly-the-gulf-of-mexico/",target="blank","Ramsay, C., M. D. Campbell, and B. Sauls. 2025. A meta-analysis of immediate and delayed discard mortality of red snapper (Lutjanus campechanus) in the Gulf of America (formerly the Gulf of Mexico). SEDAR90-DW-15. SEDAR, North Charleston, SC. 38 pp.")),
                                              tags$li(tags$a(href = "https://sedarweb.org/documents/sedar-74-dw-06-a-description-of-floridas-gulf-coast-recreational-fishery-and-release-mortality-estimates-for-the-central-and-eastern-subregions-mississippi-alabama-and-florida-with-varyi/",target="blank","Vecchio, J. L., D. Lazarre, B. Sauls, M. Head, and T. Montcrief. 2022. A description of Florida’s Gulf Coast recreational fishery and release mortality estimates for the central and eastern subrgions (Mississippi, Alabama, and Florida) with varying levels of descender use. SEDAR74-DW-6, SEDAR, North Charleston, SC. 27 pp.")),
                                              tags$li(tags$a(href = "https://sedarweb.org/documents/sedar-73-wp15-utility-and-usage-of-descender-devices-in-the-red-snapper-recreational-fishery-in-the-south-atlantic-revised-12-4-2020/",target="blank","Vecchio, J., D. Lazarre, and B. Sauls. 2020. Utility and Usage of Descender Devices in the Red Snapper Recreational Fishery in the South Atlantic. SEDAR73-WP15, SEDAR, North Charleston, SC. 16 pp. ")),
                                      )
                              ),
                              tags$li("Research studies informing mortality and recompression benefits:",
                                      tags$ul(class = "links-sublist",
                                              tags$li(tags$a(href = "https://digitalcommons.usf.edu/etd/8319/",target="blank","Ayala, O. 2020, March 20. Testing the Efficacy of Recompression Tools to Reduce the Discard Mortality of Reef Fishes in the Gulf of Mexico. Thesis, University of South Florida, Tampa, FL. ")),
                                              tags$li(tags$a(href = "https://doi.org/10.1093/icesjms/fsz202",target="blank","Bohaboy, E. C., T. L. Guttridge, N. Hammerschlag, M. P. M. Van Zinnicq Bergmann, and W. F. Patterson III. 2020. Application of three-dimensional acoustic telemetry to assess the effects of rapid recompression on reef fish discard mortality. ICES Journal of Marine Science 77:83–96. ")),
                                              tags$li(tags$a(href = "https://doi.org/10.1080/19425120.2015.1074968",target="blank","Curtis, J. M., M. W. Johnson, S. L. Diamond, and G. W. Stunz. 2015. Quantifying Delayed Mortality from Barotrauma Impairment in Discarded Red Snapper Using Acoustic Telemetry. Marine and Coastal Fisheries 7:434–449. ")),
                                              tags$li("Diamond, S., T. Hendrick-Hopper, G. W. Stunz, M. Johnson, and J. Curtis. 2011. Reducing Discard Mortality in the Recreational Fisheries using Descender Hooks and Rapid Recompression. Final Report."),
                                              tags$li(tags$a(href = "https://doi.org/10.1080/19425120.2014.920746",target="blank","Drumhiller, K. L., M. W. Johnson, S. L. Diamond, M. M. Reese Robillard, and G. W. Stunz. 2014. Venting or Rapid Recompression Increase Survival and Improve Recovery of Red Snapper with Barotrauma. Marine and Coastal Fisheries 6:190–199. ")),
                                              tags$li(tags$a(href = "https://doi.org/10.1016/j.fishres.2025.107524",target="blank","Ramsay, C., M. D. Campbell, and B. Sauls. 2025. A meta-analysis of immediate and delayed discard mortality of red snapper (Lutjanus campechanus). Fisheries Research 291:107524. ")),
                                              tags$li(tags$a(href = "https://doi.org/10.1002/mcf2.10175",target="blank","Runde, B. J., N. M. Bacheler, K. W. Shertzer, P. J. Rudershausen, B. Sauls, and J. A. Buckel. 2021. Discard Mortality of Red Snapper Released with Descender Devices in the U.S. South Atlantic. Marine and Coastal Fisheries 13:478–495. ")),
                                              tags$li(tags$a(href = "https://doi.org/10.1093/najfmt/vqaf012",target="blank","Rudershausen, P. J., B. J. Runde, R. M. Tharp, J. H. Merrell, N. M. Bacheler, W. F. Patterson III, and J. A. Buckel. 2025. Discard mortality rates of Red Snapper after barotrauma and hook trauma: Insights from using acoustic telemetry in the U.S. South Atlantic. North American Journal of Fisheries Management 45:270–282. ")),
                                              tags$li("Stunz et al. 2017. Techniques for Minimizing Discard Mortality of Gulf of Mexico Red Snapper and Validating Survival with Acoustic Telemetry. Final Report for BREP Grant NA14NMF4720326. Corpus Christi, TX. 69 pp. "),
                                              tags$li(tags$a(href = "https://tamucc-ir.tdl.org/items/a4a8212d-ea3b-4371-9246-99584c58f64b",target="blank","Tompkins, A. K. 2017. Utility of rapid compression devices in the Gulf of Mexico red snapper fishery. Thesis. Texas A&M University. ")),
                                              tags$li(tags$a(href = "http://hdl.handle.net/10415/4909 ",target="blank","Williams-Grove, L. J. 2015. Red Snapper, Lutjanus campechanus, Mortality, Movements, and Habitat Use Based on Advanced Telemetry Methods. Dissertation, Auburn University, Auburn, AL. ")),
                                              
                                      )
                              ),
                            ),
                            #close panel from bottom
                            tags$button(class="accordion-bottom",tags$i(class="fas fa-chevron-up accordion-arrow")),
                            
                            
                        ),
                        tags$button(class="accordion active",tags$i(class="fas fa-chevron-up accordion-arrow"),"Credits"),
                        div(class="panel",style="display: block;",
                            p("Created by Return ‘Em Right and Industrial Economics, Incorporated. Data compiled by Research Planning, Inc. Original dashboard developed by John Froeschke with support from the Gulf Council. "),
                            p("Funding through the Deepwater Horizon Natural Resource Damage Assessment settlement, ",tags$a(href = "https://www.gulfspillrestoration.noaa.gov/project?id=226",target="blank","Return 'Em Right - Reducing Post-release Mortality project"),"."),
                            #close panel from bottom
                            tags$button(class="accordion-bottom",tags$i(class="fas fa-chevron-up accordion-arrow")),
                            
                        ),
                        tags$button(class="accordion",tags$i(class="fas fa-chevron-up accordion-arrow"),"Contact"),
                        div(class="panel",style="display: block;",
                            p("Have questions or need additional information? Get in touch with the project team. "),
                            p("Charlie Robertson",
                              tags$br(),
                              "Fisheries & Sport Fish Restoration Coordinator",
                              tags$br(),
                              "Gulf States Marine Fisheries Commission",
                              tags$br(),
                              tags$a(href="mailto:charlie.robertson@gsmfc.org",target="blank","charlie.robertson@gsmfc.org")
                            ),
                            #close panel from bottom
                            tags$button(class="accordion-bottom",tags$i(class="fas fa-chevron-up accordion-arrow")),
                            
                        ),
                        downloadLink("historical_data_download_1", label = ""),
                        
                 ),
                 column(5,
                        tags$img(style="width:100%;margin-top: 15px;",src = "about page image.jpg")
                 )

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
          toggleBtn1.textContent = 'Hide Filters';
        } else {
          filters1.classList.add('mobile-hidden');
          toggleBtn1.textContent = 'Show Filters';
        }
      });
    
      // Toggle function for second tab
      toggleBtn2.addEventListener('click', function () {
        if (!isMobile()) return;
        var filtersHidden = filters2.classList.contains('mobile-hidden');
        if (filtersHidden) {
          filters2.classList.remove('mobile-hidden');
          toggleBtn2.textContent = 'Hide Filters';
        } else {
          filters2.classList.add('mobile-hidden');
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
    
    // make accordion collapse
    
    var acc = document.getElementsByClassName('accordion');
    var i;
    
    for (i = 0; i < acc.length; i++) {
      acc[i].addEventListener('click', function() {
        /* Toggle between adding and removing the 'active' class,
        to highlight the button that controls the panel */
        this.classList.toggle('active');
    
        /* Toggle between hiding and showing the active panel */
        var panel = this.nextElementSibling;
        if (panel.style.display === 'block') {
          panel.style.display = 'none';
        } else {
          panel.style.display = 'block';
        }
      });
    }
    
    // make accordion collapse from bottom
    
    var acc = document.getElementsByClassName('accordion-bottom');
    var i;
    
    for (i = 0; i < acc.length; i++) {
      acc[i].addEventListener('click', function() {
        /* Toggle between adding and removing the 'active' class,
        to highlight the button that controls the panel */
        this.classList.toggle('active');
    
        /* Toggle between hiding and showing the active panel */
        var panel = this.parentElement;
        if (panel.style.display === 'block') {
          panel.style.display = 'none';
        } else {
          panel.style.display = 'block';
        }
      });
    }
    
    // make arrow rotate
    
    var accordionHeaders = document.querySelectorAll('.accordion');

    accordionHeaders.forEach(header => {
      header.addEventListener('click', () => {
        var arrow = header.querySelector('.accordion-arrow');
        // Toggle the 'rotate' class on the arrow
        arrow.classList.toggle('rotate');
    
      });
    });
    
    // make arrow rotate from bottom
    
    var accordionHeaders = document.querySelectorAll('.accordion-bottom');

    accordionHeaders.forEach(header => {
      header.addEventListener('click', () => {
        var arrow = header.parentElement.previousElementSibling.querySelector('.accordion-arrow');
        // Toggle the 'rotate' class on the arrow
        arrow.classList.toggle('rotate');
    
      });
    });
    
    
    document.addEventListener('DOMContentLoaded', function () {
          var excel_download = document.getElementById('download_data_excel');
          excel_download.addEventListener('click', function () {
            var downloadhandlerbutton = document.getElementById('historical_data_download_1');
            downloadhandlerbutton.click();
          });

    });




  "))

  
)