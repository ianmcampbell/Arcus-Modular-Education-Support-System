#Lesson Generator
library(shiny)
library(RCurl)
library(htmlwidgets)
library(data.table)
library(dplyr)
library(shinyjqui)
library(DT)
#Source functions for URL encoding and decoding
source("URL-Encode.R")

ui <- fluidPage(
    uiOutput("page_output")
)

server <- function(input, output, session) {

  #Load tables from disk
  module_table <- fread("ModuleTable.csv")
  #module_table <- fread("/Users/campbellim/Arcus/Lessons/ModuleTable.csv")
  curricula_table <- fread("CurriculaTable.csv")
  #curricula_table <- fread("/Users/campbellim/Arcus/Curricula/CurriculaTable.csv")

  master_table <- rbind(curricula_table[,list(type="Curriculum",key=curriculum_key,title,default_modules)],module_table[,list(type="Module",key=lesson_key,title,default_modules=NA)])
  master_table[,display:=paste0(type,": ",title)]
  setkey(master_table,display)
  vals<-reactiveValues()
  vals$Data<- master_table[,list(type,title,key)]
  values <- reactiveValues(selected_items=vector(),selected_type=vector(),current_modules=vector(),modules_per_curriculum=vector())
        output$page_output <- renderUI({

        fluidRow(column("",width=2),column(
        titlePanel("Custom Learning Plan Generation"),
        tags$h3("Learner Name:"),
        textInput("name", label = ""),
        tags$h3("Custom Message:"),
        textAreaInput("message", label = "", width = "400px",height = "200px"),
        tags$h3("Select Personae, Curricula and Modules:"),
        checkboxInput(inputId = "default_modules",label = "Use Default Modules in Curricula",value = FALSE),
        fluidRow(
          column(selectizeInput(inputId = "main_input", label="Curricula", choices = master_table[type=="Curriculum",display], multiple = TRUE),width=6),
          column(selectizeInput(inputId = "module_input", label="Modules", choices = master_table[type=="Module",display], multiple = TRUE),width=6)
          ),
        #renderTable(master_table[values$selected_items,list(type,title,key)]),
        dataTableOutput("Main_table"),
        actionButton("clear", "Clear"),
        actionButton("gen", "Generate URL"),
        tags$br(),
        tags$br(),
        tags$h3("Custom URL:"),
        textInput("url_holder", label = "", value = "",width="70%")
        , width=8),column("",width=2),
        tags$script("$(document).on('click', '#Main_table button', function () {
                    Shiny.onInputChange('lastClickId',this.id);
                    Shiny.onInputChange('lastClick', Math.random())
  });"))
    })

        output$Main_table<-renderDataTable({
          if(length(values$selected_items)==0){DT <- as.data.table(list(type=rep("",2),title=rep("",2),key=rep("",2)))}
          else {DT=master_table[values$selected_items,list(type,title,key)]}


          DT[["Actions"]]<-
            paste0('
             <div class="btn-group" role="group" aria-label="Basic example">
                <button type="button" class="btn btn-secondary up"id=up_',1:nrow(master_table[values$selected_items,]),'>⬆︎</button>
                <button type="button" class="btn btn-secondary down"id=down_',1:nrow(master_table[values$selected_items,]),'>⬇︎</button>
                <button type="button" class="btn btn-secondary delete" id=delete_',1:nrow(master_table[values$selected_items,]),'>✕︎</button>
             </div>

             ')
          datatable(DT,
                    escape=F,rownames=F,options = list(dom='t',ordering=F,pageLength=-1))}
        )

    observeEvent(input$main_input,{
        values$selected_type <<- master_table[input$main_input,type]

        #If use default modues, load default modules and add them with selected curriculum
        if(input$default_modules == TRUE & values$selected_type == "Curriculum")
        {
            current_default_modules <- master_table[input$main_input,default_modules] %>%
                                       strsplit(.,split=",") %>%
                                       unlist %>%
                                       as.numeric
            values$current_modules <- c(input$main_input,master_table[type == "Module"][match(current_default_modules,key),display])
            values$selected_items <<- append(values$selected_items,values$current_modules)
        }
        #Otherwise, just add the selection directly
        else
        {values$selected_items <<- append(values$selected_items,input$main_input)}

        #Calculate the modules per curriculum
        values$modules_per_curriculum <<- master_table[values$selected_items,type] %>%
                                          split(., cumsum(.=="Curriculum")) %>%
                                          sapply(.,function(x){sum(x=="Module")}) %>%
                                          paste0(.,collapse = ",")

        updateSelectizeInput(session, "main_input", selected = "")
    })

    observeEvent(input$lastClick,
                 {
                   if (input$lastClickId%like%"delete")
                   {
                     row_to_del=as.numeric(gsub("delete_","",input$lastClickId))
                     #vals$Data=vals$Data[-row_to_del]
                     values$selected_items=values$selected_items[-row_to_del]
                   }
                   else if (input$lastClickId%like%"up")
                   {
                     row_to_up=as.numeric(gsub("up_","",input$lastClickId))
                     raiseRow <- function(vec,pos){
                       temp <- vec ;
                       if(pos == 1) {return(vec)}
                       else if (pos > length(vec)) {return(vec)}
                       else { temp[pos-1] <- pos; temp[pos] <- vec[pos-1]; return(temp)}
                     }
                     new_order <- raiseRow(1:nrow(master_table[values$selected_items,]),row_to_up)
                     #vals$Data=vals$Data[new_order]
                     values$selected_items=values$selected_items[new_order]
                   }
                   else if (input$lastClickId%like%"down")
                   {
                     row_to_down=as.numeric(gsub("down_","",input$lastClickId))
                     lowerRow <- function(vec,pos){
                       temp <- vec ;
                       if(pos >= length(vec)) {return(vec)}
                       else {temp[pos+1] <- pos; temp[pos] <- vec[pos+1]; return(temp)}
                     }
                     new_order <- lowerRow(1:nrow(master_table[values$selected_items,]),row_to_down)
                     #vals$Data=vals$Data[new_order]
                     values$selected_items=values$selected_items[new_order]
                   }
                 }
    )

    observeEvent(input$module_input,{
      values$selected_type <<- master_table[input$module_input,type]

      values$selected_items <<- append(values$selected_items,input$module_input)

      #Calculate the modules per curriculum
      values$modules_per_curriculum <<- master_table[values$selected_items,type] %>%
        split(., cumsum(.=="Curriculum")) %>%
        sapply(.,function(x){sum(x=="Module")}) %>%
        paste0(.,collapse = ",")

      updateSelectizeInput(session, "module_input", selected = "")
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
