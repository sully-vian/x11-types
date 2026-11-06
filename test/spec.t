Every valid and misuse case runs without a BadValue in C, every invalid case
raises one:

  $ ../run.sh --spec
  
  valid: 37/37
  invalid: 17/17
  misuse: 14/14
