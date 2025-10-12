# STATUS of REDUCE on Common Lisp (SBCL)

**[Francis Wright](https://sites.google.com/site/fjwcentaur)**
Time-stamp: <2025-10-12 17:18:24 franc>

This status report is based on running REDUCE 7190 on (native Windows) SBCL 2.5.8 on Cygwin.

No build errors.

## Package tests showing issues

Using the standard REDUCE test framework (excluding regressions):

```sh
franc@Centaur23 /c/REDUCE/reduce-algebra-code/testing
$ ../scripts/testall.sh --sbcl $(../common-lisp/packages-to-test.sh)
```
Package     | Comment
------------|--------
arith       | SBCL is numerically more accurate than CSL/PSL!
ellipfn     | One (significant) numerical difference
gf2         | Missing final backtrace
numeric     | Minor numerical differences
xcolor      | Crashes with stack overflow if compiled for debugging!

## TO DO

<!-- Local Variables: -->
<!-- fill-column: 1000 -->
<!-- eval: (auto-fill-mode -1) -->
<!-- eval: (visual-line-mode 1) -->
<!-- eval: (visual-wrap-prefix-mode 1) -->
<!-- End: -->
