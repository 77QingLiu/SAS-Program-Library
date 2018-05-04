%macro AHGreadlines;
  %global %AHGwords(gglline,50,base=0)    ;
  %AHGfuncloop(%nrbquote( let ahuige=; ) ,loopvar=ahuige
    ,loops=%AHGwords(gglline,20,base=0) );
  filename ahgclip clear;
  filename ahgclip clipbrd;
  %local clipline;

  %if %sysfunc(exist(ahgclipdsn)) %then 
  %do;
    data ahgclipdsn0;
      set ahgclipdsn;
    run;
  %end;

  data   ahgclipdsn;
  infile ahgclip truncover end=end;
  format   line $500.;
  input line 1-500 ;
  if missing(line) then return;
  loopid+1;
  call symput(compress('gglline'||%AHGputn(loopid)),line);
  if end then call symput('gglline0',left(%AHGputn(loopid)));
  if not missing(line) then output;
  run;

  %global ahgtask;
  %let ahgtask=;
  %local nobs;
  %AHGnobs(ahgclipdsn,into=Nobs);
  %if &Nobs=1 %then %let ahgtask=one line mode;
  %else %if &Nobs=9 and %sysfunc(prxmatch(m/[d\.\s*]{9}/,%bquote(&gglline1))) %then %let ahgtask=sudoku;
  %else %if %sysfunc(prxmatch(m/^\s*data\s+/i,%bquote(&gglline1))) %then %let ahgtask=data step;
  %else %if %sysfunc(prxmatch(m/^\s*proc\s+/i,%bquote(&gglline1))) %then %let ahgtask=proc step;

  %if %sysfunc(exist(ahgclipdsn0)) %then 
  %do;
  %global ahgclipdiff;
  %let ahgclipdiff=1;
    proc sql noprint;
      create table ahgclipdiff as
      select *
      from ahgclipdsn
      except
      select *
      from ahgclipdsn0
      union
      select *
      from ahgclipdsn0
      except
      select *
      from ahgclipdsn
      ;
      quit;

  %AHGnobs(ahgclipdiff,into=ahgclipdiff);
    
  %end;

  %AHGpm(ahgtask);
%mend;


