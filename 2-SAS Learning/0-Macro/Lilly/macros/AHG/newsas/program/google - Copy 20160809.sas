
%macro ahgreadkeywords;
  %global %AHGwords(gglkey,20) %AHGwords(ggltype,20);
  %AHGfuncloop(%nrbquote( let ahuige=; ) ,loopvar=ahuige
    ,loops=%AHGwords(gglkey,20) %AHGwords(ggltype,20));

  filename ahgclip clear;
  filename ahgclip clipbrd;
  %local clipline;

  data   ahgclipdsn;
  infile ahgclip truncover;
  format cmd  line $500.;
  input line 1-500 ;
  call symput('clipline',line);
  run;

  %AHGpm(clipline);

  %do i=1 %to 20;
/*  %let gglkey&i=%scan(&clipline,&i,%str( ));*/
/*  %let clipline=%left(&clipline);*/
/*  %if*/
  %let gglkey&i=%sysfunc( 
                          prxchange
                          (
                          %nrbquote(s/\s*(%str(%')[^%str(%')]+%str(%')).*/\1/),1,&clipline                   
                          )        
                        );

/*  %put ########### ;%AHGpm(gglkey&i);*/
/**/
  %if %AHGnonblank(&&gglkey&i) and %sysfunc(exist(&&gglkey&i)) %then %let ggltype&i=data;
  %if %sysfunc(prxmatch(/^[%str(%')%str(%")]/,&&gglkey&i)) or %sysfunc(prxmatch(/[\%str(%')\%str(%")]$/,&&gglkey&i)) %then %let ggltype&i=str;
  %end;

  

  %AHGpmlike(gglkey);
  %AHGpmlike(ggltype);
%mend;

 %macro dummy;

  %local googlecmd;
  %let googlecmd=%nrstr("powershell.exe cat D:\newsas\meta\googlelike.txt|select-string ""^AHG&ahgGoogleID""|%%{ $_ -replace '^AHG&ahgGoogleID',' '} > D:\TEMP\googleresult.txt ");
  x %unquote(&googlecmd);
  
  filename ahgclip clear;
  filename ahgclip clipbrd;

  %AHGreadline(file=D:\TEMP\googleresult.txt,out=googlein);

  data _null_;
    file ahgclip;
    
    set googlein;
    if _n_=1 then put ' ';
    put line;
  run;
  %let ahggoogleid=%sysfunc(mod(%eval(&ahggoogleid+1),&ahggooglecount));
  %if &ahggoogleid=0 %then %let ahggoogleid= &ahggooglecount;
  %mend;

%macro AHGprxdsn(str,into=ahgprxdsn,refresh=0);
%local lib dsn;
%let lib=%scan(&str,-2);
%let dsn=%scan(&str,-1);
%if (not %sysfunc(exist(sashelp__vmember))) or &refresh %then
%do;
  data sashelp__vmember;
    set sashelp.vmember;
  run;
%end;
  proc sql;
    select into :&into separated by ' '
    from sashelp.vmember
    where 
    ;
    quit;
%mend;



%macro AHGgoogle;
/* 
for reading keyworcs
*/
%AHGclearlog;
%ahgreadkeywords;

%macro dummy;
%if %AHGblank(&gglkey2) and %AHGnonblank(&gglkey1)
    and (%sysfunc(exist(&gglkey1)) or %sysfunc(fileexist(&gglkey1))) %then %AHGclip;
%else %if %AHGblank(&gglkey2) and %AHGnonblank(&gglkey1) %then 
     %do;
     %put;
     %put;
     %put &gglkey1;
     %end;
%else 
  %do;
  %local strict;
  %let strict=0;
  %if %sysfunc(prxmatch(/^\=/i,%bquote(&gglkey2))) %then 
    %do;
    %let strict=1;
    %AHGpm(strict);
    %let gglkey2=%substr(&gglkey2,2);
    %end;
  %else %put #####################nonono;
  %if  &ggltype1=data %then %AHGcatch(&gglkey1,&gglkey2, strict=&strict);
  %end;

%mend;
 
%mend;




/*""^AHG&ahgGoogleID""*/
/*|%{ $_ -replace ""^AHG&ahgGoogleID"",' ' }*/

/* select-string ""^AHG&ahgGoogleID"" |*/
/*|%{ $_ -replace ""^AHG&ahgGoogleID"","" "" }*/



