# Arcus Modular Education Support System (MESS)

#### Designer, Sheila Braun, MA; Programmer, Ian Campbell, MD PhD. Based on ideas formed at the Summer 2019 Arcus Education Retreat attended by Joy Payton, MS (Supervisor, Arcus Education) and Sheila Braun (Data Instructional Specialist II)

Many of CHOP’s principle investigators and their teams have become interested in R and statistical analysis in R. In support of [the Arcus project at CHOP](https://arcus.reskubestage.research.chop.edu), one of our goals at [Arcus Education](https://education.arcus.chop.edu) is to create learning environments for relevant topics such as those in which 100% of attendees spend 100% of their time working towards their own goals at their own pace.

In our workshops, 

* Each learner sets their own goals.    
* Each learner receives an individualized curriculum based on their goals.   
* Success is measured by the extent to which each learner perceives themselves to have met their own goals.

Workshop attendees have highly variable goals, from R basics to machine learning algorithms for genetic data to report writing for monthly metrics. We experimented with R packages to answer the question, “How can an instructor who has _N_ attendees at a workshop create _N_ different curricula based on _N_ different sets of learning goals, while still treating the class as _N_ individuals rather than as a single unit?” 

To answer this question in a practical way, we are currently using R packages such as `shiny` and `learnr` to create a tool that streamlines the process of designing individual curricula.

The software for this tool is in the [Personalized Learning Plan](https://github.research.chop.edu/braunsb/Arcus-Education-Lessons-and-Learning-Plan-Generator/tree/master/Personalized-Learning-Plan) folder. Individual lessons are in [Lessons](https://github.research.chop.edu/braunsb/Arcus-Education-Lessons-and-Learning-Plan-Generator/tree/master/Lessons). 

### Be MESSy: Become a Contributor!

[New Lessons](https://github.research.chop.edu/braunsb/Arcus-Education-Lessons-and-Learning-Plan-Generator/tree/master/New-Lessons) is for you, our contributor. Please add your educational material to this folder. If you are a genetics expert, teach us about genetics; if you want people to know how to use a package you just created, create a lesson about it and add it. If you want to teach about Python, put your Python lessons there.

These are our requirements for a lesson:

* It must be provided in Markdown (.Rmd is our favorite, but you can supply a .md file instead.
* It must stand on its own. If you have Python code that runs upon rendering, or SQL, or videos, or links, they must work. 
* It must adhere to CHOP's standards and ethics. 

Our editors will check your lesson and add it to the list of options available to learners if we believe it is in line with our mission to educate learners at CHOP. 

### Note about this Repo's History

Previously, we had a repository consisting of multiple kinds of files to support our modular education.  We wanted 
to change the structure to 2 or more repositories:  

1. One repository that will hold all and **only** lesson modules (previously the subfolders 
"lessons", "personalized-learning-plan" and "lesson-generator").  We isolate these files so we can clone the entire repo 
to the shiny education server using git (moves us away from subversion) to populate the module list that educators can use 
to create curricula. THIS IS THAT REPO.

3. One repository (or possibly more) that contain(s) the supporting code that actually starts the server and has 
the code that will change seldom.
