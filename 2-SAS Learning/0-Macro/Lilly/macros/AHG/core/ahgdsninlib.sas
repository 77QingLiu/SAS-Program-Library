%macro AHGdsninlib(lib=WORK,list=dsnlist,lv=2,mask=,global=0);
%local DsnInlibtemp;
%if %lowcase(&lib)=work %then %let lv=1;
%AHGgettempname(DsnInlibtemp);
%if &global %then %global &list;
  proc datasets lib=&lib nolist;

    contents data=_all_ memtype=data out=work.&DsnInlibtemp noprint;
  run;


/*  %AHGdatanodupkey(data =&DsnInlibtemp , out = , by =MEMNAME );*/
   %local outvalue;
   %if &lv=1 %then %let outvalue=MEMNAME;
   %else  %let outvalue="&lib.."||MEMNAME;
  proc sql noprint;
    select  &outvalue into :&list  separated by ' '
  from sashelp.vstable
  where upcase("&lib")=libname  and not %AHGeqv(memname, "&DsnInlibtemp")  %if not %AHGblank(&mask) %then %str(and upcase(memname) like %upcase(&mask));
      
  ;
  quit;
  
%AHGdatadelete(data=&DsnInlibtemp);  

%mend;


