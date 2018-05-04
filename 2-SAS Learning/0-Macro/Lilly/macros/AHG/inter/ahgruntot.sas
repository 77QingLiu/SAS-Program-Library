%macro AHGruntot(tot,r=0,refreshmac=0);
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname);

    %AHGclearusermac;

    proc datasets lib=work memtype=catalog;
        delete sasmacr;
    run;

    %if &refreshmac=1 %then
    %do;
    data _null_;
      filename pip pipe "dir ""&projectpath\macros\*.sas "" /b";
      infile pip;
      length file $100 com $300;
      input file ;
      com=("%include ""&projectpath\macros\"||file||'";');
      put com=;
      call execute(com);
    run;
    %end;

    /*copy and modify from Jason Liu's code*/
    %let gmacs=g_dsin g_dsnin dsin dsnin scope subset subsetskip bylabel bytitle g_subset_keyvars
    g_subset g_subset_c g_subset_va g_subset_disp g_subset_codes extravar g_extravar g_extravar_c g_extravar_disp
    g_extravar_codes pageby g_pageby g_pageby_c g_pageby_disp g_pageby_codes selstmt ;
    %do i=1 %to %AHGcount(&gmacs);
        %let %scan(&gmacs,&i) = ;
    %end;
    /*************/

    %if not %index(&tot,.tot) %then
    %DO;
    %AHGrpipe(%str( totfile=$(tabnum2tot &tot &root3/tools) ;basename $totfile  ),rcrpipe)  ;
    %let tot=%trim(&rcrpipe);
    %END;

  option noxwait;
  %let repbase=%sysfunc(tranwrd(&tot,.tot,%str()));
  %if &standard eq pds1_0 %then %AHGreadtot(PRT.pds);
  x "copy &localtemp\temp.txt &localtemp\tempPRT.txt";

  %AHGreadtot(PRT.pds);

  %if &r=1 or (%sysfunc(fileexist(&projectpath\tools\project.meta)) ne 1) %then  %AHGrdown(save=0,rlevel=all,folder=tools,filename=project.meta);;
  %AHGreadtot(project.meta );
  x "copy &localtemp\temp.txt &localtemp\tempproj.txt";

  %if &r=1 or (%sysfunc(fileexist(&projectpath\tools\submission.meta)) ne 1) %then  %AHGrdown(save=0,rlevel=all,folder=tools,filename=submission.meta);;
  %AHGreadtot(submission.meta );
  x "copy &localtemp\temp.txt &localtemp\tempsub.txt";

  %if &r=1 or (%sysfunc(fileexist(&projectpath\tools\protocol.meta)) ne 1) %then  %AHGrdown(save=0,rlevel=all,folder=tools,filename=protocol.meta);;
  %AHGreadtot(protocol.meta );
  x "copy &localtemp\temp.txt &localtemp\tempprot.txt";

  %if &r=1 or (%sysfunc(fileexist(&projectpath\tools\&tot)) ne 1) %then  %AHGrdown(save=0,rlevel=3,folder=tools,filename=&tot);;
  %AHGreadtot(&tot );
  x "copy &localtemp\temp.txt &localtemp\temptot.txt";

  %if &r=1 or (%sysfunc(fileexist(&projectpath\tools\lab.meta)) ne 1) %then  %AHGrdown(save=0,rlevel=all,folder=tools,filename=lab.meta);;
  %AHGreadtot(lab.meta);
  x "copy &localtemp\temp.txt &localtemp\templab.txt";


  x "copy &localtemp\tempPRT.txt + &localtemp\tempproj.txt + &localtemp\tempsub.txt + &localtemp\tempprot.txt + &localtemp\temptot.txt +&localtemp\templab.txt &localtemp\ENVARS.txt";
  %global drvrname;

  data _null_;
    file "&localtemp\globalstat.sas";
    infile "&localtemp\ENVARS.txt" dlm='^' truncover;
    length letstring $400 mac $50 value $300;
    input mac value;
    if upcase(mac) eq 'DRVRNAME' then call symput('drvrname',trim(value));
    put ';%global ' mac ';';
  run;

  %inc "&localtemp\globalstat.sas";
  
  %global ssd;
  %let ssd=datvprot.&repbase;
  %local getmed;
  %PUT iAMFINE;
  %if %sysfunc(fileexist(&projectpath\program\&DRVRNAME)) ne 1 %then  %AHGrdown(save=0,rlevel=all,folder=program,filename=&DRVRNAME);;
  %let outfile=&projectpath\table\&repbase.pc.rpt;
  %include "&projectpath\program\&DRVRNAME";
  %put &projectpath\program\&DRVRNAME;
  %AHGsetauto;
  x "&outfile";

%AHGclearusermac;
option nosymbolgen;



%mend;
