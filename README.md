tlog
============================================

A git-based CLI to help you with time tracking on your projects.

## Installing
```bash
$ sudo gem install tlog
```

## Usage
* Navigate to a directory that has a git repo

### Create a time log
```bash
$ tlog create example 
```

### Check out a time log
```bash
$ tlog checkout example
```

### Create a time log with a time goal
```bash
$ tlog create example --goal 4hr
```

### Create a new time log with a state and a points value
```bash
$ tlog create example --state OPEN --points 10
```

### Start a new task the checked-out time log
```bash
$ tlog start -d "My task description"
```

### Update the state of the checked-out time log
```bash
$ tlog state CLOSED
```

### Update the points value of the checked-out time log
```bash
$ tlog points 10
```

### Update the owner of the checked-out time log
```bash
$ tlog owner cewendel
```

### Stop the current task
```bash
$ tlog stop example
```

### Show active time logs and label the checked-out log or the in-progress log
```bash
$ tlog active
All Time Logs:
testing
feature1(in-progress)
bug fix
feature2
```
 
### Display all the current time logs and their tasks, total time logged and time left.
```bash
$ tlog display
Log:    bugfix1
State:  CLOSED
Points: 5
Owner:  petewallen
	Start               End                    Duration          Description
	June 06, 12:28AM   June 06, 12:29AM        0:00:53           still fixing the bug
	June 06, 12:01AM   June 06, 12:01AM        0:00:08           fixing the bug 
----------------------------------------------------------------------------------------------------
	Total                                      0:01:01 
Log:    feature2
State:  OPEN
Points: 1
Owner:  chriwend
	Start               End                    Duration          Description
	June 05, 11:46PM   June 05, 11:46PM        0:02:17           creating cool feature2
----------------------------------------------------------------------------------------------------
	Total                                      0:02:17 
``` 

### Delete a time log
```bash
$ tlog delete example
```

## Collaboration

tlog makes for easy time and ticket tracking when working with a team. Assuming you have a remote repo that you and others are pushing to, use the `tlog push` and `tlog pull` commands to keep your time logs up to date.

### Pull in new or updated time logs from upstream
```bash
$ tlog pull
```

### Push new or updated time logs upstream
```bash
$ tlog push
```

## Contributing

Please look at the TODO for possible additional features. Use [Github issues](https://github.com/cewendel/tlog/issues) to track bugs and feature requests.

## Licence

GNU GENERAL PUBLIC LICENCE Version 2
