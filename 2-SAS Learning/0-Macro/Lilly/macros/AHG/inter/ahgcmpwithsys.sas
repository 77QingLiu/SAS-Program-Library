%macro AHGcmpWithSys(
             folder=macros,
             filename=,
             rpath=&userhome/temp ,
             v1=sys/*sys  drug sub prot*/,
             v2=prot/*sys drug sub prot*/
             );

    %local i temp macroname ext rlevel1 rlevel2 basename;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname); 
    
  %let temp=&localtemp\&sysmacroname.sas;
  %let ext=%qscan(&filename,2,.);
  %let basename=%qscan(&filename,1,.);
  data _null_;
  file "&temp";
  put "rsubmit;";

    
  %local fld;
  %let fld=&folder;
  %if &ext=sas and &folder=program  %then %let fld=extract;
  %do i=1 %to 4;
    %if %qscan(sys drug sub prot,&i)=&v1 %then   %let rlevel1=%eval(&i-1);
    %if %qscan(sys drug sub prot,&i)=&v2 %then   %let rlevel2=%eval(&i-1);

  %end;

  
  put "x "" test -e ~/temp/&basename._&v1..&ext %nrstr(&&) rm -f ~/temp/&basename._&v1..&ext "" ;";
  put "x "" test -e ~/temp/&basename._&v2..&ext %nrstr(&&) rm -f ~/temp/&basename._&v2..&ext "" ;";
  put " x ""test -e &&root&rlevel1/&fld/&filename %nrstr(&&) co -p &&root&rlevel1/&fld/&filename  > ~/temp/&basename._&v1..&ext"" ; ";   ;
  put " x ""test -e &&root&rlevel1/&fld/&filename || echo No This level file  > ~/temp/&basename._&v1..&ext"" ; ";   ;
  put " x "" co -p &&root&rlevel2/&folder/&filename > ~/temp/&basename._&v2..&ext"" ; ";

  put "endrsubmit;";
  run;

  %include "&temp";  
  
  %AHGrdowntmp(filename=&basename._&v1..&ext, rpath=&rpath,open=1);
  %AHGrdowntmp(filename=&basename._&v2..&ext, rpath=&rpath,open=1);

  
  
%mend;
