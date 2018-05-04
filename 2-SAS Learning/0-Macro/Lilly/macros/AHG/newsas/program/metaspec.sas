%macro metaspec(DSN,var,ALLADAM);
%LOCAL outdsn tran varlist define dsnlist HTML kword;
%let kword=&dsn;
%if %index(&dsn,.)=0 %then %let dsn=specs.meta_&dsn;
%AHGgettempname(outdsn);
%AHGgettempname(tran);
%AHGgettempname(define);
%AHGcatch(&DSN,"&VAR",out=&outdsn,open=0);


 

%local allget;
%let allget=;

                                                          %macro ONETERM(dsn,var);
                                                          %local outdsn;
                                                          %let outdsn=%scan(&dsn,-1,.);
                                                          %let allget=&allget &outdsn;

                                                          %AHGcatch(&dsn,"&VAR",out=&outdsn.xx,open=0,strict=0);
                                                          %AHGpm(kword);
                                                          %AHGcatch(&outdsn.xx,"&kword",out=&outdsn,open=0,strict=0);
                                                          %mend;


%LOCAL defineliST ;
%let definelist=;
%AHGdsnInLib(lib=specs,list=definelist,mask='%%_define_%%');

%AHGfuncloop(%nrbquote( ONETERM(thedsn,&var) ) ,loopvar=thedsn,loops=&definelist);
/*%AHGshow(alllist->&definelist);*/


%AHGdsnInLib(lib=specs,list=dsnlist,mask='%%meta_ad%%');

                                                              %macro findadam;
                                                              %local i;
                                                              %do i=1 %to %AHGcount(%str(&dsnlist));
                                                              %let one=%scan(&dsnlist,&i,%str( ));
                                                              %if %length(&one)-%length(%sysfunc(compress(&one,_)))=1 and %index(&one, META_AD) %then %let alladam=&alladam %scan(&dsnlist,&i,%str( ));
                                                              %else %AHGpm(one);
                                                              %end;

                                                              %mend;
%AHGpm(alladam);
%IF %AHGblank(&alladam) %then %findadam;
/*%else %AHGshow(&alladam);*/
/*%IF not %AHGblank(alladam) %then %AHGshow(&alladam);;*/
/*%AHGshow(alladam->&alladam);*/



%local valuelist;
%let valuelist=;
%AHGdsnInLib(lib=specs,list=valuelist,mask='%%Meta_adam_values%%');

%AHGfuncloop(%nrbquote( ONETERM(thedsn,&var) ) ,loopvar=thedsn,loops=&valuelist);
/*%AHGshow(allget->&allget);*/

 




%macro ANYWHERE(dsn,var);
%local outdsn;
%let outdsn=%scan(&dsn,-1,.);
%let allget=&allget &outdsn;

%AHGcatch(&dsn,"&VAR",out=&outdsn,open=0,strict=0);
 
%mend;

%AHGfuncloop(%nrbquote(oneterm(thedsn,&var) ) ,loopvar=thedsn,loops=&alladam);


%AHGsetprint(&allget,out=mysetprint,print=0,prefix=thevar);
/*%AHGexportopen(mysetprint,n=999);*/
/*%AHGopendsn(mysetprint);?*/

        %LET HTML=%AHGtempdir\&var._metaspec.html;

        ods html file="&HTML";  

/*        %AHGreportby(&tran,0);*/

        %AHGreportby(mysetprint,0,which=,whichlength=,sort=0,groupby=0,groupto=0,topline=,showby=0,option=nowd,labelopt=%str(option label;));
        ods html close;   

        %AHGopenfile(%AHGtempdir\&var._metaspec.html,copy=0);

                                                                  %macro nouse;
                                                                  %AHGrenamekeep(setprint,out=outdsn,pos=,names=,prefix=var);


                                                                  %AHGvarlist(&outdsn,Into=varlist,dlm=%str( ),global=0);



                                                                  proc transpose data=&outdsn out=&tran;
                                                                    var &varlist;
                                                                  run;

                                                                  data &tran;
                                                                    set &tran;
                                                                    format value $80.;
                                                                    keep _name_ value;
                                                                    col1=left(col1);
                                                                    begin=1;
                                                                    if length(trim(col1))<=50 then 
                                                                      do;
                                                                      value=col1;
                                                                      output;
                                                                      end;
                                                                    else 
                                                                      do end=1 to  length(col1) ;
                                                                      if (end-begin+1>=50 and substr(col1,end,1)=' ') or length(col1)=end then
                                                                        do;
                                                                        if begin ~= 1 then _name_='';
                                                                        value=substr(col1,begin,end-begin+1);
                                                                        output;
                                                                        begin=end+1;
                                                                        end;
                                                                      end;
                                                                  run;

                                                                  %LET HTML=%AHGtempdir\&var._metaspec.html;

                                                                  ods html file="&HTML";  

                                                          /*        %AHGreportby(&tran,0);*/

                                                                  %AHGreportby(mysetprint,0,which=,whichlength=,sort=0,groupby=0,groupto=0,topline=,showby=0,option=nowd,labelopt=%str(option label;));
                                                                  ods html close;   
                                                                  %mend;
 
%mend;

%AHGtime(1);
%AHGclearlog;
%AHGkill;
option MPRINT NOSOURCE NOSOURCE2;

%metaspec(adsl,age


);
option MPRINT NOSOURCE NOSOURCE2;

%AHGtime(2);
%AHGinterval(1,2);


