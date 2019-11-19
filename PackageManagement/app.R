#PackageManagement
library(shiny)
library(RCurl)
library(data.table)
library(magrittr)
library(DT)


ui <- fluidPage(

    uiOutput("page_output")

)

server <- function(input, output) {
    InstalledPackages <- as.data.table(installed.packages()[,c(1,3)])
    AvailablePackages <- as.data.table(available.packages(repo="cran.rstudio.com")[,c(1,2)])

    values <- reactiveValues(installed=InstalledPackages,available=AvailablePackages,viewInstalled=FALSE,searchTerm="",toInstall="",install=FALSE,command="",search=FALSE,done="")

    output$page_output <- renderUI({
        list(tags$h2("Review Installed Packages"),
             paste0("There are ",nrow(values$installed)," installed packages."),tags$br(),tags$br(),
             if(values$viewInstalled){renderTable(values$installed)} else {""},
             actionButton("viewInstalled", "Review"),tags$br(),tags$br(),
             tags$h2("Install New Package"),
             textInput(inputId = "searchTerm",label = "Package to Install"),tags$br(),
             actionButton("search", "Search for Package"),tags$br(),tags$br(),
             if(values$search & values$toInstall!=""){list(paste0("Found package: ",values$toInstall),tags$br(),tags$br())}
             else if (values$search & values$toInstall==""){list(paste0("Unable to find package patching: ",values$searchTerm),tags$br(),tags$br())}
             else {""},
             if(values$search & values$toInstall!=""){list(actionButton("install", "Install Package to Server"),tags$br())} else {""},tags$br(),
             if(values$done != ""){list(paste0("Result of system command: $ ",values$command),tags$br(),HTML(values$done))} else {""},
             tags$br()
        )
    })

    observeEvent(input$viewInstalled,{
           values$viewInstalled <<- TRUE
    })

    observeEvent(input$search,{
        values$searchTerm <<- input$searchTerm
        Ind <- match(values$searchTerm,AvailablePackages$Package)
        if(!is.na(Ind)){values$toInstall <- AvailablePackages$Package[Ind]}
        values$search <- TRUE
    })


    observeEvent(input$install,{
        values$command <- paste0('-e "install.packages(',"'",values$toInstall,"'",", repo='cran.rstudio.com')",'"')
        values$done <- withProgress(expr = {system2("R", values$command, stdout = FALSE, stderr = TRUE)},message = "Please wait. Package installation attempt in progress.")
        values$done <- values$done %>% .[(grep("={10,}",.)+3):(length(.)-2)]
        values$done <- paste(values$done,collapse="<br>")
    })
}

# Run the application
shinyApp(ui = ui, server = server)
