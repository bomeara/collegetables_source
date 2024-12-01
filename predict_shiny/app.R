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
    
    # Application title
    titlePanel("Predict college degrees"),
    "This shows where people with some of the same demographic information and/or field interest as you gotten degrees. This is not to say that you would not thrive at schools lower on the list: most people from Florida stay in state, but that doesn't mean that U. of Alaska wouldn't be a great place for a student from Florida, just that relatively fewer get degrees there than from U. of Florida. My goal with this is to let students look at places they might not otherwise consider.",
	
	"Note this table is about getting degrees, not overall enrollment: some schools enroll many students but most do not graduate, so those schools show up lower than you might expect. 
	
	This uses information from federal data, which considers gender as only male or female and only a particular set of ethnicities. 
	
	Federal data only includes 25th percentile and 75th percentile SAT and ACT scores; to help you get a better idea of where you might go, I estimate a distribution based on this, but it is only an estimate.
	
	This uses a naive Bayesian model to estimate the probabilities. This is a fairly simple model. Most importantly, it does not take into account, or even know, about interactions between terms.",
    
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
            prediction <- prediction[order(prediction[,1], decreasing=TRUE),][sequence(100)]
            prediction_df <- data.frame(School=sapply(names(prediction), ConvertUNITID_to_School, namematch_table=namematch_table), Percentage=round(100*prediction,1), UNITID=names(prediction))
            prediction_df$School <- paste0("<a href='collegetables.info/", prediction_df$UNITID, ".html'>", prediction_df$School, "</a>")
            prediction_df}, quoted=FALSE)
    }
    
    # Run the application 
    shinyApp(ui = ui, server = server)
    