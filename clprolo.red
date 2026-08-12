% module clprolo;  % CL dependent code for REDUCE.

% Author: Anthony C. Hearn.
% Modified by FJW for REDUCE on Common Lisp via "sl-on-cl.lisp".
% Time-stamp: <2026-08-06 17:33:48 franc>
% The standard version is "packages/support/pslprolo.red".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Redistribution and use in source and binary forms, with or without           %
% modification, are permitted provided that the following conditions are met:  %
%                                                                              %
%    * Redistributions of source code must retain the relevant copyright       %
%      notice, this list of conditions and the following disclaimer.           %
%    * Redistributions in binary form must reproduce the above copyright       %
%      notice, this list of conditions and the following disclaimer in the     %
%      documentation and/or other materials provided with the distribution.    %
%                                                                              %
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  %
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE    %
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE   %
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNERS OR CONTRIBUTORS BE    %
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR          %
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF         %
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS     %
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN      %
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)      %
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE   %
% POSSIBILITY OF SUCH DAMAGE.                                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This file defines functions, variables and declarations needed to
% make REDUCE and the underlying CL system compatible, and which need
% to be input before the system independent REDUCE source is loaded.

% The following switches are not being declared fluid as they should
% be using ECL, so as a temporary fix...
COMMENT
fluid '(
!*allbranch
!*arbvars
!*assert_inline_procedures
!*assert_procedures
!*assertbreak
!*assertinstall
!*assertstatistics
!*break
!*cf_taylor
!*commutedf
!*compxroots
!*cramer
!*evalassert
!*f5fractionfree
!*f5interreduce
!*f5parametric
!*f5parametricnormalize
!*f5statistics
!*f5sugar
!*f5usef5c
!*force_gnuplot_term
!*fullprecision
!*fullroots
!*lalr_verbose
!*multiplicities
!*multiroot
!*nocommutedf
!*noint
!*nointint
!*nonlnr
!*nosturm
!*odesolve_basis
!*odesolve_check
!*odesolve_diff
!*odesolve_equidim_y
!*odesolve_expand
!*odesolve_explicit
!*odesolve_fast
!*odesolve_full
!*odesolve_implicit
!*odesolve_noint
!*odesolve_norecurse
!*odesolve_noswap
!*odesolve_plus_or_minus
!*odesolve_verbose
!*parse_errors_fatal
!*partialintint
!*partialintdf
!*partialintint
!*plus_or_minus
!*prephold
!*printlower
!*psprintorder
!*pwrds
!*qgosper_down
!*qgosper_specialsol
!*qhullkeepfiles
!*qsum_nullspace
!*qsum_trace
!*qsumrecursion_certificate
!*qsumrecursion_down
!*qsumrecursion_exp
!*qsumrecursion_profile
!*ranum
!*rational
!*ratroot
!*redefmsg
!*rlabout
!*rootmsg
!*rtrace
!*show!-shared
!*show_grid
!*simpnoncomdf
!*smtabout
!*smtprompt
!*solvesingular
!*taylorautocombine
!*taylorautoexpand
!*taylorkeeporiginal
!*taylorprintorder
!*tracelex
!*tracespecfns
!*trallfac
!*trigform
!*trlimit
!*trnonlnr
!*trroot
!*trsolve
!*trsum
!*trtaylor
!*usetaylor
!*verboseload
!*xpartialint
!*xpartialintdf
!*xpartialintint
!*zb_factor
!*zb_inhomogeneous
!*zb_proof
!*zb_timer
!*zb_trace
!*zeilberg);

fluid '(!*savedef !*gc!-hook!* !*noinlines);

global '(!*psl !*csl);                  % CL is neither
!*psl := t;                             % but pretend to be PSL!

% NB: !*psl is used dynamically and essentially in readch1 in
% "rlisp/tok.red" (and statically in code that is ignored in
% "rlisp/switch.red").

% Support for package creation.

symbolic procedure create!-package(u,v);
   % Make module list u into a package with path v.
   % Second argument is no longer used.
   if null idp car u then typerr(car u,"package name")
   else <<
      put(car u,'package,u);
%     put(car u,'path,if null v then list car u else v);
      car u >>;

% Try to work around an issue with ECL that calls of switch when
% building REDUCE do not lead to the necessary fluid declaration. Note
% that limited syntax is available when reading this file!

symbolic procedure formswitch(u,vars,mode);
   % Call fluid explicitly and then call switch as usual.
   begin scalar swlist, switches, x, fllist;
      swlist := if atom cadr u then cdr u else cadr u;
      switches := swlist;
      while switches do <<
         x := car switches;  switches := cdr switches;
         % Handle switch default settings:
         if pairp x then x := cadr x;
         x := intern list2string ('!* . explode2 x);
         % if and(not fluidp x, not globalp x) then
         fllist := x . fllist;
      >>;
      return list('progn,
         list('fluid, mkquote fllist, t),
         list('switch, mkquote swlist));
      % Evaluate switch at both compile time and load time.
      % list('bothtimes, list('switch, mkquote swlist)));
   end;

put('switch, 'formfn, 'formswitch);

% create!-package('(clprolo),nil);

% endmodule;

end;
