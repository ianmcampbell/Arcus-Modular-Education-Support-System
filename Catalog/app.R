#Lesson Catalog
library(shiny)
library(RCurl)
library(data.table)
library(magrittr)
library(DT)

#module_table <- fread("ModuleTable.csv")
module_table <- fread("../ModuleTable/ModuleTable.csv")
createLink <- function(val) {
    sprintf(paste0('<a href="..', URLdecode(val),'" target="_blank">', substr(val, 1, 40) ,'</a>'))
}
module_table[,url := sapply(url,createLink)]
module_table[,lesson_key := NULL]
LessonGroups <- module_table[,unique(group)]
setnames(module_table,c("Group","Title","Link"))
values <- reactiveValues()
values$RenderTable <- module_table
# Define UI for application that draws a histogram
ui <- fluidPage(
    includeCSS("www/bootstrap.min.css"),
    includeCSS("www/flexdashboard.min.css"),
    includeCSS("www/style.css"),
    uiOutput("page_output")

)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$page_output <- renderUI({
        fluidRow(column("",width=1),column(
            #Place the title
            titlePanel("ALEx Lesson Catalog"),
            tags$h3("Filter by Group:"),
            checkboxGroupInput(inputId = "group", label = NULL, choices = LessonGroups, selected = FALSE, inline = TRUE, width="100%"),
            renderText(input$group),
            DT::renderDataTable({
                if(is.null(input$group)){RenderTable <- module_table}
                else {RenderTable <- module_table[Group %in% input$group,]}
                DT::datatable(RenderTable,options = list(pageLength = 25),escape = FALSE)
                })
            ,width=10),column("",width=1))})

}



# Run the application
shinyApp(ui = ui, server = server)