2.0.4 -- 03/20/14
-------------------

* Updated help documentation to be more clear about abbreviated commands and descriptions, and also added some examples.
* Added confirmation for delete and clear commands.
* Fixed a problem where switching directly between two tasks didn't save fulfillment data for the first.

2.0.3 -- 08/17/14
------------------

* Added gem files to gitignore
* Pointed spec helper at the correct lib directory (after moving)
* Removed Rakefile (unused now with gem distribution)

2.0.2 -- 08/17/14
------------------

### Gem Distribution:

* Now available as a gem! 'gem install dayrb'
* Reorganized directory structure for gem generation

### Bug Fixes:

* Changed shebang to user /usr/bin/env ruby instead of /usr/bin/ruby.
* Fixed some spec regressions.

2.0.1 -- 08/12/14
------------------

* Makes sure data store directory exists.

2.0.0 -- 08/11/14
------------------

### Feature Additions:

* Added "-a" / "-A" flag, for "all tasks." This allows you to see tasks that aren't enabled for today.
* You can now refer to tasks by name rather than only by numerical index.

### Deprecations:

* Removed DESCRIPTION flag and deprecated its functionality, which would print full descriptions instead of asterisk in the tasklist.

### Internal Changes:

* Major internal rewrite; Disassembled god class (List) and also significantly simplified the configuration. (One module and YAML/DBM instead of three modules and hand-rolled YAML file access.)
* Separated all printing logic into presenter module.
* Separated all DB access logic into configuration module.
* Created Tasklist to manage task objects and maintain lists of valid tasks and all tasks.
* Wrote specs for Configuration and Parser.
* Added YARD-style documentation to all methods and classes.

1.9.1 -- 1/21/14
-------------------

* Added editor-based descriptions: Define EDITOR in user config section and then include it in the new_task arglist to launch editor and capture description.
* Times printed out in certain places are converted to minutes/hours/days as appropriate.
* Added colorization on index key and task names in printout.
* Some internal upgrades (refactoring, spacing issues, etc.)

1.8.1 -- 12/30/13
-------------------

* Add "(No tasks in list.)" declaration so that the program always has SOME output.
* Removed extra newline after task list printout. (Just trying to make thins look cleaner and more compact.)
* Fixed build tool; Added a CUT HERE comment to day.rb which the build tool uses to split the file.
* Updated build tool :update_version task to handle SemVer.

1.8 -- 12/28/13
-------------------

* Removed unused 'commit' command code.
* Added VERSION file to act as authoritative version source.
* Added Rakefile to build project, incrementing version and date and also building one-file distributable.
* Added string helper String.number? to avoid !nan? double negative & clarifying intention.
* Added a general 'info' command which prints out all descriptions.
* Updated options parsing when creating a new task so that everything after task name can be in any order. (Previously, the description had to come first.)
* Added a very rudimentary help command and version printout command.
* Added task-specific fulfillment clear function rather than forcing clear on all of them.

1.7 -- 12/18/13
-------------------

* Changed 'info' command behavior to print out task title instead of just declaring `Description:'.
* Added aliases: 'c' for clear, 'i' for info and 'rm' for delete
* Added colorized output, but it's off by default. (I didn't want to make any assumptions regarding readability.) Colored output can be configured for titles, enter/exits, completion printouts, and the description-indicating star specifically, as well as all of the remaining text generally.
* Cleaned up some cosmetic issues in code and comments, and a tiny typo in readme.
* Updated error messages for clarity, verbosity, and style.
* Extended list of enabled-day glyphs to include more partial-spellings of day names.

1.6 -- 11/05/13
-------------------

* Removed bundler dependency, deleted Gemfile. (Literally the only dependency was bundler itself. I guess hardly anyone will NOT have bundler, but nevertheless it's useless and gone.)

1.5 -- 10/29/13
-------------------

* Changed wording in program to use estimates instead of commitments.
* Added optional descriptions for tasks.
* Added info command to print out descriptions without checking-in.

1.4 -- 9/13/13
-------------------

* Fixed daily fulfillments. Previously every time you exited a context it would reset the daily fulfillment counter.
* Changed all time printouts to use 1 digit past the decimal.
* Tracks and displays daily fulfillment for tasks that don't have commitments.

1.3 -- 8/27/13
-------------------

* Printout will now clearly show tasks with commitments but no fulfillments.
* Only update fulfillment on tasks that actually have commitments
* Added day_fulfillment property on all tasks which resets every day and prints out how much progress you've made today.

1.2 -- 8/23/13
-------------------

* Only display tasks if their specified days are blank or include today

1.1 -- 8/23/13
-------------------

* Task list printout will now give progress on current task.
