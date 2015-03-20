day.rb
======
(Version 2.0.4 -- March 2015)

A command-line to-do & time-tracking application.

* Define & describe tasks, and set time estimates for yourself.
* Check in and out of tasks to track time spent.

Requirements:
-------------
* Ruby (Tested with 2.1.2)

Installation:
-------------

### Method 1 (Recommended): Install as a Gem

* Simply run 'gem install dayrb' and invoke the executable, 'day.rb'

### Method 2: Clone the Repository (Entire Folder)

* Clone the repository to your favorite apps folder. (git clone https://github.com/sanarothe/day.git ~/apps)
* Symlink day.rb into your favorite bin folder. (ln -s ~/apps/day/bin/day.rb ~/bin/day)
* Chmod it to be executable (chmod +x ~/bin/day)

Usage Overview:
---------------
    Usage: day.rb <command> [<args>]

    Commands:
      (no command)        Prints out task list for the day
      (nonexisting task)  Creates a new task
      (existing task)     Start tracking time for named task.
      delete (task)       Remove a task
      rm (task)           (Synonym for delete.)
      info                Print all descriptions
      info (task)         Print a specific description
      i (task)            (Synonym for info.)
      clear               Clear fulfillment for all tasks.
      clear (task)        Clear fulfillment for a specific task.
      c (task)            (Synonym for clear.)

    Flags:
      -a                  Also print tasks not enabled today.

    Tips:
      Refer to a task either by its name or index.
      Jump directly between tasks.
      Include "vim" or your editor constant when creating new task to add a description.
      Configuration data is stored at the top of 'day.rb.'

Examples
--------
    # Create a new task:
    day.rb my_new_task

    # Create task enabled on monday & wednesday, with a 45 minute estimate:
    day.rb my_new_task m w 45

    # Create a task with in-line description:
    # Note parenthesis and quotations are mandatory.
    day.rb my_new_task "(some description)"

    # Create a task with editor description:
    # Note 'vim' can be changed to any editor atop day.rb file.
    day.rb my_new_task vim

Copyright 2015 - Cameron Carroll

License: MIT
