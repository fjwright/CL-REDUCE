# STATUS of REDUCE on Common Lisp (SBCL)

**[Francis Wright](https://sites.google.com/site/fjwcentaur)**
Time-stamp: <2025-10-04 15:12:37 franc>

This status report is based on running REDUCE 7181 on SBCL 2.5.8 on Cygwin.

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
economise   | Insignificant numerical differences
ellipfn     | One (significant) numerical difference
gf2         | Missing final backtrace
numeric     | Insignificant numerical errors
sstools     | Minor cosmetic difference, apparently caused by failure of bothtimes, not clear how to fix; see below
xcolor      | Crashes with stack overflow if compiled for debugging!

## TO DO

* sstools: `bothtimes put('is_fermionic,'boolfn,'evalfermionicp)$` in "sstools.red" but when `is_fermionic` is called from within "sstools.red" it is not recognised as an operator, although it is when called in "sstools.tst".  This suggests that `bothtimes` is not working at compile time, so the compiled code is calling `is_fermionic` rather than `evalfermionicp`.  Also, fluid declarations seem to be ignored!

<!-- Local Variables: -->
<!-- fill-column: 1000 -->
<!-- eval: (auto-fill-mode -1) -->
<!-- eval: (visual-line-mode 1) -->
<!-- eval: (visual-wrap-prefix-mode 1) -->
<!-- End: -->
