day.rb
------

A simple time tracking / to-do application.

Overview:
=========
1. Define daily tasks, or for specific dates
2. List all tasks to pick a context
3. Pick a task to time, or mark asynchronous tasks as finished
4. Quantify time spent

Runtime Requirements:
==================
1. Ruby (Tested with 2.0.0)
2. bundler (gem install bundler)
3. trollop rubygem installed globally (gem install trollop)

Installation:
=============
1. Copy day.rb to your favorite application folder
2. Symlink apps/day.rb to your favorite bin folder

Usage:
======
(day.rb --help will print this out also)

Simply select a task to begin timing it, and run the same command again to stop.

  day.rb [options] [task number]

  Examples:

  # day.rb -- List tasks for the day.
  # day.rb new_task -- Adds a new task; Defaults to 'every day.'
  # day.rb 0 -- Switch context & start timing new_task... tasks are indexed from 0.
  # day.rb new_task2
  # day.rb 1 -- Switch context and save time spent in previous context.
  # day.rb 1 -- Exit context, save times.

  #day.rb new_task3 m w thu -- Create new_task3 for monday, wednesday and thursday.

  Notes:

  # Days of the week can either be defined as individual letters and digraphs,
    where necessary, or trigraphs where desired. Must be given as a list of lowercase keys.
    ie: m, tu, w, th, f, sa, su
    You could also use the internal representation, where 0 corresponds to sunday and 6 to saturday.

  # When using day.rb <noun>, integer numerical input will switch context,
    while alphanumeric input will create a new task.


Copyright 2013 - Cameron Carroll
License: GNU GPL V3