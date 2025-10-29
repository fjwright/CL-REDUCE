# STATUS of REDUCE on Common Lisp (SBCL)

**[Francis Wright](https://sites.google.com/site/fjwcentaur)**
Time-stamp: <2025-10-29 16:58:40 franc>

This status report is based on running REDUCE 7190 on (native Windows) SBCL 2.5.8 on Cygwin.

No build errors.

But `sstools.blg` shows a *large number* of warnings of the form

```
*** nonlocal use of undeclared variable foo in procedure bar
```

which I think are due to fluid declarations not working at compile time.  Similar warnings also appear in `conlaw.blg`, `crack.blg`, `liepde.blg`, `plot.blg`, `scope.blg`, `v3tools.blg`, but no other packages!  (Why only these?)

If fluid declarations fail at *load* time, the build fails when remaking `ineq` and `modsr` because

```
***** module solve1 of package solve cannot be loaded
```

when loading `solve`.  This happens because `solveeval1`, defined in `solve.red`, is undefined because the fluid declaration for `solvemethods!*` fails, so that `solvemethods!*` is unbound in

```
solvemethods!* := union('(odesolve!*),solvemethods!*);
```

Similarly, `inside!-solveeval` is unbound.

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

* Fix fluid to work correctly when compiling, loading and executing!
* Revise readch1 to make the *psl case the default?
* Revise yesp to handle id case and spacing correctly?


<!-- Local Variables: -->
<!-- fill-column: 1000 -->
<!-- eval: (auto-fill-mode -1) -->
<!-- eval: (visual-line-mode 1) -->
<!-- eval: (visual-wrap-prefix-mode 1) -->
<!-- End: -->
