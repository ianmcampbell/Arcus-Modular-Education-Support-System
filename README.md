# Arcus Education Lessons and the Learning Plan Generator

Previously, we had a repository consisting of multiple kinds of files to support our modular education.  We wanted 
to change the structure to 2 or more repositories:  

1. One repository that will hold all and **only** lesson modules (previously the subfolders 
"lessons", "personalized-learning-plan" and "lesson-generator").  We isolate these files so we can clone the entire repo 
to the shiny education server using git (moves us away from subversion) to populate the module list that educators can use 
to create curricula. THIS IS THAT REPO.

3. One repository (or possibly more) that contain(s) the supporting code that actually starts the server and has 
the code that will change seldom.
