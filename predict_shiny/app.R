#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(naivebayes)

load('prediction.rda')
load('namematch_table.rda')

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput( 
                "gender", 
                "Select gender:", 
                list("Any" = "Any", "Male" = "men", "Female" = "women")
                ),
                selectInput(
                    "ethnicity",
                    "Select ethnicity:",
                    list("Any" = "Any", 
                         "American Indian or Alaska Native"="American Indian or Alaska Native",
                         "Asian"="Asian",
                         "Black or African American"="Black or African American",
                         "Hispanic"="Hispanic",
                         "Native Hawaiian or Other Pacific Islander"="Native Hawaiian or Other Pacific Islander",
                         "International (non-US)"="Nonresident alien",
                         "White"="White")
                ),
                selectInput("origin", "Student from:", choices = c("Anywhere", sort(unique(prediction_bayes_model$data$x$students_from)))),
                selectInput("field", "Bachelors field of study:", choices = c("Any", sort(unique(prediction_bayes_model$data$x$field)))),
            numericInput("math_sat", "Math SAT score:", value=NA,
                        min = 200, max = 800, step = 10
            ),
            numericInput("reading_sat", "Reading SAT score:", value=NA,
                         min = 200, max = 800, step = 10
            ),
            numericInput("math_act", "Math ACT score:", value=NA,
                         min = 1, max = 36, step = 1
            ), 
            numericInput("english_act", "English ACT score:", value=NA,
                         min = 1, max = 36, step = 1
            )      
            
            ),
            
            # Show a plot of the generated distribution
            mainPanel(
                tableOutput("table")
            )
        )
    )
    
    # Define server logic required to draw a histogram
    server <- function(input, output) {
        
        ConvertUNITID_to_School <- function(UNITID, namematch_table) {
            return(subset(namematch_table, namematch_table$`UNITID Unique identification number of the institution`==UNITID)$`Institution entity name`[1])
        }
        
        
        output$table <- renderTable({
            gender_chosen <- input$gender
            if(gender_chosen=="Any") { gender_chosen <- NA }
            ethnicity_chosen <- input$ethnicity
            if(ethnicity_chosen=="Any") { ethnicity_chosen <- NA }
            students_from_chosen <- input$origin
            if(students_from_chosen=="Anywhere") { students_from_chosen <- NA }
            field_chosen <- input$field
            if(field_chosen=="Any") { field_chosen <- NA }
			
            math_sat_chosen <- input$math_sat
			try({
            if(math_sat_chosen < 200 | math_sat_chosen>800) {
                math_sat_chosen <- NA   
            }
			}, silent=TRUE)
			math_sat_chosen <- as.character(math_sat_chosen)
            
            reading_sat_chosen <- input$reading_sat
			try({
			if(reading_sat_chosen < 200 | reading_sat_chosen>800) {
				reading_sat_chosen <- NA   
			}
			}, silent=TRUE)
			reading_sat_chosen <- as.character(reading_sat_chosen)
			
			math_act_chosen <- input$math_act
			try({
				if(math_act_chosen < 1 | math_act_chosen>36) {
					math_act_chosen <- NA
				}
			}, silent=TRUE)
			math_act_chosen <- as.character(input$math_act)
			
			english_act_chosen <- input$english_act
			try({
			if(english_act_chosen < 1 | english_act_chosen>36) {
				english_act_chosen <- NA
			}
			}, silent=TRUE)
			english_act_chosen <- as.character(input$english_act)
			
            prediction <- t(predict(prediction_bayes_model, data.frame(
                ethnicity=ethnicity_chosen, 
                gender=gender_chosen, 
                students_from=students_from_chosen, 
                field=field_chosen,
                math_sat=math_sat_chosen,
                reading_sat=reading_sat_chosen,
                english_act=english_act_chosen,
                math_act=math_act_chosen
                ), type="prob" ))
            prediction <- prediction[order(prediction[,1], decreasing=TRUE),][sequence(50)]
            prediction_df <- data.frame(School=sapply(names(prediction), ConvertUNITID_to_School, namematch_table=namematch_table), Percentage=round(100*prediction,1), UNITID=names(prediction))
            prediction_df$School <- paste0("<a href='http://www.collegetables.info/", prediction_df$UNITID, ".html'>", prediction_df$School, "</a>")
            prediction_df$UNITID <- NULL
            prediction_df}, quoted=FALSE, sanitize.text.function = function(x){x})
    }
    
    # Run the application 
    shinyApp(ui = ui, server = server)
    