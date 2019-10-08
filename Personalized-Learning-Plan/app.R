library(shiny)
library(RCurl)
library(data.table)
library(dplyr)

#Source functions for URL encoding of lesson plans and user names
source("URL-Encode.R")

#Source function to render additional Rmd files in the same Shiny App (uses dplyr)
source("Rmd-Render.R")

#Load the lesson and curricula table from disk
module_table <- fread("ModuleTable.csv")
curricula_table <- fread("CurriculaTable.csv")

#Convert default modules to a list of numeric vectors
curricula_table[ , default_modules := sapply(curricula_table$default_modules,function(x){as.numeric(unlist(strsplit(x,",")))})]

ui <- fluidPage(
    uiOutput("page_output")
)

server <- function(input, output, session) {


output$page_output <- renderUI({

    #Query the URL for paramters
    query <- parseQueryString(session$clientData$url_search)

    #Return and decode the student's name from Base64 and prepare for rendering
    learner_name <- query[["userid"]]
    if(is.null(learner_name))
       {title_string <- "Personalized Learning Plan"}
    else
    {title_string <- paste0(urlsafebase64decode(learner_name),"'s Personalized Learning Plan")}

    #Load module list from URL; otherwise, leave NULL
    module_url_list <- query[["modules"]]
    if(is.null(module_url_list)) {
      module_list <- NULL
      }
    else
    {module_list <- decode_lessons(module_url_list)}

    #Load curriculua list from URL; otherwise, supply default
    curricula_url_list <- query[["curricula"]]
    if(is.null(curricula_url_list))
       {curricula_list <- c(101,103)}
    else {
      curricula_list <- decode_lessons(curricula_url_list)
    }

    #Load module-splitting instructions from URL; otherwise leave null
    curricula_url_split <- query[["modulesplit"]]
    if(!is.null(curricula_url_split)) {
      curricula_split <- urlsafebase64decode(curricula_url_split)
      curricula_split <- as.numeric(unlist(strsplit(curricula_split,",")))
      }
    else {
      curricula_split <- NULL
    }

    #If no module list is supplied, return modules based on curricula, either from the URL or default
    if(is.null(module_list))    {
      curricula_to_render <- curricula_table[match(curricula_list,curricula_table$curriculum_key),list(filename,default_modules)]
      curricula_to_render <- split(curricula_to_render,1:nrow(curricula_to_render))
    }
    #If only one curriculum is supplied, and modules are, render all modules for the single curriculum
    else if (length(curricula_list) == 1 & !is.null(module_list)) {
      curricula_to_render <- list(
        data.table(filename = curricula_table[match(curricula_list,curricula_table$curriculum_key),]$filename,
                   default_modules = list(module_list)))
    }
    else {
      # Split module list by the curricula split from URL ?modules=sI57jADDtheVzgSi1N&curricula=6Qdh5&modulesplit=MTAsMSww
      split_module_list <- list()
      for( i in 1:length(curricula_split)){
        stop.ind <- sum(curricula_split[1:i])
        start.ind <- stop.ind - curricula_split[i] + 1
        if(start.ind - 1 == stop.ind)
        {split_module_list[[i]] <- 100}
        else
        {split_module_list[[i]] <- module_list[start.ind:stop.ind]}
      }
      filenames <- curricula_table[match(curricula_list,curricula_table$curriculum_key),]$filename
      curricula_to_render <- data.table(filename=filenames,default_modules=split_module_list)
      curricula_to_render <- split(curricula_to_render,1:nrow(curricula_to_render))
    }

    #Initiate a fluid row, with columns to improve formatting
    fluidRow(column("",width=2),column(
      #Place the title

      titlePanel(title_string),

      #Open a div to improve formating
        tags$div(
          #Insert module from Learning-Modules.R
          # Add custom message if present
          if(!is.null(query[["message"]])){urlsafebase64decode(query[["message"]])} else {""},
          tags$br(),

          #Curricula and module links are created dynamically. This function expects a list of length N where N curricula ploted
          #Each list element should be a 1x2 data.table. The first element should be the relative file path to the curriculum Rmd file.
          #The second element should be a numeric vector with the IDs of the modules to link that match entries in ModuleTable.txt
          #If no module links are required for a curriculum, a numeric vector of length 1 containing the integer 100 should be provided
          lapply(curricula_to_render,function(x){
                   curriculum_filename <- x[[1]]
                   curriculum_module_list <- x[[2]]
                   list(inclRmd(curriculum_filename),
                   #If curriculum needs links, insert section for browser based learning modules
                    if(unlist(curriculum_module_list)[1] != 100){
                    student_lessons <- module_table[match(unlist(curriculum_module_list),lesson_key), ]
                    list(tags$h3("Curriculum"),
                    "Here is a list of lessons we chose based on your stated goals. They can be completed in any modern browser. Your progress is saved and you can return at any time.",
                     tags$br(),
                    tags$div(
                      #Generate URLs from the selected rows of the lessons table
                      apply(cbind(seq(1,nrow(student_lessons)),student_lessons[,list(title,url)]),1,function(x){list(tags$a(href=x[3], paste(c("Lesson ",x[1],": ",x[2]),collapse = ""), target = "newtab"),tags$br())})
                      , style = "font-size:20px; margin-left:5%"))}
                  else {
                    ""
                    }
                                                               )}),

          tags$h2("Join the R User Group"),
          "If you haven’t already, consider joining the CHOP R User Group, where you will find cookies (the edible ones), coffee, conversations, presentations, and help with your code. We have a newsletter to announce upcoming gatherings (usually held semimonthly) and an active slack user group.",
          tags$a(href="https://bit.ly/chop-r)",tags$img(src = "chop-r.gif",width = "225px", height="150px", style="display: block; margin-left: auto; margin-right: auto;")),
          tags$img(src = "footer.png"),

          # Style for div
          style = "font-size:15px")


      , width=8),column("",width=2))
})
}

shinyApp(ui = ui, server = server)
