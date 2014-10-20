library(shiny)

source("chooser.R")

shinyUI(navbarPage(
  header=includeScript("www/js/jquery-ui.custom.min.js"),
  "OpenMx IFA Model Builder",
  tabPanel(
    "Data",
    sidebarLayout(
      sidebarPanel(
        fileInput('file1', 'Choose CSV File',
                  accept=c('text/csv', 
                           'text/comma-separated-values,text/plain', 
                           '.csv')),
        tags$hr(),
        checkboxInput('dataHeader', 'Header?', TRUE),
        checkboxInput('dataRowNames', 'Row names?', TRUE),
        radioButtons('dataSep', 'Separator',
                     c(Comma=',',
                       Semicolon=';',
                       Tab='\t'),
                     ','),
        radioButtons('dataQuote', 'Quote',
                     c(None='',
                       'Double Quote'='"',
                       'Single Quote'="'"),
                     '"'),
        tags$hr(),
        helpText("Load example data"),
        actionButton("exampleDataKCT", label = "KCT"),
        actionButton("exampleDataScience", label = "Science")
      ),
      mainPanel(
        tabsetPanel(id="dataPreviewTabset",
                    tabPanel("First 6 rows", value="front",
                             tags$p("Data file:"),
                             verbatimTextOutput("nameOfDataFile"),
                             tags$p("Number of rows:"),
                             verbatimTextOutput("numberOfDataRows"),
                             hr(),
                             tableOutput('dataContents')),
                    tabPanel("Item summary",
                             selectInput("freqColumnName", label = "Row frequency column:",
                                         choices="No data loaded"),
                             hr(),
                             tableOutput('dataSummary')))
      )
    )
  ),
  tabPanel("Outcomes",
           sidebarLayout(
             sidebarPanel(
               selectInput("focusedOutcomeSet", label = "Outcome set:",
                           choices="No data loaded"),
               selectInput("focusedOutcomeItem", label = "Item:",
                           choices="No data loaded"),
               tags$hr(),
               textInput("newOutcomeName", label = "Add outcome"),
               actionButton("addNewOutcomeAction", label = "Add It"),
               textOutput("addNewOutcomeActionFeedback"),
               tags$hr(),
               selectInput("focusedOutcomeMapFrom", label="Recode from",
                           choices="No outcomes loaded"),
               selectInput("focusedOutcomeMapTo", label="to",
                           choices="No outcomes loaded"),
               conditionalPanel('input.focusedOutcomeMapTo == "<Rename>"',
                                textInput("focusedOutcomeRenameTo", label = "New name")),
               actionButton("focusedOutcomeMapAction", label = "Add mapping"),
               textOutput("focusedOutcomeMapActionFeedback"),
               tags$hr(),
               numericInput("focusedRecodeRule", "Recode Rule", value=1, step=1),
               actionButton("resetRecodeAction", label = "Discard"),
               textOutput("resetRecodeActionFeedback")
             ),
             mainPanel(
               tabsetPanel(
                 tabPanel("Recode",
                          helpText("Currently selected outcomes:"),
                          tableOutput("focusedOutcomeTable"),
                          helpText("Recode Table:"),
                          tableOutput("recodeTable")
                 ),
                 tabPanel("Reorder",
                          wellPanel(helpText(
                            "Drag to reorder.",
                            "The standard order is from incorrect (upper) ",
                            "to correct (lower) or from least (upper) to",
                            "most (lower). Exceptional items that use the",
                            "opposite order can be marked as reversed",
                            "on the next tab."),
                            uiOutput('reorderOutcomesSorterUI')),
                          helpText("Permutation Table:"),
                          tableOutput("permuteTable")
                 ),
                 tabPanel("Reverse",
                          helpText("This is not working yet."),
                          chooserInput("mychooser", "Available frobs", "Selected frobs",
                                       row.names(USArrests), c(), size = 10, multiple = TRUE
                          )
                 ),
                 tabPanel("Import/Export",
                          helpText("You can store the recoding table, outcome orders,",
                                   "and items marked as reversed in a separate file",
                                   "to reuse with similar analyses."),
                          downloadButton('downloadCoding', 'Download'),
                          tags$hr(),
                          fileInput('codingFile', paste('Choose a setting save file from',
                                                        'which to restore the settings'),
                                    accept=c('text/plain', '.R')),
                          textOutput("codingFileFeedback")
                 )
               )
             ))),
  tabPanel("Model",
           sidebarLayout(
             sidebarPanel(
               selectInput("focusedItem", label = "Edit item:",
                           choices="No data loaded"),
               selectInput("focusedItemModel", label = "Model:",
                           choices=c('drm', 'grm', 'nrm')),
               selectInput("focusedItemParameter", label = "Parameter:",
                           choices="No item selected"),
               selectInput("focusedParameterFree", label = "Free",
                           choices="No parameter selected"),
               textInput("focusedParameterLabel", label = "Label"),
               actionButton("changeLabelAction", label = "Set Label"),
               conditionalPanel('input.focusedItemModel == "drm"',
                                selectInput("focusedParameterPrior", label = "Prior",
                                            "logit normal", "beta"))
             ),
             mainPanel(tabsetPanel(
               tabPanel("Factors",
                        # TODO change back to sliderInput
                        sliderInput("numFactors", "Number of factors:",
                                    min=1, max=5, value=1),
                        textInput("nameOfFactor1", "Factor 1"),
                        textInput("nameOfFactor2", "Factor 2"),
                        textInput("nameOfFactor3", "Factor 3"),
                        textInput("nameOfFactor4", "Factor 4"),
                        textInput("nameOfFactor5", "Factor 5")),
               tabPanel("Model", tableOutput('itemModelAssignment')),
               tabPanel("Parameters",
                        helpText("Starting values"),
                        tableOutput('itemStartingValuesTable'),
                        helpText("Is free?"),
                        tableOutput('itemFreeTable'),
                        helpText("Labels"),
                        tableOutput('itemLabelTable'),
                        helpText("Bayesian prior"),
                        tableOutput('itemPriorTable'))
               ))
           )),
  tabPanel("Preview",
           actionButton("debugScriptAction", label = "Refresh!"),
           verbatimTextOutput("debugScriptOutput")),
  tabPanel("Download", sidebarLayout(
    sidebarPanel(
      checkboxInput("showFitProgress", label = "Show model fitting progress", value = TRUE),
      checkboxInput("fitReferenceModels", label = "Fit reference models (for more fit statistics)",
                    value = FALSE),
      selectInput("infoMethod", "Information matrix method:", 
                  choices = c("Oakes (1999)", "Meat", "Agile SEM", "*none*")),
      downloadButton('downloadScript', 'Download')
    ),
    mainPanel(
      withTags(ol(
        li('Download your analysis script.'),
        li('Open it in RStudio.'),
        li('Update the pathname to your data (if necessary).'),
        li('Click the Knit/HTML button at the top of your document.')
      )),
      withTags(p(br(),br(),br(),br(),br(),br(),br(),br(),br()))
    )
  ))

))