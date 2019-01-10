% module clprolo;   % CL dependent code for REDUCE.

% Author: Anthony C. Hearn.

% Modified by FJW for REDUCE on Common Lisp.
% The standard version is "packages/support/pslprolo.red".

% This file defines functions, variables and declarations needed to
% make REDUCE and the underlying CL system compatible, and which need
% to be input before the system independent REDUCE source is loaded.

fluid '(lispsystem!* !*savedef !*gc!-hook!*);

lispsystem!* := !*features!*;			% must include COMMON-LISP

global '(!*psl !*csl);					% CL is neither!

% Support for package creation.

symbolic procedure create!-package(u,v);
   % Make module list u into a package with path v.
   % Second argument is no longer used.
   if null idp car u then typerr(car u,"package name")
   else <<
      put(car u,'package,u);
%     put(car u,'path,if null v then list car u else v);
      car u >>;

% create!-package('(clprolo),nil);

symbolic procedure evload l;
   % Modified from cslprolo.red (which calls load!-module, not load).
   % Written like this because load is defined as a statement in
   % "rlisp/module.red".  Might be better defined in "sl-on-cl.lisp".
   while l do << apply(function load, list car l); l := cdr l >>;

% These functions are already defined in Common Lisp (and union is
% needed in the build process before it is defined in the rlisp
% module):

flag('(first second third rest evenp oddp union intersection),'lose);

% Common Lisp provides integer functions gcd and lcm, which I could use.

% flag('(gcdn),'lose);     % Defined in bignum package.

% Common Lisp provides numerical predicates >= and <=, which I could use.

% flag('(geq leq reversip),'lose);
flag('(reversip),'lose);

% yesp1 is more or less equivalent to y-or-n-p.

remflag('(yesp1),'lose);

symbolic procedure yesp1; y!-or!-n!-p();

flag('(yesp1),'lose);

% orderp is needed in rlisp/switch, so define it here.

symbolic procedure orderp(u,v);
   % This CL-specific definition of ORDERP is designed to work in
   % lexicographical order.  It assumes arguments are truly id's,
   % which should be true with current REDUCE.  Ignore case.
   string!-not!-greaterp(symbol!-name u, symbol!-name v);

% TEMPORARY -- Ignore inline declarations for now:
put('inline, 'newnam, 'symbolic);
% or could do
% !*noinlines := nil;

% Note that rlisp/proc.red claims that

% !*loginlines will cause a compile-time report of patterns of inline usage.

% This is just what I need to turn off in faslout, but I think that
% this variable is ignored.

% endmodule;

end;
