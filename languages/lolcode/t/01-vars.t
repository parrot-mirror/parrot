HAI 1.2
  VISIBLE "1..6"

  BTW THIS IS COMMENT OK?
  I HAS A CHEEZBURGER ITZ "ok "
  VISIBLE CHEEZBURGER !
  CHEEZBURGER R 1
  VISIBLE CHEEZBURGER

  BTW ONE LETTER VARS OK.
  I HAS A Q ITZ "ok "
  VISIBLE Q !
  Q R 2
  VISIBLE Q

  "ok 3"
  VISIBLE IT

  BTW VARS THAT START WITH KEYWORDS OK.
  I HAS A ANY ITZ "ok 4"
  VISIBLE ANY

  BTW EMPTY DECLARATIONS SHOULDN'T CLOBBER
  I HAS A RESULT ITZ "ok 5"
  I HAS A RESULT
  VISIBLE RESULT

  BTW MULTIPLE DECLARATIONS WITH ASSIGNMENTS SHOULD
  I HAS A ANOTHER ITZ "not ok 6"
  I HAS A ANOTHER ITZ "ok 6"
  VISIBLE ANOTHER

  BTW vim: set filetype=lolcode :
KTHXBYE
