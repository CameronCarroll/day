1.1 -- 8/23/13
-------------------

* Task list printout will now give progress on current task.

1.2 -- 8/23/13
-------------------

* Only display tasks if their specified days are blank or include today

1.3 -- 8/27/13
-------------------

* Printout will now clearly show tasks with commitments but no fulfillments.
* Only update fulfillment on tasks that actually have commitments
* Added day_fulfillment property on all tasks which resets every day and prints out how much progress you've made today.

1.4 -- 9/13/13
-------------------

* Fix daily fulfillments. Previously every time you exited a context it would reset the daily fulfillment counter.
* Change all time printouts to use 1 digit past the decimal.
* Tracks and displays daily fulfillment for tasks that don't have commitments