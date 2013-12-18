1.7 -- 11/10/13
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

