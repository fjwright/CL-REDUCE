# STATUS of REDUCE on Common Lisp (SBCL)

**[Francis Wright](https://sites.google.com/site/fjwcentaur), September 2025**

This status report is based on running REDUCE 7172 on SBCL 2.5.8 on
Cygwin using the standard REDUCE test framework:

```sh
franc@Centaur23 /c/REDUCE/reduce-algebra-code/testing
$ ../scripts/testall.sh --sbcl
```

## Packages showing issues

### First test

Package     | Comment
------------|--------
arith       | Insignificant numerical errors; IGNORE
assist      | Insignificant gensym numbering differences; one other insignificant difference; IGNORE for now
numeric     | Minor numerical errors; IGNORE for now
economise   | Insignificant numerical errors & display format differences; IGNORE for now
scope       | Insignificant gensym numbering differences; IGNORE for now
ellipfn     | One (significant) numerical error -- SBCL REDUCE is correct, CSL REDUCE is wrong!
redlog      | Insignificant numerical display differences; IGNORE for now
ofsf        | **VERY SLOW**; timed out/killed
ibalp       | Fixed by redefining equal as cl:equal
xcolor      | **CRASHES**, stack overflow in EQUAL!
lalr        | Minor cosmetic differences; IGNORE for now
sstools     | Minor cosmetic difference; IGNORE for now
f5          | Diffs -- to be investigated
gf2         | Significant diffs -- to be investigated
Regressions | IGNORE for now

### Second test with revised sl-on-cl 17/09/2025

Package     | Comment
------------|--------
arith
assist
economise
ellipfn
f5
gf2
lalr
numeric
ofsf        | NOT TESTED, **VERY SLOW**; timed out/killed
redlog
scope
sparse
sstools
xcolor      | NOT TESTED, **CRASHES**, stack overflow in EQUAL!

<!-- Local Variables: -->
<!-- fill-column: 1000 -->
<!-- eval: (auto-fill-mode -1) -->
<!-- eval: (visual-line-mode 1) -->
<!-- eval: (visual-wrap-prefix-mode 1) -->
<!-- End: -->
