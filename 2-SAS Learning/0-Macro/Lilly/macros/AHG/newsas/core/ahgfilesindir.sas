%macro AHGfilesindir(dir,dlm=@,fullname=0,extension=,mask=,include=,except=,into=q,case=0,print=0);    
  %local DirID memcnt fileref rc i ahg0 name mydir;
  %let fileref=%substr(X%AHGrandom,1,8);
  %let rc=%sysfunc(filename(fileref,&dir)); 
  %let DirID=%sysfunc(dopen(&fileref));                                                                                                      
                                                                                                                                        
  /* Returns the number of members in the directory */                                                                   
  %let memcnt=%sysfunc(dnum(&DIRid)); 
  %local filedsn;
  %AHGgettempname(filedsn);
  data &filedsn;
  format file $200.;
  %do i = 1 %to &memcnt;                                                                                                                
     file="%qsysfunc(dread(&DIRid,&i))";
     output;
  %end;
  run;
  proc sql noprint;
    select  %if &fullname %then "&dir%AHGdelimit"||;file into :&into   separated by "&dlm"
  from &filedsn
  where 1=1 
  %if %AHGnonblank(&mask) %then 
  %if &case=0 %then %str(and upcase(file) like upcase(&mask));
  %else and file like &mask ;


  %local oneept;
  %if %AHGnonblank(&include) %then 
  %do;
    and ( 1
    %do ahg0=1 %to %AHGcount(&include); 
    %let oneEpt=%scan(&include,&ahg0,%str( ));
    %if &case=0 %then %str(or (index(upcase(file),upcase("&oneEpt")))        );
    %else or (index( file ,"&oneEpt")  );
    %end;
    )
  %end;

  %if %AHGnonblank(&except) %then 
  %do ahg0=1 %to %AHGcount(&except); 
  %let oneEpt=%scan(&except,&ahg0,%str( ));
  %if &case=0 %then %str(and not (index(upcase(file),upcase("&oneEpt")))        );
  %else and not (index( file ,"&oneEpt")  );
  %end;
  order by file
  ;
  quit;
  %let rc=%sysfunc(dclose(&DIRid)); 
  %let rc=%sysfunc(filename(filrf));
  %if &print %then %AHGpm(&into);
%mend;
  




