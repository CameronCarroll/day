day.rb
======
(Version 1.3 -- 8/27/13)

A command-line time tracking / to-do application.

* Define tasks, optionally with expected time commitment.
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
        --> Day.rb (1.0)
        --> Today's tasks:
        -->
        --> 0: add_new_feature
        
        day 0
        --> Enter context: add_new_feature
        
        (2 minutes later)
        
        day 0
        --> Exit Context: add_new_feature
        --> Time: 2.29 minutes
        
        day.rb
        --> Day.rb (1.0)
        --> Today's tasks:
        -->
        --> 0: add_new_feature [2.29/45]  [5.10%]
        
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