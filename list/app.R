#Lesson List
library(shiny)
library(RCurl)
library(data.table)
library(magrittr)

module_table <- fread("ModuleTable.csv")


# Define UI for application that draws a histogram
ui <- fluidPage(

    uiOutput("page_output")

)

# Define server logic required to draw a histogram
server <- function(input, output) {
    output$page_output <- renderUI({
        apply(module_table[,list(title,lesson_key,url)],1,function(x){
        list(tags$a(href=paste("../",x[3],collapse=""), paste(c("Lesson: ",x[1]," Key: ",x[2]),collapse = ""), target = "newtab"),
             tags$br() )
        })
    })

}

# Run the application
shinyApp(ui = ui, server = server)
