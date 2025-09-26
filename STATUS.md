# STATUS of REDUCE on Common Lisp (SBCL)

**[Francis Wright](https://sites.google.com/site/fjwcentaur), September 2025**

This status report is based on running REDUCE 7172 on SBCL 2.5.8 on Cygwin using the standard REDUCE test framework (excluding regressions):

## Packages showing issues

```sh
franc@Centaur23 /c/REDUCE/reduce-algebra-code/testing
$ ../scripts/testall.sh --sbcl
```

Package     | Comment
------------|--------
arith       | SBCL is numerically more accurate than CSL/PSL **IGNORE**
assist      | Gensym numbering differences **FIX[2]**; one other minor difference IGNORE for now
economise   | Insignificant numerical errors **IGNORE**; display format differences **FIX[1]**
ellipfn     | One numerical difference **IGNORE** for now
f5          | Issues to be investigated
gf2         | Issues to be investigated
lalr        | Minor cosmetic differences to be investigated
numeric     | Insignificant numerical errors **IGNORE**
ofsf        | **NOT TESTED**, **VERY SLOW**; timed out/killed
redlog      | Display format differences **FIX[1]**
scope       | Gensym numbering differences **FIX[2]**
sparse      | **Issues to be investigated**
sstools     | Minor cosmetic difference IGNORE for now
xcolor      | **NOT TESTED**, **CRASHES**, stack overflow in EQUAL!

### 25/09/2025

```sh
franc@Centaur23 /c/REDUCE/reduce-algebra-code/testing
$ ../scripts/testall.sh --sbcl $(../common-lisp/packages-to-test.sh)
```
Package     | Comment
------------|--------
arith       | SBCL is numerically more accurate than CSL/PSL **IGNORE**
assist      | One minor difference because tan not flagged lose **IGNORE** for now
economise   | Insignificant numerical differences **IGNORE**
ellipfn     | One numerical difference **IGNORE** for now
gf2         | **Issues to be investigated**
ibalp       | Stack overflow in equal (again!)
lalr        | **Minor cosmetic differences** c vs. !C, ordering of '; uses hash tables!
numeric     | Insignificant numerical errors **IGNORE** for now
ofsf        | **NOT TESTED**
sstools     | Minor cosmetic difference, apparently caused by failure of bothtimes, not clear how to fix; see below **IGNORE** for now
xcolor      | **NOT TESTED**

## TO DO

* sstools: `bothtimes put('is_fermionic,'boolfn,'evalfermionicp)$` in "sstools.red" but when `is_fermionic` is called from within "sstools.red" it is not recognised as an operator, although it is when called in "sstools.tst".  This suggests that `bothtimes` is not working at compile time, so the compiled code is calling `is_fermionic` rather than `evalfermionicp`.  Also, fluid declarations seem to be ignored!

<!-- Local Variables: -->
<!-- fill-column: 1000 -->
<!-- eval: (auto-fill-mode -1) -->
<!-- eval: (visual-line-mode 1) -->
<!-- eval: (visual-wrap-prefix-mode 1) -->
<!-- End: -->
