%macro AHGaddcomma(mac,comma=%str(,) );
%if %AHGnonblank(&mac) %then %sysfunc(tranwrd(     %sysfunc(compbl(&mac)),%str( ),&comma       ))   ;
%mend;
