# STATUS of REDUCE on Common Lisp (SBCL)

**[Francis Wright](https://sites.google.com/site/fjwcentaur), September 2025**

This status report is based on running REDUCE 7172 on SBCL 2.5.8 on
Cygwin using the standard REDUCE test framework:

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

### 21/09/2025

```sh
franc@Centaur23 /c/REDUCE/reduce-algebra-code/testing
$ ../scripts/testall.sh --sbcl $(../common-lisp/packages-to-test.sh)
```
Package     | Comment
------------|--------
arith       | SBCL is numerically more accurate than CSL/PSL **IGNORE**
assist      | Gensym numbering differences **FIX[2]**; one other minor difference IGNORE for now
economise   | Insignificant numerical errors **IGNORE**
ellipfn     | One numerical difference **IGNORE** for now
f5          | **Issues to be investigated**
gf2         | **Issues to be investigated**
lalr        | **Minor cosmetic differences to be investigated**
numeric     | Insignificant numerical errors **IGNORE** for now
ofsf        | **NOT TESTED**
redlog      | Display format differences remain! **FIX[1]**
scope       | Gensym numbering differences **FIX[2]**
sparse      | **Issues to be investigated**
sstools     | Minor cosmetic difference **IGNORE** for now
xcolor      | **NOT TESTED**

<!-- Local Variables: -->
<!-- fill-column: 1000 -->
<!-- eval: (auto-fill-mode -1) -->
<!-- eval: (visual-line-mode 1) -->
<!-- eval: (visual-wrap-prefix-mode 1) -->
<!-- End: -->
