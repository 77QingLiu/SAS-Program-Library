%macro metaspec(DSN,var);
%LOCAL outdsn tran varlist define HTML;
%if %index(&dsn,.)=0 %then %let dsn=specs.&dsn;
%AHGgettempname(outdsn);
%AHGgettempname(tran);
%AHGgettempname(define);
%AHGcatch(&DSN,"&VAR",out=&outdsn);

%AHGcatch(specs.Meta_define_terminology,"&VAR",out=&define);
%AHGopendsn();

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

%AHGreportby(&tran,0);

ods html close;   

 
%mend;



