
library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Welcome to the ARCUS Modular Education Support System"),"Many people at CHOP have become interested in R and statistical analysis in R. For Arcus Education, creating a learning environment where 100% of attendees spend 100% of their time working towards their",tags$em("own"),"goals at their own pace is of utmost importance. In our workshops, each learner sets their own goals, ",tags$b("receives an individualized curriculum based on those goals,"),"and success is measured by the extent to which each learner meets their goals. Our workshop attendees have highly variable goals and are increasing in number.",
    tags$br(),tags$br(),"Below you will find examples of how our system can provide this customized experience while being easily accessible anywhere in the world and maintaining reasonable throughput.",
    tags$h3("R Beginner"),
    "Here is an example lesson plan for a user who is just getting started with R. It covers the absolute basics including classes, logic, functions and graphics.",
    tags$br(),tags$br(),
    a("Example R Beginner Lesson Plan",href="../Personalized-Learning-Plan/?&modules=sHXtfjmhu84EQfHM7VpLV&curricula=qiJ&modulesplit=MTMsMA~~"),
    tags$h3("Introduction to Statistics in R"),
    "Here is an example lesson plan for a user with some familiarity with R but who wants to learn to perform statistical analysis. It covers some fundamentals as well as practical application of statistical tests in R.",
    tags$br(),tags$br(),
    a("Example Statistics Lesson Plan",href="../Personalized-Learning-Plan/?&modules=yoyXvAlV&curricula=qyR&modulesplit=NSww"),
    tags$h3("Example Lessons"),
    "Here are some additional example lessons",
    tags$br(),tags$br(),
    a("Basic Building Blocks",href="../swirl-basic-building-blocks/"),tags$br(),tags$br(),
    a("Variables",href="../sb-variables/"),tags$br(),tags$br(),
    a("Correlation and Linear Regression",href="../sb-correlation-and-linear-regression/"),
    tags$h3("Lessons in Other Programming Languages"),
    "Although our initial emphasis has been placed on the R programming language, we are cognizant that other languages and subjects need to be taught. Here is an extremely brief example of an exercise in Python. We continue to consider the optimal way to present other languages.",
    tags$br(),tags$br(),
    a("Example Exercise in Python using pandas",href="../ic-python-demo/"),
    tags$br(),tags$br(),
    "Another type of lesson we offer is interactive Jupyter Notebooks. Here is one such notebook, deployed to Google Colab",
    tags$br(),tags$br(),
    a("Example Jupyter Notebook",href="https://colab.research.google.com/github/arcus/education-materials/blob/master/data-analysis-with-pandas/01-exploring-diagnostic-data-with-pandas.ipynb"),
    tags$h3("Generate a Customized Curriculum"),
    "Try your hand at generating a customized curriculum for yourself or others.",
    tags$br(),tags$br(),
    a("Custom Curriculum Generator",href="../Lesson-Generator/"),
    tags$h3("Sign Up for an R or Statistics Workshop"),
    "If you are an employee or student of Children's Hospital of Philadelphia or the University of Pennsylvania, you are eligable to participate in an in-person workshop.",
    tags$br(),tags$br(),
    a("Click here to sign up.",href="https://redcap.chop.edu/surveys/?s=EYWKYA48KT"),
    tags$h3("Contribute Your Knowledge"),
    tags$img(src = "index1.png",width="40%"),tags$br(),tags$br(),
    tags$b("Contributing your knowledge is as easy as filling in an Rmarkdown document."),tags$br(),tags$br(),
    tags$ol(tags$li(a("Download and install RStudio if you haven't already.",href="https://rstudio.com/products/rstudio/download/#download"),tags$br(),tags$br()),
            tags$li("Install the learnr package:",tags$code('install.packages("learnr")'),".",tags$br(),tags$br()),
            tags$li("Download our template.",downloadButton("downloadData", "Download"),tags$br(),tags$br()),
            tags$li("Check out the ",a("learnr documenation",href="https://rstudio.github.io/learnr/")," for more information.",tags$br(),tags$br()),
            tags$li("Email ",a("Sheila",href="mailto:BRAUNSB@EMAIL.CHOP.EDU"),"or ",a("Ian",href="mailto:CAMPBELLIM@EMAIL.CHOP.EDU"),"to arrange upload to the system.",tags$br(),tags$br()),
            )

)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$downloadData <- downloadHandler(
        filename <- function(){"Template.Rmd"},
        content <- function(con){file.copy("/srv/shiny-server/index/Template.Rmd",con)}
        #content <- function(con){file.copy("/Users/campbellim/Arcus/Arcus-Modular-Education-Support-System/Template.Rmd",con)}
        #contentType <- "text/plain"
    )
}

# Run the application
shinyApp(ui = ui, server = server)