%macro ahgreadkeywords(clipline);
  %local i;
  %global %AHGwords(gglkey,20) %AHGwords(ggltype,20);
  %AHGfuncloop(%nrbquote( let ahuige=; ) ,loopvar=ahuige
    ,loops=%AHGwords(gglkey,20) %AHGwords(ggltype,20));
  %do i=1 %to 20;

  %let gglkey&i= 
                          %sysfunc( 
                            prxchange
                          (
                           s/\s*(=?)([^%str(%')%str(%")\s=]+|%str(%')[^%str(%')]+%str(%')|%str(%")[^%str(%")]+%str(%")).*/\1\2/,1,&clipline                    
                          )        
                        );

  %let clipline= 
                            %sysfunc( 
                            prxchange
                          (
                           s/\s*(=?)([^%str(%')%str(%")\s=]+|%str(%')[^%str(%')]+%str(%')|%str(%")[^%str(%")]+%str(%"))(.*)|/\3/,1,&clipline 
                          )        
                        );



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
%IF not %symexist(AHGgoogleInit) %then
%do;
/* 
Initial things
*/
/*data sasuser.nowlibs;*/
/*  set sashelp.vmember;*/
/*run;*/
%end;

%global AHGgoogleInit;


%AHGclearlog;
%local ahgthelast;
%let ahgthelast=&syslast;
%AHGreadlines;option nosymbolgen nomlogic;
                      %macro h_oneloop;
                      %if 0 %then ;
                      %else %if &gglkey1 eq _ %then 
                        %do;
                        data _null_;
                          file ahgclip;
                          put "&AHGthelast";
                        run;
                        %end;
                      %else %if %AHGblank(&gglkey2) and %AHGnonblank(&gglkey1) 
                          /* ONLY ONE KEYWORD, KEYWORD IS FILE OR DATASET*/
                          and %sysfunc(exist(&gglkey1)) %then %AHGopendsn(&gglkey1);
                      %else %if %AHGblank(&gglkey2) and %AHGnonblank(&gglkey1) 
                          /* ONLY ONE KEYWORD, KEYWORD IS FILE OR DATASET*/
                          and  %sysfunc(fileexist(&gglkey1)) %then %AHGopenfile(&gglkey1);
                            /* ONLY ONE KEYWORD, KEYWORD IS QUOTED STRING*/
                      %else %if %AHGblank(&gglkey2) and %AHGnonblank(&gglkey1) and (&ggltype1=str or %sysfunc(anydigit(&gglkey1 ))   ) %then 
                         %do;
                          %local strict ;
                          
                          %let strict=0;
                          %if %sysfunc(prxmatch(/^\=/i,%bquote(&gglkey1))) %then 
                            %do;
                            %let strict=1;
                            %AHGpm(strict);
                            %let gglkey1=%substr(&gglkey1,2);
                            %end;

                          %AHGcatch(&ahgthelast,&gglkey1, strict=&strict);
                         %end;
                      %else %if %AHGblank(&gglkey2) and %AHGnonblank(&gglkey1)   %then 
                          %DO;
                          %local alibname;
                          %let aLibname=;
                          proc sql noprint;
                            select strip(path) into :aLibname
                            from sashelp.vlibnam
                            where libname=upcase("&gglkey1")
                            ;
                          quit;
                          %put (&alibname);
                          %if %AHGnonblank(&alibname) %then x "explorer.exe ""%trim(&alibname)""";;

                          %END;



                      %else %if %AHGblank(&gglkey3) and %AHGnonblank(&gglkey2) %then
                        %do;

                        %if  &ggltype1=data %then 
                            %do;
                            %local strict; 
                            %let strict=0;
                            %if %sysfunc(prxmatch(/^\=/i,%bquote(&gglkey2))) %then 
                              %do;
                              %let strict=1;
                              %AHGpm(strict);
                              %let gglkey2=%substr(&gglkey2,2);
                              %end;

                            %AHGcatch(&gglkey1,&gglkey2, strict=&strict);
                            %end;

                        %end;
                     
                       %let ahgthelast=&syslast;
                      %mend;

%if &ahgtask=one line mode %then
    %do;
    %local i ;

    %do i=1 %to &gglline0;

    %ahgreadkeywords(%bquote(&&gglline&i));

    %put #############################  ahgreadkeywords(&&gglline&i);;
    %h_oneloop;
    %end;


    %end;

%else %if &ahgtask=data step and (&ahgclipdiff>0) %then
    %do;
    %local i j dsns one varlist allvar onedata;
    %let allvar=;

    %let one=;
    %if %sysfunc(prxmatch(m/\s*(data)\s+([\w|\.]+).*/i,&gglline1)) %then 
        %do;
        %let one=%sysfunc(prxchange(s/\s*(data)\s+([\w|\.]+).*/\2/i,1,&gglline1));
        %let varlist=;
        %AHGvarlist(&one,Into=varlist,dlm=%str( ),global=0);
        %AHGpm(one varlist);
        %do i=1 %to %AHGcount(&varlist);
          %local getit onevar;
          %let onevar=%scan(&varlist,&i);
          %let getit=0;
          %do j=1 %to &gglline0;
            %if &getit=0 %then %if %sysfunc(prxmatch(m/\b&onevar\b/i,&&gglline&j)) %then 
              %do;
              %let allvar=&allvar &onevar;
              %let getit=1;
              %end;
          %end;
        %end;

        %AHGpm(allvar);
        %let onedata=t_%AHGrdm;
        data &onedata;
          set &one;
          keep &allvar;
        run;

       %AHGopendsn(&onedata);


       %end;


                                                      %macro _nouse_;
                                                      %local i dsns one;
                                                      %let dsns=;

                                                      %do i=1 %to &gglline0;
                                                      %let one=;
                                                      %if %sysfunc(prxmatch(m/\s*(data)\s+([\w|\.]+).*/i,&&gglline&i)) %then %let one=%sysfunc(prxchange(s/\s*(data)\s+([\w|\.]+).*/\2/i,1,&&gglline&i));
                                                      %if  %AHGnonblank(&one) %then %AHGopendsn(&one);

                                                      %let one=;
                                                      %if %sysfunc(prxmatch(m/\s*(set)\s+([\w|\.]+).*/i,&&gglline&i)) %then %let one=%sysfunc(prxchange(s/\s*(set)\s+([\w|\.]+).*/\2/i,1,&&gglline&i));
                                                      %if  %AHGnonblank(&one) %then %AHGopendsn(&one);
                                                     
                                                      %end;
                                                      %mend;
  %end;

%else %if (&ahgtask=data step) and (&ahgclipdiff=0) %then

    %do;
    %local i j dsns one varlist allvar onedata;
    %let allvar=;

    %let one=;
    %if %sysfunc(prxmatch(m/\s*(data)\s+([\w|\.]+).*/i,&gglline1)) %then 
        %do;
        %let one=%sysfunc(prxchange(s/\s*(data)\s+([\w|\.]+).*/\2/i,1,&gglline1));
        %let varlist=;
        %AHGvarlist(&one,Into=varlist,dlm=%str( ),global=0);
        %AHGpm(one varlist);
        %do i=1 %to %AHGcount(&varlist);
          %local getit onevar;
          %let onevar=%scan(&varlist,&i);
          %let getit=0;
          %do j=1 %to &gglline0;
            %if &getit=0 %then %if %sysfunc(prxmatch(m/\b&onevar\b/i,&&gglline&j)) %then 
              %do;
              %let allvar=&allvar &onevar;
              %let getit=1;
              %end;
          %end;
        %end;

        %AHGpm(allvar);
        %let onedata=t_%AHGrdm;
        %AHGalltocharNew(&one,out=&onedata);
        data &onedata;
          set &onedata;
          %do i=1 %to %AHGcount(&allvar);;
            %scan(&allvar,&i)='<font  color="red">' ||trim(%scan(&allvar,&i))||'</font>';;
          %end;
        run;

          %macro html(dsn );
          %local html;
          %let html=%AHGtempdir\myrdm.HTML;
              ods html file="&html";  
              proc print data=&dsn;
              run;
              ods html close;   
/*              x "start &html";*/
          %mend;


          %html(&onedata);
        %end;
    %end;

%else %if &ahgtask=proc step %then
    %do;
    %local i dsns one;
    %let dsns=;

    %do i=1 %to &gglline0;
    %let one=;
    %if %sysfunc(prxmatch(m/.*data\s*\=\s*([\w|\.]+).*/i,&&gglline&i)) %then %let one=%sysfunc(prxchange(s/.*data\s*\=\s*([\w|\.]+).*/\1/i,1,&&gglline&i));
    %if  %AHGnonblank(&one) %then %AHGopendsn(&one);
 
    %let one=;
    %if %sysfunc(prxmatch(m/.*out\s*\=\s*([\w|\.]+).*/i,&&gglline&i)) %then %let one=%sysfunc(prxchange(s/.*out\s*\=\s*([\w|\.]+).*/\1/i,1,&&gglline&i));
    %if  %AHGnonblank(&one) %then %AHGopendsn(&one);
    %end;
    %end;

%else %if &ahgtask=sudoku %then 
  %do;
  %put #######   sudoku ########;
  data sudoku;
    array num  (1:9,1:9) n11-n19 n21-n29 n31-n39 n41-n49 n51-n59 n61-n69 n71-n79 n81-n89 n91-n99;
    do i=1 to 9;
    set ahgclipdsn point=i;
      do j=1 to 9;
         put i= j=;
         num(i,j)=input(scan(line,j,' '),best.);;
      end;
    if i=9 then 
    do;
    output;
    stop;
    end;
    end;
    drop  j line;
  run;

  %sudoku;
  %end;



 
%mend;

%macro sudoku;
option mprint;

data _null_;

	 call symput('ahuigefromtime',put(time(),time8.));

run;
%local inc bk stkn;

  %let inc=000;

  %let bk=000;

  %let stkn=000;

libname cache  "d:\temp" memlib;

  proc datasets lib=cache kill;

  run;



/* Turn on full caching */

options memcache = 4;


%let columns=6,3,5,7,8,9,4,2,1;

%let rows=2,3,4,7,8,9,5,6,1;

                                %macro printMtrx(dsn,open=0);/*print matrix*/

                                  data _null_;
                                    set &dsn;
                                    %local afile;
                                    %if &open %then
                                    %do;
                                    %let afile=%AHGtempdir\%AHGrdm.txt;
                                    file "&afile";
                                    %end;
                                    array num(1:9,1:9) n11-n19 n21-n29 n31-n39 n41-n49 n51-n59 n61-n69 n71-n79 n81-n89 n91-n99;
                                    do i=1 to 9;
                                      do j=1 to 9;
                                        put num(i,j)@@;
                                      end;
                                      put;
                                    end; 
                                  run;
                                  %if &open %then %AHGopenfile(&afile);

                                %mend;

                                  %macro backup(stkn);/* create datasets backup and bk*** from dataset ori */
                                  /*  %let bk=%incr(&bk);*/
                                    data cache.backup(keep=n11-n19 n21-n29 n31-n39 n41-n49 n51-n59 n61-n69 n71-n79 n81-n89 n91-n99) 
                                         cache.bk&stkn;
                                      set cache.ori;
                                    run;
                                  %mend;




                                          
                                        %macro tryAgain ;/*rollback to the latest stage and choose another number */
                                          %let inc=%incr(&inc);
                                          data cache.stack cache.stack&inc; /*stack(n)-snapshot*/
                                            set cache.stack end=eof;
                                            put _all_;
                                            if eof then
                                              do;
                                              call symput('i',outi);
                                              call symput('j',outj);
                                              call symput('value',substr(outvalue,1,1));
                                              call symput('id',left(stkn));
                                              if length(compress(outvalue))=1 then delete;
                                              outvalue=substr(outvalue,2);
                                              end;
                                          run;
                                          %let id=%addz(&id);

                                          data cache.ori;
                                            set cache.bk&id;
                                            array num(1:9,1:9) n11-n19 n21-n29 n31-n39 n41-n49 n51-n59 n61-n69 n71-n79 n81-n89 n91-n99;
                                            num(&i,&j)=&value;
                                          run;

                                        %mend;







                                              %macro goThrough;

                                              data cache.ori (keep=n11-n19 n21-n29 n31-n39 n41-n49 n51-n59 n61-n69 n71-n79 n81-n89 n91-n99) 
                                                  cache.single(keep=outj outi outvalue) ; /*check relevant elements to see whether this element can be decided*/
                                                set cache.ori;
                                                array num(1:9,1:9) n11-n19 n21-n29 n31-n39 n41-n49 n51-n59 n61-n69 n71-n79 n81-n89 n91-n99;
                                                call symput('wrongway','0');
                                                wrongway=0;
                                                call symput('progressed','0');
                                                progressed=0;
                                                call symput('over','1');
                                                over=1;
                                                do until(progressed=0 or enough=300);
                                              /*    put 'asdfjlsdfhkjsdhfkjdshafkjsahfdkjsah';*/
                                                  enough+1;
                                                  progressed=0;
                                                  lth=9;
                                                  do i=&rows;
                                                    if wrongway then leave;
                                                    do j=&columns;
                                                      if not missing(num(i,j)) then continue;
                                                      if normal(0)<0 then  string='123456789';
                                              		    else   string='987654321';
                                                      /*narrow options from column info*/
                                                      do ii=1 to 9;
                                                      string=compress(string,put(num(ii,j),1.));
                                                      end;
                                                      /*narrow options from raw info*/
                                                      do jj=1 to 9;
                                                      string=compress(string,put(num(i,jj),1.));
                                                      end;
                                                      iii=(ceil(i/3)-1)*3+1;
                                                      jjj=(ceil(j/3)-1)*3+1;
                                                      *put i= j= iii= jjj=;
                                                      /*narrow options from squre info*/
                                                      do k=iii to iii+2;
                                                        do l=jjj to jjj+2;
                                                          string=compress(string,put(num(k,l),1.));
                                                        end;
                                                      end;
                                                      lg=length(compress(string));
                                              /*        put i= j= string= lg=;*/
                                                      if string='' then do;wrongway=1;call symput('wrongway','1');leave;end;

                                                      if lg<lth then
                                                        do;
                                                        outi=i; outj=j; outvalue=string;lth=lg;
                                                        end;
                                                      if lg=1 then
                                                        do;
                                                        num(i,j)=input(string,best8.);
                                                        progressed=1;
                                                        call symput('progressed',1);
                                                        end;
                                                    end;
                                                  end;
                                                end;
                                                do i=1 to 9;
                                                    if not over then leave;
                                                    do j=1 to 9;
                                                    if missing(num(i,j)) then 
                                                      do;
                                                      over=0;
                                                      leave;
                                                      end;
                                                    end;
                                                end;
                                                if not wrongway then output cache.ori;
                                                if not over then call symput('over','0');
                                                if not over and not wrongway and not progressed then  output cache.single ;
                                              run;

                                              %mend;




                                                  %macro append(stkn);/* Add one record in the stack*/
                                                    data cache.single;
                                                      set cache.single;
                                                      stkn=&stkn;
                                                    run;

                                                    proc datasets;
                                                      append base=cache.stack
                                                      data=cache.single;
                                                    run;
                                                  %mend;




                                                  %macro addz(n);/*PUT n with format z3.*/
                                                    %if %length(&n)=1 %then %let n=00&n;
                                                    %if %length(&n)=2 %then %let n=0&n;
                                                    &n
                                                  %mend;







                                                  %macro incr(n); /*n++ with format z3.*/
                                                    %let n=%eval(&n+1);
                                                    %addz(&n)
                                                  %mend;







                                                          %macro main;

                                                            %backup;

                                                            %gth:

                                                            %goThrough;
                                                            %put over=&over progressed=&progressed wrongway=&wrongway;
                                                            %if &over %then 
                                                              %goto exit;
                                                            %else 
                                                              %do;
                                                              %if &wrongway %then 
                                                                %do;
                                                                %put ##############  wrongway  #############;
                                                                %printMtrx(cache.ori);
                                                                %tryAgain;
                                                                %goto gth ;
                                                                %end;
                                                              %else;
                                                                %do;
                                                                %if &progressed %then
                                                                  %goto gth ;
                                                                %else;
                                                                  %do;
                                                                  %put not progressed;
                                                                  %let stkn=%incr(&stkn);
                                                                  %append(&stkn);
                                                                  %backup(&stkn);
                                                                  %put #######   Now  ########;
                                                                  %printMtrx(ori);
                                                                  %tryagain;
                                                                  %goto gth ;
                                                                  %end;
                                                                %end;
                                                              %end;
                                                            %exit:
                                                          %mend;


                                                %macro big;
                                                  %main;

                                                  %printMtrx(cache.ori,open=1);
                                                

                                                data _null_;

                                                	 diff=time()-input("&ahuigefromtime",time8.);

                                                	 put '################ time used :' diff time8.;

                                                run;
                                                %mend;

DATA cache.ori;
  set sudoku;
run;
%big;
%mend;



%macro generator;
*modify source;

  data sudoku;

    array num  (1:9,1:9) n11-n19 n21-n29 n31-n39 n41-n49 n51-n59 n61-n69 n71-n79 n81-n89 n91-n99;

    do i=1 to 9;

      do j=1 to 9;

        input num(i,j) @@;

      end;

    end;

    drop i j;
    cards;

3 5 . . . . 9 . . 
9 . 7 . . . 6 3 1 
. . . . . . . . 4 
. . . 2 7 . . . . 
. . . 1 6 8 . . . 
. . . . . 5 . . . 
. 6 . . . . 5 . 8 
5 . . . . . 7 . 3 
8 . . . . . 2 1 6


    ;

    run;


%mend;



