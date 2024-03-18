## ToDo
- be able to move tasks
- sort them automatically by date
- work for phone
  - TimePickerSpinner
- if you hover over date you get more details
- ToPlan ToDo without due date or without due time
- Create/view page
- terminal looking instead of scaffoldmessager
- highlight time part from task

## Done
- delete time park from task
- make tom work
- no date and time should work
- shouldn't flicker when adding a new task
- finish writing the dateTime options
- implement the dateTime options

Home page: scrollable 
  1st page
    Upper half: todo (button to add task)
      Tasks to do now
      ToBuy
      ToPlan
    Lower half: notes (button to add note)
Before going to sleep: day review + score
Keep track of score (hours efficient /hours inneficient)
+ plan next day
Remind me of bdays + exams some time before

## Tasks operations
- add a new task
- modify a task (by id)
- delete a task (by id)
- sort tasks by date

## Sync
- When
  - opening ToDo
  - adding a new task
  - modifying a task
  - deleting a task
  - refreshing tasks
- What
  - list of tasks
  - 

start DateTime, reccurance, planned duration, actual duration 
- firestore storage
- display: string (simpler string)
  - if reccurent just show the reccurent icon
  - start DateTime -> end DateTime
  - DateTime
    - can be none (no date no time)
    - time if optional (can have only date)
    - if date not present (only time) it's today
    - Date
      - 12 mar 22
      - 12 mar
      - mon
    - Time
      - 12:00
- input ~ display more complex string
  - date
      no date
      12.5.25
      12 jan 25
      12.5
      12 jan
      this/every 12
      tod/tom
      in/every 5d/w/m/y
      /every mon/tue/wed/thu/fri/sat/sun
      /every end of jan
  - time
      12:34
      no time
  - date & time
      in 5m/h
      date time
  - end date / duration
      date time -> time: 12 jan 12:00 -> 13:00
      date time -> date time 12 jan 12:00 -> 13 jan 15:00
      date time -> duration: 21 jan 12:00 for 1m/h/d/w/m/y
- mark it as done
  - if reccurent set it to next startDate
    - every 5d/w/m/y
    - every mon
- order by DateTime for calendar

## Task
### View in app
- Done %
- Title
- Description
- #ToPlan
- Start date -> end date
- Planned time -> actual time
- Priority
  - 0 = red = cannot change it: exam/business meeting
  - 1 = orange = should not change it: meeting/doctor apoointment/gym
  - 2 = no colour = everything else
- Subtasks

### Add a new task
- press + button
- press q
