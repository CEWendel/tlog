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

### Create a time log with a time goal
```bash
$ tlog create example --goal 4hr
```

### Start a new task on a time log
```bash
$ tlog start example -d "My task description"
```

### Stop the current task
```bash
$ tlog stop example
```

### Show active time logs and label the current one, if it exists
```bash
$ tlog active
All Time Logs:
testing
feature1(current)
bug fix
feature2
```
 
### Display all the current time logs and their tasks, total time logged and time left.
```bash
$ tlog display
Log: example1
	Start               End                    Duration        Owner          Description
	May 29, 11:57PM    May 29, 11:58PM         0:01:13         chriwend       My Description
----------------------------------------------------------------------------------------------------
	Total                                      0:01:13 
Log: example2
	Start               End                    Duration        Owner          Description
	May 30, 12:00AM                            0:02:26         chriwend       Fixing bug
	May 30, 12:00AM    May 30, 12:00AM         0:00:10         chriwend       (no description)
----------------------------------------------------------------------------------------------------
	Total                                      0:02:36 
	Time left:                                 3:57:24
``` 

### Delete a time log
```bash
$ tlog delete example
```

## Collaboration
More to come on this after I test it...

## Contributing

Please look at the TODO for possible additional features. Use [Github issues](https://github.com/cewendel/tlog/issues) to track bugs and feature requests.

## Licence

GNU GENERAL PUBLIC LICENCE Version 2
