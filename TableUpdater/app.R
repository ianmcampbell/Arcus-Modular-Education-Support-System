#Table Updater
library(shiny)
library(RCurl)
library(data.table)
library(magrittr)
library(DT)

# Define UI for application that draws a histogram
ui <- fluidPage(

    uiOutput("page_output")

    )

# Define server logic required to draw a histogram
server <- function(input, output) {
    system("git -C /srv/shiny-server/ModuleTable pull")
    module_table <- fread("/srv/shiny-server/ModuleTable/ModuleTable.csv")
    #module_table <- fread("~/Arcus/ModuleTable/ModuleTable.csv")
    #system("git -C ~/Arcus/ModuleTable pull")
    values <- reactiveValues(table=module_table,review=FALSE,pass=FALSE,error="",write=FALSE,pull=FALSE)

    output$page_output <- renderUI({
            list(tags$h2("Record to Add"),
                fluidRow(
                    column(textInput(inputId = "key",label = "Key"),width=1),
                    column(textInput(inputId = "group",label = "Group"),width=2),
                    column(textInput(inputId = "title",label = "Title"),width=4),
                    column(textInput(inputId = "url",label = "URL"),width=5)),
                actionButton("review", "Review"),tags$br(),tags$br(),
                if(values$review){list(renderTable(values$table),actionButton("commit", "Commit"))} else {""},
                if(values$error != ""){paste0("Error: ",values$error)} else {""},
                if(values$write){"Table updated."} else {""},tags$br(),tags$br(),tags$br(),tags$br(),
                actionButton("pull", "Pull Lesson Updates from GitHub"),tags$br(),
                if(values$pull){"Lesson updates pulled from GitHub"} else {""},
                tags$br()
            )
    })

    observeEvent(input$review,{
        NewValues <- data.table(lesson_key=input$key, group=input$group, title=input$title, url=input$url)
        values$write <<- FALSE
        values$error <<- ""
        # Error Checking
        NewValues[,lesson_key := as.integer(lesson_key)]
        if(!is.na(NewValues$lesson_key)){values$pass <<- TRUE}
        if(!(NewValues$lesson_key > 100 & NewValues$lesson_key < 1000 & values$pass)){values$pass <- FALSE; values$error <<- "Lesson Key must be an integer between 100 and 1000."}
        if(NewValues$lesson_key %in% module_table$lesson_key){values$pass <- FALSE; values$error <<- "Lesson Key cannot already be present in the table. See www.a-mess.org/list/"}
        if(nchar(input$url) < 3 | nchar(input$group) < 2 | nchar(input$title) < 3){values$pass <- FALSE; values$error <<- "Please fill in all fields."}
        if(nchar(input$group) > nchar(gsub("[[:punct:]]|[0-9]","",input$group))){values$pass <- FALSE; values$error <<- "Group must contain only characters and spaces."}
        if(nchar(input$title) > nchar(gsub("[[:punct:]]","",input$title))){values$pass <- FALSE; values$error <<- "Title must contain only characters, numbers and spaces."}
        if(nchar(input$url) > nchar(gsub("([/-])|[[:punct:]]| ","\\1",input$url))){values$pass <- FALSE; values$error <<- "Path must contain only characters, numbers and dashes."}
        if(nchar(input$url) - nchar(gsub("^/|/$","",input$url)) != 2){values$pass <- FALSE; values$error <<- "Path must begin and end in forward slash."}
        if(nchar(input$url) - nchar(gsub("/","",input$url)) > 2){values$pass <- FALSE; values$error <<- "Path must contain only 2 forward slashes."}

        if(values$pass){values$table <<- rbind(values$table,NewValues); values$review <<- TRUE; values$error <<- ""}

    })

    observeEvent(input$commit,{
        #write.csv(x = values$table, file = "~/Arcus/ModuleTable/ModuleTable.csv",row.names = FALSE,quote=c(2:4))
        write.csv(x = values$table, file = "/srv/shiny-server/ModuleTable/ModuleTable.csv",row.names = FALSE,quote=c(2:4))
        #system("git -C ~/Arcus/ModuleTable/ add ModuleTable.csv")
        system("git -C /srv/shiny-server/ModuleTable/ add ModuleTable.csv")
        #system('git -C ~/Arcus/ModuleTable/ commit -m "Commit from web app."')
        system('git -C /srv/shiny-server/ModuleTable/ -c user.name="a-mess-bot" -c user.email="a-mess-bot@a-mess.org" commit -m "Commit from web app."')
        #system("git -C ~/Arcus/ModuleTable/ push")
        system("git -C /srv/shiny-server/ModuleTable/ push")
        values$review <<- FALSE
        values$write <<- TRUE
    })


    observeEvent(input$pull,{
        system("git -C /srv/shiny-server/Lessons/ pull")
        system("ln -s /srv/shiny-server/Lessons/* /srv/shiny-server")
        values$pull <<- TRUE
    })
}

# Run the application
shinyApp(ui = ui, server = server)
