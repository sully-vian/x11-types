Every valid and misuse case runs without a BadValue in C, every invalid case
raises one:

  $ ../run.sh --spec
  
  valid: 25/25
  invalid: 16/16
  misuse: 15/15
