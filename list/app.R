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
            list(tags$h2("List of Available Lessons"),
            tags$table(style = "padding: 50%; width: 80%;",
            tags$tr(tags$th("Key"),tags$th("Name"),tags$th("Path")),
                apply(module_table[,list(title,lesson_key,url)],1,function(x){
                    tags$tr(
                        tags$td(x[2]),
                        tags$td(x[1]),
                        tags$td(tags$a(href=paste("..",x[3],collapse="",sep=""), x[3], target = "newtab"))

                    )
                }),
                )
    )})

}

# Run the application
shinyApp(ui = ui, server = server)
