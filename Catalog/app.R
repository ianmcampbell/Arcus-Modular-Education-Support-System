#Lesson Catalog
library(shiny)
library(RCurl)
library(data.table)
library(magrittr)
library(DT)

#module_table <- fread("ModuleTable.csv")
module_table <- fread("../ModuleTable/ModuleTable.csv")
createLink <- function(url,text) {
    sprintf(paste0('<a href="..', URLdecode(url),'" target="_blank">', substr(text, 1, 40) ,'</a>'))
}
module_table[,Link := apply(module_table,1,function(x){createLink(url = x["url"], text = x["title"])})]
module_table[,lesson_key := NULL]
LessonGroups <- module_table[,unique(group)]
setnames(module_table,"group","Group")
setnames(module_table,"title","Title")
module_table <- module_table[,list(Link, Group)]
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
          list(fluidRow(titlePanel("ALEx Lesson Catalog")),
          fluidRow(column(tags$h3("Filter by Group:"),checkboxGroupInput(inputId = "group", label = NULL, choices = LessonGroups, selected = FALSE, inline = FALSE, width="100%"),width=3),column(
            #Place the title
            DT::renderDataTable({
                if(is.null(input$group)){RenderTable <- module_table}
                else {RenderTable <- module_table[Group %in% input$group,]}
                DT::datatable(RenderTable,options = list(pageLength = 25),escape = FALSE, rownames= FALSE)
                })
            ,width=9)))})
}





# Run the application
shinyApp(ui = ui, server = server)