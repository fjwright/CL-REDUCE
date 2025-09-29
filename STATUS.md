# STATUS of REDUCE on Common Lisp (SBCL)

**[Francis Wright](https://sites.google.com/site/fjwcentaur), September 2025**

This status report is based on running REDUCE 7178 on SBCL 2.5.8 on Cygwin.

## Package builds showing issues 29/09/2025

gf2: build fails if optimised for speed.

## Package tests showing issues 29/09/2025

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
gf2         | **Issues to be investigated**
lalr        | **Minor cosmetic differences** c vs. !C, ordering of '; uses hash tables!
numeric     | Insignificant numerical errors
ofsf        | **VERY SLOW**
sstools     | Minor cosmetic difference, apparently caused by failure of bothtimes, not clear how to fix; see below
xcolor      | **CRASHES**, stack overflow

## TO DO

* sstools: `bothtimes put('is_fermionic,'boolfn,'evalfermionicp)$` in "sstools.red" but when `is_fermionic` is called from within "sstools.red" it is not recognised as an operator, although it is when called in "sstools.tst".  This suggests that `bothtimes` is not working at compile time, so the compiled code is calling `is_fermionic` rather than `evalfermionicp`.  Also, fluid declarations seem to be ignored!

<!-- Local Variables: -->
<!-- fill-column: 1000 -->
<!-- eval: (auto-fill-mode -1) -->
<!-- eval: (visual-line-mode 1) -->
<!-- eval: (visual-wrap-prefix-mode 1) -->
<!-- End: -->
