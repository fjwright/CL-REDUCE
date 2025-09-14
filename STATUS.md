# STATUS of REDUCE on Common Lisp (SBCL)

**[Francis Wright](https://sites.google.com/site/fjwcentaur), September 2025**

This status report is based on running REDUCE 7172 on SBCL 2.5.8 on
Cygwin using the standard REDUCE test framework:

```sh
franc@Centaur23 /c/REDUCE/reduce-algebra-code/testing
$ ../scripts/testall.sh --sbcl
```

## Packages for which the test logs differ

Package | Comment
--------|--------
`arith` | Insignificant numerical errors; IGNORE
`assist` | `***** Continuing with parsing only ...`
`cantens` | `***** The function STANDARD-LISP::REMHASH is undefined. ***** Continuing with parsing only ...`
`dfpart` | A few differences -- to be investigated
`odesolve` | rlg out of sync with tst?
`numeric` | Minor numerical errors; IGNORE for now
`economise` | Very slow; insignificant numerical errors & display format differences
`scope` | Insignificant gensym differences (fixable?); IGNORE for now
`spde` | `***** The function STANDARD-LISP::REMHASH is undefined`
`ellipfn` | One non-trivial numerical error -- to be investigated
`trigint` | Significant differences -- to be investigated
`redlog` | Insignificant numerical display differences (fixable?); IGNORE for now
`ofsf` | Very slow. `***** The function STANDARD-LISP::REMHASH is undefined`
`ibalp` | CRASHES, repeatedly reads EOF, and breaks timeout! TEST KILLED.
