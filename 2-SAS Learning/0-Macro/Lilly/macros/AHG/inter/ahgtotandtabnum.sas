%macro AHGtotandtabnum(OneTOT,bigstr=bigstring,print=yes);
%let rcrpipe=;

%AHGrpipe( %str(grep -i tabno^ &root3/tools/&OneTOT 2>/dev/null),rcrpipe );

%if %length(&rcrpipe) %then 
%do;
%let rcrpipe=%sysfunc(tranwrd(&rcrpipe,Table,t));
%let  rcrpipe=%sysfunc(compress(&rcrpipe));
%let  rcrpipe=%lowcase(%substr(&rcrpipe,7));
%end;

%let &bigstr=&&&bigstr @ &OneTOT  &rcrpipe ;
%if &print=yes %then %put &&&bigstr @ &OneTOT  &rcrpipe ;

%mend;

