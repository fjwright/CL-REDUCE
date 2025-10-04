# STATUS of REDUCE on Common Lisp (SBCL)

**[Francis Wright](https://sites.google.com/site/fjwcentaur), September 2025**

This status report is based on running REDUCE 7181 on SBCL 2.5.8 on Cygwin.

## Package builds showing issues 03/10/2025

None.

## Package tests showing issues 03/10/2025

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
lalr        | **Minor cosmetic differences** (ordering of S')
numeric     | Insignificant numerical errors
ofsf        | **VERY SLOW**
sstools     | Minor cosmetic difference, apparently caused by failure of bothtimes, not clear how to fix; see below
xcolor      | Crashes with stack overflow if compiled for debugging!

## TO DO

* sstools: `bothtimes put('is_fermionic,'boolfn,'evalfermionicp)$` in "sstools.red" but when `is_fermionic` is called from within "sstools.red" it is not recognised as an operator, although it is when called in "sstools.tst".  This suggests that `bothtimes` is not working at compile time, so the compiled code is calling `is_fermionic` rather than `evalfermionicp`.  Also, fluid declarations seem to be ignored!

* lalr: SBCL REDUCE sees S' as |s'|, which sorts as lower case.

<!-- Local Variables: -->
<!-- fill-column: 1000 -->
<!-- eval: (auto-fill-mode -1) -->
<!-- eval: (visual-line-mode 1) -->
<!-- eval: (visual-wrap-prefix-mode 1) -->
<!-- End: -->
