library(shiny)
library(RCurl)
library(htmlwidgets)
library(data.table)
library(dplyr)
library(shinyjqui)
#Source functions for URL encoding and decoding
source("URL-Encode.R")

#Load tables from disk
module_table <- fread("ModuleTable.csv")
curricula_table <- fread("CurriculaTable.csv")
master_table <- rbind(curricula_table[,list(type="Curriculum",key=curriculum_key,title,default_modules)],module_table[,list(type="Module",key=lesson_key,title,default_modules=NA)])
master_table[,display:=paste0(type,": ",title)]
setkey(master_table,display)

values <- reactiveValues(selected_items=vector(),selected_type=vector(),current_modules=vector(),modules_per_curriculum=vector())

ui <- fluidPage(
    uiOutput("page_output")
)

server <- function(input, output, session) {

        output$page_output <- renderUI({

        fluidRow(column("",width=2),column(
        titlePanel("Custom Learning Plan Generation"),
        tags$h3("Learner Name:"),
        textInput("name", label = ""),
        tags$h3("Custom Message:"),
        textAreaInput("message", label = "", width = "400px",height = "200px"),
        tags$h3("Select Personae, Curricula and Modules:"),
        checkboxInput(inputId = "default_modules",label = "Use Default Modules in Curricula",value = TRUE),
        selectizeInput(inputId = "main_input", label="", choices = master_table$display, multiple = TRUE,width = "50%"),
        renderTable(master_table[values$selected_items,list(type,title,key)]),
        actionButton("clear", "Clear"),
        actionButton("gen", "Generate URL"),
        tags$br(),
        tags$br(),
        tags$h3("Custom URL:"),
        textInput("url_holder", label = "", value = "",width="70%")
        , width=8),column("",width=2))
    })

    observeEvent(input$main_input,{
        values$selected_type <<- master_table[input$main_input,type]

        #If use default modues, load default modules and add them with selected curriculum
        if(input$default_modules == TRUE & values$selected_type == "Curriculum")
        {
            current_default_modules <- master_table[input$main_input,default_modules] %>%
                                       strsplit(.,split=",") %>%
                                       unlist %>%
                                       as.numeric
            values$current_modules <- c(input$main_input,master_table[type == "Module" & key %in% current_default_modules,display])
            values$selected_items <<- append(values$selected_items,values$current_modules)
        }
        #Otherwise, just added the selection directly
        else
        {values$selected_items <<- append(values$selected_items,input$main_input)}

        #Calculate the modules per curriculum
        values$modules_per_curriculum <<- master_table[values$selected_items,type] %>%
                                          split(., cumsum(.=="Curriculum")) %>%
                                          sapply(.,function(x){sum(x=="Module")}) %>%
                                          paste0(.,collapse = ",")

        updateSelectizeInput(session, "main_input", selected = "")
    })

    observeEvent( input$clear,{
      values$selected_items <<- vector()
    })
    observeEvent( input$gen,{
        #Encode the learner's name to Base64
        encoded_name <- urlsafebase64encode(input$name)
        #Encode message to Base64
        encoded_message <- urlsafebase64encode(input$message)

        #Encode module list
        encoded_module_list <- master_table[values$selected_items][type=="Module",key] %>%
                               encode_lessons(.)

        #Encode curricula list
        encoded_curricula_list <- master_table[values$selected_items][type=="Curriculum",key] %>%
                               encode_lessons(.)
        #Encode curricula split
        encoded_modulesplit <- urlsafebase64encode(values$modules_per_curriculum)

        if(nchar(encoded_name) > 1){name_url_element <- paste0("userid=",encoded_name,"&")} else {name_url_element <- ""}
        if(nchar(encoded_message) > 1){message_url_element <- paste0("&message=",encoded_message)} else {message_url_element <- ""}
        if(nchar(encoded_module_list) > 1){module_url_element <- paste0("&modules=",encoded_module_list)} else {module_url_element <- ""}
        if(nchar(encoded_curricula_list) > 1){curricula_url_element <- paste0("&curricula=",encoded_curricula_list)} else {curricula_url_element <- ""}
        if(nchar(encoded_modulesplit) > 2){modulesplit_url_element <- paste0("&modulesplit=",encoded_modulesplit)} else {modulesplit_url_element <- ""}
        URL <- paste0("http://www.a-mess.org/Personalized-Learning-Plan/?",
                      name_url_element,
                      message_url_element,
                      module_url_element,
                      curricula_url_element,
                      modulesplit_url_element,collapse = "")
        updateTextInput(session, "url_holder", value = URL)
    }
    )
}

shinyApp(ui = ui, server = server)
