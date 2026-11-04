mask.ml computes what C computes: same answers from the stand-ins on every bit,
same constants, operators and server masks. Only the types may differ.

  $ report() (
  >   cd $1 && cp ../../oracle/probe.ml ../../oracle/semantics.ml . &&
  >   if [ -f mask.mli ]; then ocamlc -c mask.mli; fi &&
  >   ocamlc mask.ml probe.ml -o probe && ocamlc mask.cmo semantics.ml -o semantics &&
  >   ./probe && ./semantics
  > )
  $ mkdir oracle candidate
  $ cp ../oracle/mask.ml oracle/ && cp ../mask.mli ../mask.ml candidate/
  $ report oracle > oracle.txt
  $ report candidate > candidate.txt
  $ diff oracle.txt candidate.txt
  $ wc -l < oracle.txt
  222
