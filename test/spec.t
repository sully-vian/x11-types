Every valid and misuse case runs without a BadValue in C, every invalid case
raises one:

  $ ../run.sh --spec
  
  valid: 21/21
  invalid: 16/16
  misuse: 12/12
