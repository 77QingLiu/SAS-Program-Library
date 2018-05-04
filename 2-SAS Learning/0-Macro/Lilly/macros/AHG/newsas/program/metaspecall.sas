%macro metaspecall(DSN);


%LOCAL table tran varlist   dsnlist HTML kword;
%AHGgettempname(table);
%AHGgettempname(tran);

data &table;
  set specs.Meta_adam_tables:;
  WHERE dataset=upcase("&dsn");
run;

%let kword=&dsn;
%if %index(&dsn,.)=0 %then %let dsn=specs.meta_&dsn;





%AHGtran(&table,out=table&tran);

%AHGtran(&dsn,out=&tran);


data &tran;
  set table&tran &tran;
run;
/*%AHGfuncloop(%nrbquote( dosomething(thedsn,&var) ) ,loopvar=thedsn,loops=&dsnlist);*/

%LET HTML=%AHGtempdir\&dsn._metaspec&%AHGrdm.html;

ods html file="&HTML";  

%AHGreportby(&tran,0);

ods html close;   

 
%mend;
%AHGkill;
%AHGclearlog;
%metaspecall(adAE);
