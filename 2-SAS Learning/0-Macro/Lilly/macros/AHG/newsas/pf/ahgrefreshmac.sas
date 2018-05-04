%macro AHGrefreshmac(refreshnet=0,lib=,proj=0,files=);
		%AHGdefault(theuser,LIUH04);
		%AHGdefault(kanbox,c:\kanbox\baiduyun);
		%AHGclearmac;
    %if %upcase(&theuser)=LIUH04 %then 
    %if &proj=1 %then
      %do;
          data _null_;
            filename pip pipe "dir ""&projectpath\macros\*.sas "" /b";
            infile pip;
            length file $100 com $300;
            input file ;
            if index(file,'refreshmac.sas') then return;
            if ("&files" ne '') and (not index(upcase("&files"),trim(upcase(file)))) then return;
            com=("%include ""&projectpath\macros\"||file||'";');
            put com=;
            call execute(com);
          run; 
      %end;
    %else 
    %do;
    data _null_;
      filename pip pipe "dir ""&kanbox\allover\*.sas "" /b";
      infile pip;
      length file $100 com $300;
      input file ;
      if index(file,'refreshmac.sas') then return;
      if ("&files" ne '') and (not index(upcase("&files"),trim(upcase(file)))) then return;
      com=("%include ""&kanbox\allover\"||file||'";');
      put com=;
      call execute(com);
    run;
    
    data _null_;
      filename pip pipe "dir ""&kanbox\alloverhome\*.sas "" /b";
      infile pip;
      length file $100 com $300;
      input file ;
      if index(file,'refreshmac.sas') then return;
      if ("&files" ne '') and (not index(upcase("&files"),trim(upcase(file)))) then return;
      com=("%include ""&kanbox\alloverhome\"||file||'";');
      put com=;
      call execute(com);
    run;    
    
    data _null_;
      filename pip pipe "dir ""&kanbox\my sas files\macros\*.sas "" /b";
      infile pip;
      length file $100 com $300;
      input file ;
      if index(file,'refreshmac.sas') then return;
      if ("&files" ne '') and (not index(upcase("&files"),trim(upcase(file)))) then return;
      com=("%include ""&kanbox\my sas files\macros\"||file||'";');
      put com=;
      call execute(com);
    run;
    
    data _null_;
      filename pip pipe "dir ""&kanbox\homesas\*.sas "" /b";
      infile pip;
      length file $100 com $300;
      input file ;
      if index(file,'refreshmac.sas') then return;
      if ("&files" ne '') and (not index(upcase("&files"),trim(upcase(file)))) then return;
      com=("%include ""&kanbox\homesas\"||file||'";');
      put com=;
      call execute(com);
    run;    

 
    %local macbackup;
    %let macbackup=&preadandwrite\automac\AHG_sas9mac;
    
    libname netmac "&macbackup";
    %local mydt;
    %AHGdateandtime(mydt);
    %AHGpm(mydt);
    
    %if &refreshnet=1 %then
        %do;
        x mkdir &macbackup&mydt;   
        x copy  &macbackup\*.* &macbackup&mydt\;    
        proc datasets lib=work;
          copy out=netmac memtype=catalog;
        run;
        quit;
        %end;

    %end;
%mend;


