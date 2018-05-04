%MACRO ahggenva(fullvadsn,refresh=0,iterate=0,tot=de_sum.tot,r=0/*refreshmeta*/);
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname); 
    %AHGclearusermac;
    %let fullvadsn=%upcase(&fullvadsn);
    %if not %index(&fullvadsn,.) %then %let fullvadsn=DATVPROT.&fullvadsn;
    %local vadsn valib;
    %let vadsn=%scan(&fullvadsn,2,.);
    %let valib=%scan(&fullvadsn,1,.);
    %global startime genvaIter vaDone;
    %let genvaiter=0;
    %let  vaDone=;

    data _null_;
        call symput('startime',put(datetime(),datetime16.));
    run;

 %if &standard eq pds1_0 %then %AHGreadtot(PRT.pds,clean=1);
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
  %AHGpm(drvrname);
    

  data _null_;
    file "&localtemp\globalstat.sas";
    infile "&localtemp\ENVARS.txt" dlm='^' truncover;
    length letstring $400 mac $50 value $300;
    input mac value;
    if upcase(mac) eq 'DRVRNAME' then call symput('drvrname',trim(value));
    put ';%global ' mac ';';
  run;

  %inc "&localtemp\globalstat.sas";

    data _null_;
      length envar $ 200. enval $ 800.;

      infile "&localtemp\ENVARS.txt" pad   lrecl=1000 missover delimiter='^' end=last;
      input envar $ enval $;

      if trim(left(envar)) ^= '' then do;
         call symput(envar,trim(enval));
      end;

      if last then do;
         rc = fclose(1);
      end;

    run;


    

    %macro decodemeta(str);
        &str=(tranwrd(&str,'.$(SSD01)',' '))  ;
        &str=(tranwrd(&str,'$(',''))  ;
        &str=(tranwrd(&str,')','.'))  ;
    %mend;


   
    %macro getvadep(fullvadsn,outvar);
        data vadep(keep=va drvr vadeps);
            set alltod;
            x=upcase(compress(va));
            y=upcase("&fullvadsn" );
            if x=y then 
            do;
            output;
            call symput("&outvar",compress(vadeps,byte(13)||byte(17)));
            put x=;
            put y=;
            put vadeps=;
            end;
        run;
    
    %mend;




    %macro runvadrvr(fullvadsn);
        %local drvr;
        data vadep(keep=va drvr vadeps);
            set alltod;
            x=upcase(compress(va ));
            y=upcase("&fullvadsn" );
            if x=y then output;
             if x=y then  call symput("drvr",drvr);
        run;
        %if %index(&drvr,.sasdrvr) %then
        %do;
        %if &refresh=1 or (%sysfunc(fileexist(&projectpath\program\&drvr)) ne 1) %then   %AHGrdown(rlevel=all,folder=program,filename=&drvr,save=0);
        %if  %sysfunc(fileexist(&projectpath\program\&drvr)) eq 1 %then   %include "&projectpath\program\&drvr";
        %end;
    
    %mend;



    %local systod tod;
    %if %upcase(&standard)=%upcase(WSS3_0)%THEN %let systod=SysTodTYPE2.meta;
    %if %upcase(&standard)=%upcase(PDS1_0)%THEN %let systod=SysTodCSR.meta;
    %let tod=Tod.meta;
    %if &refresh=1 %then 
        %do;
        %AHGrdown(rlevel=all,folder=tools,filename=&systod,save=0);
        %AHGrdown(rlevel=all,folder=tools,filename=&tod,save=0);
        %end;



    data systod;
                
        infile "&psysdata\tools\&systod" truncover lrecl=1000; 
        length templine $1000  line $1000 va $100 drvr $100  deps $1000 vadeps $1000;
        input line 1-1000 ;
        %decodemeta(line);
        va=scan(line,1,'^');
        drvr=scan(line,2,'^');
        deps=scan(line,3,'^');
        vadeps=scan(line,3,'^');
        do i=1 to 30;
          if upcase(scan(vadeps,i,' '))=:'DATVPROT' or upcase(scan(vadeps,i,' '))=:'TOOLPROT'  then templine=trim(templine)||' '||upcase(scan(vadeps,i,' ')); 
         end;
         vadeps=templine;
    run;

    data tod;
        infile "&projectpath\tools\&tod" truncover lrecl=1000;   
        length line $1000 va $100 drvr $100  deps $1000 vadeps $1000;
        input line 1-1000 lrecl=1000;
        %decodemeta(line);
        va=scan(line,1,'^');
        drvr=scan(line,2,'^');
        deps=scan(line,3,'^');
        vadeps=scan(line,3,'^');

        do i=1 to count(vadeps,' $(');
            if not (upcase(scan(vadeps,i,' '))=:upcase('datvprot.'))  then vadeps=tranwrd(vadeps,scan(vadeps,i,' '),' ');
        end;
    run;

    proc sort data=systod;
        by va;
    run;

    proc sort data=tod;
        by va;
    run;

    data alltod;
        merge systod tod;
        by va;
    run;
    %global finalCommand;
    %let finalCommand=;

   %macro AHGgenvacore(fullvadsn);
    %let genvaiter=%eval(&genvaiter+1);
    %if /*&genvaiter>30 * or */  %index(&fullvadsn,_META) %then %goto getout;

    %if &iterate=1 %then 
        %do;
        %local moredsn;
        %getvadep(&fullvadsn,moredsn);
        %do i=1 %to %AHGcount(&moredsn);

            %global modate;
            %let modate=;
            proc sql noprint;
                select modate into :modate
                from sashelp.vtable
                where libname=upcase("%scan(%scan(&moredsn,&i,%str( )),1,.)") and memname=upcase("%scan(%scan(&moredsn,&i,%str( )),2,.)")
                ;
            quit;
            %put %scan(&moredsn,&i,%str( )) startime=&startime  modate=&modate ;
 
            %if not %index(&vaDone,%upcase(%scan(&moredsn,&i,%str( ))) )%then 
                %do; 
/*                %put hhhhh; %AHGpm(vaDone) ; %put now %upcase(%scan(&moredsn,&i,%str( )));*/
                %let vaDone=&vaDone  %upcase(%scan(&moredsn,&i,%str( ))); 
                %AHGgenvacore(%scan(&moredsn,&i,%str( ))); 
                %end;
            
            %put VaDone=&vaDone;
        %end;
        %end;
    %put   fullvadsn=&fullvadsn moredsn=&moredsn;
    %put Iamgenerating  &fullvadsn;

    %let finalCommand=&finalCommand%str(;)   % runvadrvr(&fullvadsn) ;
    %AHGpm(finalCommand);
    %getout:
    %mend;
    %AHGgenvacore(&fullvadsn);
    %put &finalcommand;
    %sysfunc(compress(&finalcommand));


     
%mend;
