tlog
============================================

A git-based CLI to help you with time tracking on your projects.

## Installing
```bash
$ sudo gem install tlog
```

# Usage
* Navigate to a directory that has a git repo

## Create a time log

#### Create a default time log with no goal
```bash
$ tlog create example 
```

#### Create a time log with a time goal
```bash
$ tlog create example --goal 4hr
```

#### Create a new time log with a state and a points value
```bash
$ tlog create example --state OPEN --points 10
```

## Using time logs

#### Check out a time log
```bash
$ tlog checkout example
```

#### Start a new task the checked-out time log
```bash
$ tlog start -d "My task description"
```

#### Update the state of the checked-out time log
```bash
$ tlog state CLOSED
```

#### Update the points value of the checked-out time log
```bash
$ tlog points 10
```

#### Update the owner of the checked-out time log
```bash
$ tlog owner cewendel
```

#### Stop the current task
```bash
$ tlog stop example
```

#### Delete a time log
```bash
$ tlog delete example
```

## Displaying time logs

#### Display all time logs
```bash
$ tlog display
Log:    bugfix
State:  open
Points: 10
Owner:  andrew
	Start               End                    Duration          Description
	June 06, 12:45PM   June 06, 12:46PM        1:00:27           fixing really bad bug
	June 07, 
----------------------------------------------------------------------------------------------------
	Total                                      1:00:27 
	Time left:                                 0:59:33
Log:    important
State:  closed
Points: 0
Owner:  chris
	Start               End                    Duration          Description
----------------------------------------------------------------------------------------------------
	Total                                      0:00:00 
Log:    feature1
State:  hold
Points: 5
Owner:  peter
	Start               End                    Duration          Description
	June 13, 12:32PM   June 13, 12:33PM        0:00:34           making sure new feature works
	June 13, 12:29PM   June 13, 12:32PM        0:02:30           working on new feature
----------------------------------------------------------------------------------------------------
	Total                                      0:03:04 
	Time left:                                 3:56:56
``` 

#### Display a specific time log
```bash
$ tlog display feature1
Log:    feature1
State:  hold
Points: 5
Owner:  peter
	Start               End                    Duration          Description
	June 13, 12:32PM   June 13, 12:33PM        0:00:34           making sure new feature works
	June 13, 12:29PM   June 13, 12:32PM        0:02:30           working on new feature
----------------------------------------------------------------------------------------------------
	Total                                      0:03:04 
	Time left:                                 3:56:56
```

#### Constrain displayed time logs to only ones with specified states
```bash
$ tlog display -s open,hold
Log:    bugfix
State:  open
Points: 10
Owner:  andrew
	Start               End                    Duration          Description
	June 06, 12:45PM   June 06, 12:46PM        1:00:27           fixing really bad bug
	June 07, 
----------------------------------------------------------------------------------------------------
	Total                                      1:00:27 
	Time left:                                 0:59:33
Log:    feature1
State:  hold
Points: 5
Owner:  peter
	Start               End                    Duration          Description
	June 13, 12:32PM   June 13, 12:33PM        0:00:34           making sure new feature works
	June 13, 12:29PM   June 13, 12:32PM        0:02:30           working on new feature
----------------------------------------------------------------------------------------------------
	Total                                      0:03:04 
	Time left:                                 3:56:56
```
#### Constrain displayed time logs to only ones with specified owners
```bash
$ tlog display -o chris,peter
Log:    important
State:  closed
Points: 0
Owner:  chris
	Start               End                    Duration          Description
----------------------------------------------------------------------------------------------------
	Total                                      0:00:00 
Log:    feature1
State:  hold
Points: 5
Owner:  peter
	Start               End                    Duration          Description
	June 13, 12:32PM   June 13, 12:33PM        0:00:34           making sure new feature works
	June 13, 12:29PM   June 13, 12:32PM        0:02:30           working on new feature
----------------------------------------------------------------------------------------------------
	Total                                      0:03:04 
	Time left:                                 3:56:56
```

#### Contrain displayed time logs to only ones that have points values >= the specified points value
```bash
$ tlog display -p 10
Log:    bugfix
State:  open
Points: 10
Owner:  andrew
	Start               End                    Duration          Description
	June 06, 12:45PM   June 06, 12:46PM        1:00:27           fixing really bad bug
	June 07, 
----------------------------------------------------------------------------------------------------
	Total                                      1:00:27 
	Time left:                                 0:59:33
```

#### Constrain displayed time logs to only ones that have less than the specified amount of time left to finish
```bash
$ tlog display -g 1hr
Log:    bugfix
State:  open
Points: 10
Owner:  andrew
	Start               End                    Duration          Description
	June 06, 12:45PM   June 06, 12:46PM        1:00:27           fixing really bad bug
	June 07, 
----------------------------------------------------------------------------------------------------
	Total                                      1:00:27 
	Time left:                                 0:59:33
```

#### Show active time logs and label the checked-out log or the in-progress log
```bash
$ tlog active
All Time Logs:
testing
feature1(in-progress)
bug fix
feature2
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
