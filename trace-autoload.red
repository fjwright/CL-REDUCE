symbolic macro procedure tr u;
   {'autoload!-trace, mkquote u};

symbolic procedure autoload!-trace v;
   % E.g. v = (tr fn1 fn2 ...)
   <<
	  load "trace";
	  eval v
   >>;

symbolic procedure autoload!-trace v;
   % E.g. v = (tr fn1 fn2 ...)
   print v;
