% Standard Lisp code to help with bootstrapping REDUCE from Lisp.
% Modified Standard Lisp version of "packages/support/build.red".

% Author: Anthony C. Hearn.
% Modified by ACN for the Sourceforge version.
% Modified again by FJW for Common Lisp REDUCE.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Redistribution and use in source and binary forms, with or without		   %
% modification, are permitted provided that the following conditions are met:  %
%																			   %
%    * Redistributions of source code must retain the relevant copyright	   %
%      notice, this list of conditions and the following disclaimer.		   %
%    * Redistributions in binary form must reproduce the above copyright	   %
%      notice, this list of conditions and the following disclaimer in the	   %
%      documentation and/or other materials provided with the distribution.	   %
%																			   %
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  %
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE	   %
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE   %
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNERS OR CONTRIBUTORS BE	   %
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR		   %
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF		   %
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS	   %
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN	   %
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)	   %
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE   %
% POSSIBILITY OF SUCH DAMAGE.												   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FJW: This file primarily defines function load!-package!-sources,
% which is required for bootstrapping.

(global '(loaded!-packages!*))

% Since some of the early modules may have tabs in them, we must redefine
% seprp. Note that there is a TAB in this definition and that may not be
% readily visible when merely editing the file.

(de seprp (u) (or (eq u '! ) (eq u '!	) (eq u !$eol!$)))

(de mkfil (u)
   (cond
      ((stringp u) u)
      ((not (idp u)) (typerr u "file name"))
      (t (string!-downcase u))))

% FJW: Convert the module u in package directory v, or the current
% directory if v is nil, to a (lower-case) file name relative to
% the directory containing packages.
% Also defined in remake.red!
(de module2!-to!-file (u v)
   (progn
      (setq u (concat2 (mkfil u) ".red"))
      (cond
         (v
            (concat2
               "$reduce/packages/"
               (concat2 (mkfil v) (concat2 "/" u))))
         (t u))))

% FJW: Print name of file being read.
(de inmodule (u v)
   (prog (file)
      (terpri)
      (terpri)
      (prin2 "+++ Reading file: ")
      (prin2 (setq file (module2!-to!-file u v)))
      (terpri)
      (setq u (open file 'input))
      (setq v (rds u))
      (setq cursym!* '!*semicol!*)
      (prog nil
   whilelabel
         (cond ((not (not (eq cursym!* 'end))) (return nil)))
         (progn (prin2 (eval (form (xread nil)))) (prin2 " "))
         (go whilelabel))
      (rds v)
      (close u)))

(de load!-package!-sources (u v)
   (prog (!*int !*echo w)
      (inmodule u v)
      (cond ((setq w (get u 'package)) (setq w (cdr w))))
      (prog nil
   whilelabel
         (cond ((not w) (return nil)))
         (progn (inmodule (car w) v) (setq w (cdr w)))
         (go whilelabel))
      (setq loaded!-packages!* (cons u loaded!-packages!*))))
