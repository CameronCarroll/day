day.rb
======
(Version 2.0.0 -- August 2014)

A command-line to-do & time-tracking application.

* Define & describe tasks, and set time estimates for yourself.
* Check in or out of tasks to track time spent.

Requirements:
-------------
* Ruby (Tested with 2.1.2)

Installation:
-------------

### Method 1: Download a Release (One File)

* Head on over to the [Releases Page](https://github.com/sanarothe/day/releases)
* Download the latest "one-file distributable" version of day.rb
* Stick it in your favorite bin folder. (~/bin)
* Chmod it to be executable (chmod +x ~/bin/day.rb)

### Method 2: Clone the Repository (Entire Folder)

* Clone the repository to your favorite apps folder. (git clone https://github.com/sanarothe/day.git ~/apps)
* Symlink day.rb into your favorite bin folder. (ln -s ~/apps/day/day.rb ~/bin/day)
* Chmod it to be executable (chmod +x ~/bin/day)

Usage Overview: 
---------------

    Usage: day.rb <command> [<args>]

    Commands:
    (no command)        Prints out task list for the day
    (nonexisting task)  Creates a new task
    (existing task)     Start tracking time for named task
    delete (task)       Remove a task
    info                Print all descriptions
    info (task)         Print a specific description
    clear               Clear fulfillment for all tasks.
    clear (task)        Clear fulfillment for a specific task.
    
    (From 'day.rb help')
    
* Use the '-a' flag (with no command) to print out tasks that aren't enabled for the day
* Jump directly from task to task
* Stores data by default in ~/.config/day/ -- Edit the constant at top of script to change this.

Copyright 2014 - Cameron Carroll

License: MIT