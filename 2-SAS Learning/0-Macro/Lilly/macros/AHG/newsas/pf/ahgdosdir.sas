%macro AHGdosdir(name,perldir=0,len=300);

  option noxwait;
  x "cd ""&name"" ";
  x "command & cd >&localtemp\tmp.tmp ";
  %global dosdir;

  data _null_;
    length dir $&len;
    infile 'c:\tmp.tmp';
    input dir;
    if &perldir then dir=tranwrd(dir,'\','\\');
    call symput('dosdir',dir);
  run;


%mend;

/*  %local i cnt sector short modi perl dos;*/
/*  %let name=&name\;*/
/*  %put &name;*/
/*  %let modi=%substr(&name,1,%index(&name,\));*/
/*  %let cnt=%AHGcount(&name,dlm=\);*/
/*  %do i=1 %to &cnt;*/
/*    %let sector=%substr(&name,1,%index(&name,\)-1);*/
/*    %if %length(&sector)>8 %then %let sector=%sysfunc(compress(&sector));*/
/*    %if %length(&sector)>8 %then %let short=%scan(%substr(&sector,1,6)~1,1);*/
/*    %else %let short=&sector;*/
/*    %put sec=&sector;*/
/*    %put sho=&short;*/
/*    %let modi=&modi\\&short;*/
/*    %put modi=&modi;*/
/*    %if &i<&cnt %then %let name=%substr(&name,%index(&name,\)+1);*/
/*  %end;*/
/*  %let perl=%substr(&modi,3)\\;*/
/*  %let dos=%sysfunc(tranwrd(&perl,\\,\));*/
/*  %if &perldir %then &perl;*/
/*  %else  &dos;*/



