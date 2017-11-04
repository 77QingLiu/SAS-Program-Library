%macro DROPMISS( DSNIN= /* name of input SAS dataset*/
               , DSNOUT= /* name of output SAS dataset*/
               , NODROP= /* [optional] variables to be omitted from dropping even if they have only missing values */
 ) ;
%if &NODROP ne %then %let NODROP = %sysfunc(upcase(%sysfunc(prxchange(s/(^)?(\w+)(\b)/"$2"/o,-1,&NODROP))));

proc sql noprint ;
    select cat('n(',strip(name),') as ',name)     into : list separated by ','
        from dictionary.columns
        where libname='WORK' and memname="%upcase(&DSNIN)";
    create table temp as 
    select &list from &DSNIN;
quit;

data _null_;
    set temp;
    length drop $ 4000; 
    array _x_{*} _numeric_;
    do i=1 to dim(_x_);
        if _x_{i}=0 
        %if &NODROP ne %then and upcase(vname(_x_{i})) not in (&NODROP) ;
        then drop=catx(' ',drop,vname(_x_{i}));
    end;
    call symputx('drop',drop);
run;
data &DSNOUT;
    set &DSNIN(drop= &drop);
run;

proc datasets lib=work memtype=data nolist;
    delete temp;
run;
quit;
%mend DROPMISS ; 