day.rb
======
(Version 1.8 -- 12/28/13)

A command-line time tracking / to-do application.

* Define & describe tasks, and set time estimates for yourself.
* Check in or out of tasks to track time spent.

Requirements:
-------------
* Ruby (Tested with 2.0.0)

Usage: 
------
* Create a new task:

        day.rb new_task_name
        
* Create tasks for certain days & expect a time in minutes

        day.rb write_lab_report m w 120
        (or)
        day.rb add_new_feature 45
        
        --> Creating new task: add_new_feature
        

* Check into a task while you're working on it

        day.rb
        --> Day.rb (1.8)
        --> Today's tasks:
        -->
        --> 0: dayrb_add_descriptions (60 minute estimate)
        --> 1: matl_quiz_post9 (15 minute estimate)
        --> 2: matl_hw_ch9 (55 minute estimate)
        
        day.rb 0
        --> Enter context: dayrb_add_descriptions
        
        (85.9 minutes later)
        
        day.rb 0
        --> Exit Context: dayrb_add_descriptions
        --> Time: 85.9 minutes
        
        day.rb
        --> Day.rb (1.8)
        --> Today's tasks:
        --> 
        --> 0: dayrb_add_descriptions [85.9/60 minutes] [143.2%] (85.9 minutes today)
        --> 1: matl_quiz_post9 (15 minute estimate)
        --> 2: matl_hw_ch9 (55 minute estimate)
        
* Add a task with description. <br />

    (Note that the task description has to be in both quotes AND parenthesis. I'm sorry it's ugly, but getting special characters through the shell and into ARGV is hard.) <br /><br />
    (Tasks with a description have an asterisk next to their name in the task list.)

        day.rb task_name "(task description)" time_estimate

* Print out the description for a task

        day.rb info task_number

* Delete a task

        day.rb delete 0
        
* Clear fulfillment data on all tasks

        day.rb clear

* Jump directly from task to task
* Express days as monographs/digraphs when unambiguous or trigraphs/fullnames.
* Stores data by default in ~/.app_data/ -- Edit the constants at top of script to change this.

Issues:
------------
    Could not parse day argument! Check your day glyphs. (ArgumentError)
    
    (Solution: See https://gist.github.com/sanarothe/6326110)




Copyright 2013 - Cameron Carroll
License: GNU GPL V3