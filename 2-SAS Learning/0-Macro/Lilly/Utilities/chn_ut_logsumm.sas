/*soh**************************************************************************************************************************************************
Eli Lilly and Company -   Global Statistical Sciences
CODE NAME              : chn_ut_logsumm.sas
PROJECT NAME           : 
DESCRIPTION            : Summary of Logs
SPECIFICATIONS         : 
VALIDATION TYPE        : Peer Review
INDEPENDENT REPLICATION: N/A
ORIGINAL CODE          : N/A
COMPONENT CODE MODULES            : 
SOFTWARE/VERSION#      : SAS/Version 9.2
INFRASTRUCTURE                    : Windows XP \ SDD
DATA INPUT                        : 
OUTPUT                            : \system_files\&outrpt.&sysdate9..rtf
SPECIAL INSTRUCTIONS              :
PARAMETERS:

Name      Type         Default                   Description and Valid Values
--------- ------------ ------------------------- --------------------------------------
filedir   not required default folder (&sysfile) input logs folder
filelist  not required all logs                  log files
outrpt    not required missing                   RTF report name
rptdetail not required N(no details)             Create detailed RTF report
pgmer     not required missing                   developer subset
pgmdate   not required missing                   date subset gt|ge|eq|lt|le YYYYMMDD
debug     not required N(No debug)               Debug the program

USAGE NOTES:
   Users may call the chn_ut_logsumm macro to get the summary of study logs.
   Restricts:
   1. This macro works with macro a_out2rtf.sas to generate the report.
   2. At least one lst file in the default or target folder, otherwise put error.
   3. Can't specify the physical folder for filedir under SDD.
   4. Only lst/rtf file name is needed, no extension name in parameter filelist and outrpt.
   5. The lst file name should follow the sas variable naming rule, only numeric, alphabetic and underscore characters are acceptable.
   6. For parameter pgmdate, the input format should be one of gt|ge|eq|lt|le and plus YYYYMMDD
   

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

/No folder or library specified, check all logs by default folder
%chn_ut_logsumm;

/Library specified, check all logs
libname lib "D:\lillysdd\lillyce\qa\ly2439821\I1F_JE_RHAT\intrm2\programs_stat\system_files";
%chn_ut_logsumm(filedir=lib);

/Folder specified, check all logs
%let fdir = D:\lillysdd\lillyce\qa\ly2439821\I1F_JE_RHAT\intrm2\programs_stat\system_files;
%chn_ut_logsumm(filedir=&fdir);

/Folder specified, check three specified logs
%chn_ut_logsumm(filedir=&fdir,filelist=ltdis11|ltimm21|ltaes12);

/Library specified, check single log
%chn_ut_logsumm(filedir=lib,filelist=smimm25);

/No folder or library specified, check all logs with wildcards 'gr' by default folder
%chn_ut_logsumm(filelist=gr);

/No folder or library specified, check all logs by default folder, export the report without details information
%chn_ut_logsumm(outrpt=log_summ);

/No folder or library specified, check all logs by default folder, export the report with details information
%chn_ut_logsumm(outrpt=log_summ,rptdetail=Y);

/No folder or library specified, check all logs with wildcards 'gr' by default folder, export the report with details information
%chn_ut_logsumm(filelist=gr,outrpt=log_summ,rptdetail=Y);

/No folder or library specified, check all logs with wildcards 'fqaes' by default folder, export the report with details information, no findings
%chn_ut_logsumm(filelist=fqaes,outrpt=log_summ,rptdetail=Y);

/Developer specified
%chn_ut_logsumm(pgmer=C154618);

/Date Cut point specified
%chn_ut_logsumm(pgmdate=gt20140912);
 
-------------------------------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------------------------------------------------------
DOCUMENTATION AND REVISION HISTORY SECTION (required):

       Author &
Ver# Validator        Code History Description
---- ----------------     -----------------------------------------------------------------------------------------------------
1.0   Xiaofeng Shi       Original version of the code
       
**eoh*************************************************************************************************************************************************/

%macro chn_ut_logsumm(filedir=sysfile,filelist=,outrpt=,rptdetail=N,pgmer=,pgmdate=,debug=N);

** Clear out log, output;
DM 'out; clear;'; 
DM 'log; clear;'; 
run;

%put;
%put -----------------------------------------------------------------------------;
%put --- Start of %upcase(&sysmacroname) macro, Version 22JAN2015 ;
%put ---                                                                                          	 ;
%put --- Macro parameter values                                                   		 ;
%put ---     filedir         		= &filedir                                             		 ;
%put ---     filelist         		= &filelist                                            		 ;
%put ---     outrpt         		= &outrpt                                             		 ;
%put ---     rptdetail         		= &rptdetail                                          		 ;
%put ---     pgmer         		    = &pgmer                                             		 ;
%put ---     pgmdate         		= &pgmdate          
%put ---     debug         		    = &debug     ;
%put -----------------------------------------------------------------------------;
%put;

%local filedir filelist outrpt rptdetail pgmer pgmdate parse_filedir pgm_nm debug;

%let pgm_nm = %sysget(sas_execfilename);

%if %length(&pgmdate) gt 0 %then %do;
   %let pgmdate_opr = %substr(&pgmdate,1,2);
   %let pgmdate_opr2 = opr&pgmdate_opr;
   %if &pgmdate_opr2 eq oprgt or &pgmdate_opr2 eq oprge or &pgmdate_opr2 eq opreq or &pgmdate_opr2 eq oprlt or &pgmdate_opr2 eq oprle %then %do;
      %let opr_chk = 1;
   %end;
   %else %do;
      %let opr_chk = 0;
   %end;      
   %let pgmdate_dt = %substr(&pgmdate,3);
   %let digit_chk = %sysfunc(notdigit(&pgmdate_dt));
  
   %if &opr_chk ne 1 or %length(&pgmdate_dt) ne 8 or &digit_chk ne 0 %then %do;
      %put ERROR:  The date input format is not correct.  Log summary not performed.;
      %goto exit;
   %end;
%end;

%if &filedir eq sysfile %then %do;
   %let parse_filedir = %sysfunc(pathname(sysfile));
%end;

%else %if &filedir ne sysfile and %index(&filedir,&sep) eq 0 %then %do;
   %let parse_filedir = %sysfunc(pathname(&filedir));
%end;

%else %do;
   %let parse_filedir = &filedir;
%end;


%if %length(&filelist) eq 0 %then %do;

   %if %upcase(%nrbquote(&sysscp)) = WIN %then %do;
   filename indata pipe "dir &parse_filedir.\ /b";

   data __tmp_file_list;
      length fname $50.;
      infile indata truncover; /* infile statement for file names */
      input fname $50.; /* read the file names from the directory */
      if index(upcase(fname),".LST");
   run;
   %end;

   %else %do;
   filename _dir_ "%bquote(&parse_filedir.)";
   data __tmp_file_list(keep=fname where=(index(upcase(fname),".LST")));
      length fname $50.;
      handle=dopen( '_dir_' );
      if handle > 0 then do;
         count=dnum(handle);
         do i=1 to count;
            fname=dread(handle,i);
            output __tmp_file_list;
         end;
      end;
      rc=dclose(handle);
      if index(upcase(fname),".LST");
   run;

   filename _dir_ clear;
   %end;

   proc sql noprint;
      select count(distinct fname), fname into :fnum, :fname separated by ' '
      from __tmp_file_list;
   quit;

   %if &fnum eq 0 %then %do;
      proc datasets library=work;
         delete __tmpdt_: __tmp:;
      run;
      quit;

      %put ERROR:  No lst file is found.  Log summary not performed.;
      %goto exit;
   %end;
      
   %do j=1 %to &fnum;
      %let fnami=%scan(%scan(&fname,&j," "),1,".");
      
      filename onef "&parse_filedir.&sep.&fnami..lst";
		
      data __tmp00;
         infile onef truncover pad ;
         input intext $200.;
         if index(intext,"SAS LOG FILE SCANNED") gt 0 then do;
            __a + 1;
			__b = 0;
         end;
         if index(intext,("_ERRO"||"R_=1")) gt 0 then do;
            __b + 1;
         end;		 
         if __a ne 0;         
      run;

      data __tmp000;
         set __tmp00;
         if index(upcase(compress(intext)),"USER:") gt 0 or index(upcase(compress(intext)),"DATE(OFSCAN):") gt 0
            or index(upcase(compress(intext)),"TIME(OFSCAN):") gt 0 or index(upcase(compress(intext)),"OPERATINGSYSTEM(OFSCAN):") gt 0
            or index(upcase(compress(intext)),"SASVERSION(OFSCAN):") gt 0 or __b eq 1; 
         if missing(intext) then delete;
         if index(intext,("_ERRO"||"R_=1")) gt 0 then delete;
         if index(intext,"----------") gt 0 then delete;         
      run;

      proc sql noprint;         
         select * from __tmp000;
      quit;

      proc sql noprint;
         select count(distinct intext) into :intnum separated by ','         
         from __tmp000
         where __b eq 0;
      quit;

      %if &sqlobs eq 0 or &intnum ne 5 %then %do;
         data __tmpdt_&fnami;
            length pgm pgm_d status $50  col1-col5 intext $200;
	        pgm = "&fnami..sas"; pgm_d = "&fnami..sas"; status = "Can't be classified, need to check!"; col1_d = "Unclear"; col1 = "Unclear"; col2 = " "; col3 = " "; col4 = " "; col5 = " "; intext = "Log is questionable or Multiple Scans in Log."; __c = 1; output;
         run;
      %end;

	  %else %do;

      data __tmp0;
         set __tmp000;
         length pgm $50;
         pgm = "&fnami..sas";
         __c + 1;
      run;

      proc transpose data = __tmp0(where=(__c lt 6)) prefix = col out = __tmp1;
         by __a pgm;
         id __c;
         var intext;
      run;

      proc sql noprint;
         create table __tmp0_nofind as
         select * from __tmp0 where intext eq "N o    s e a r c h e d    m e s s a g e s    f o u n d  !";
      quit;
	  
      %if &sqlobs gt 0 %then %do;
      data __tmp2;
         merge __tmp1 __tmp0_nofind;
         by __a;
      run;
	  %end;

	  %else %do;
      data __tmp2;
         merge __tmp1 __tmp0(where=(__c ge 6));
         by __a;
      run;
	  %end;

      data __tmpdt_&fnami;
         set __tmp2;
         by __a;
         length status $50.;
         array char_val{5} $ col1-col5; 
         do i = 1 to 5; 
            char_val{i} = compbl(char_val{i});
         end;
         pgm_d = pgm;
         col1_d = col1;
         col2_d = col2;
         if not first.__a then do;
            col1 = ""; col2 = ""; col3 = ""; col4 = ""; col5 = ""; pgm = "";
         end;
         if index(intext,"N o    s e a r c h e d    m e s s a g e s    f o u n d  !") gt 0 and __c ge 6 then do;
            status = "OK.";
         end;
         else do;
            status = "Need to check!!";
         end;
         drop __a __b _NAME_ i;
      run;

      %end;
   %end;
%end;

%else %if %length(&filelist) ne 0 and %index(&filelist,|) gt 0 %then %do;

   %if %upcase(%nrbquote(&sysscp)) = WIN %then %do;
   filename indata pipe "dir &parse_filedir.\ /b";

   data __tmp_file_list;
      length fname $50.;
      infile indata truncover; /* infile statement for file names */
      input fname $50.; /* read the file names from the directory */
      if index(upcase(fname),".LST");
   run;
   %end;

   %else %do;
   filename _dir_ "%bquote(&parse_filedir.)";
   data __tmp_file_list(keep=fname where=(index(upcase(fname),".LST")));
      length fname $50.;
      handle=dopen( '_dir_' );
      if handle > 0 then do;
         count=dnum(handle);
         do i=1 to count;
            fname=dread(handle,i);
            output __tmp_file_list;
         end;
      end;
      rc=dclose(handle);
      if index(upcase(fname),".LST");
   run;

   filename _dir_ clear;
   %end;

   %let k = 1;
   %let fnami = %lowcase(%scan(&filelist,&k,"|"));
   %do %while("&fnami" NE "");
      proc sql noprint;
         select * from __tmp_file_list where lowcase(scan(fname,1,".")) = "&fnami";
      quit;

      %if &sqlobs eq 0 %then %do;
         %put ERROR:  &fnami..lst file is not found.  Log summary not performed.;
         %goto tmpexit;
      %end;

      filename onef "&parse_filedir.&sep.&fnami..lst";

      data __tmp00;
         infile onef truncover pad ;
         input intext $200.;
         if index(intext,"SAS LOG FILE SCANNED") gt 0 then do;
            __a + 1;
			__b = 0;
         end;
         if index(intext,("_ERRO"||"R_=1")) gt 0 then do;
            __b + 1;
         end;		 
         if __a ne 0;         
      run;

      data __tmp000;
         set __tmp00;
         if index(upcase(compress(intext)),"USER:") gt 0 or index(upcase(compress(intext)),"DATE(OFSCAN):") gt 0
            or index(upcase(compress(intext)),"TIME(OFSCAN):") gt 0 or index(upcase(compress(intext)),"OPERATINGSYSTEM(OFSCAN):") gt 0
            or index(upcase(compress(intext)),"SASVERSION(OFSCAN):") gt 0 or __b eq 1; 
         if missing(intext) then delete;
         if index(intext,("_ERRO"||"R_=1")) gt 0 then delete;
         if index(intext,"----------") gt 0 then delete;         
      run;

      proc sql noprint;         
         select * from __tmp000;
      quit;

      proc sql noprint;
         select count(distinct intext) into :intnum separated by ','         
         from __tmp000
         where __b eq 0;
      quit;

      %if &sqlobs eq 0 or &intnum ne 5 %then %do;
         data __tmpdt_&fnami;
            length pgm pgm_d status $50  col1-col5 intext $200;
	        pgm = "&fnami..sas"; pgm_d = "&fnami..sas"; status = "Can't be classified, need to check!"; col1_d = "Unclear"; col1 = "Unclear"; col2 = " "; col3 = " "; col4 = " "; col5 = " "; intext = "Log is questionable or Multiple Scans in Log."; __c = 1; output;
         run;
      %end;

	  %else %do;

      data __tmp0;
         set __tmp000;
         length pgm $50;
         pgm = "&fnami..sas";
         __c + 1;
      run;

      proc transpose data = __tmp0(where=(__c lt 6)) prefix = col out = __tmp1;
         by __a pgm;
         id __c;
         var intext;
      run;

      proc sql noprint;
         create table __tmp0_nofind as
         select * from __tmp0 where intext eq "N o    s e a r c h e d    m e s s a g e s    f o u n d  !";
      quit;
	  
      %if &sqlobs gt 0 %then %do;
      data __tmp2;
         merge __tmp1 __tmp0_nofind;
         by __a;
      run;
	  %end;

	  %else %do;
      data __tmp2;
         merge __tmp1 __tmp0(where=(__c ge 6));
         by __a;
      run;
	  %end;

      data __tmpdt_&fnami;
         set __tmp2;
         by __a;
         length status $50.;
         array char_val{5} $ col1-col5; 
         do i = 1 to 5; 
            char_val{i} = compbl(char_val{i});
         end;
         pgm_d = pgm;
         col1_d = col1;
         col2_d = col2;
         if not first.__a then do;
            col1 = ""; col2 = ""; col3 = ""; col4 = ""; col5 = ""; pgm = "";
         end;
         if index(intext,"N o    s e a r c h e d    m e s s a g e s    f o u n d  !") gt 0 and __c ge 6 then do;
            status = "OK.";
         end;
         else do;
            status = "Need to check!!";
         end;
         drop __a __b _NAME_ i;
      run;

      %tmpexit:
      %let k = %eval(&k+1);
      %let fnami = %scan(%scan(&filelist,&k,"|"),1,".");
	  %end;
   %end;
%end;

%else %if %length(&filelist) ne 0 and %index(&filelist,|) eq 0 %then %do;

   %if %upcase(%nrbquote(&sysscp)) = WIN %then %do;
   filename indata pipe "dir &parse_filedir.\ /b";

   data __tmp_file_list;
      length fname $50.;
      infile indata truncover; /* infile statement for file names */
      input fname $50.; /* read the file names from the directory */
      if index(upcase(fname),".LST");
   run;
   %end;

   %else %do;
   filename _dir_ "%bquote(&parse_filedir.)";
   data __tmp_file_list(keep=fname where=(index(upcase(fname),".LST")));
      length fname $50.;
      handle=dopen( '_dir_' );
      if handle > 0 then do;
         count=dnum(handle);
         do i=1 to count;
            fname=dread(handle,i);
            output __tmp_file_list;
         end;
      end;
      rc=dclose(handle);
      if index(upcase(fname),".LST");
   run;

   filename _dir_ clear;
   %end;

   proc sql noprint;
      select count(distinct fname), fname into :fnum, :fname separated by ' '
      from __tmp_file_list where lowcase(fname) contains "%lowcase(&filelist)";
   quit;

   %if &fnum eq 0 %then %do;
      proc datasets library=work;
         delete __tmpdt_: __tmp:;
      run;
      quit;

      %put ERROR:  The lst file with key word &filelist is found.  Log summary not performed.;
      %goto exit;
   %end;


   %do j=1 %to &fnum;
      %let fnami=%scan(%scan(&fname,&j," "),1,".");
      
      filename onef "&parse_filedir.&sep.&fnami..lst";
		
      data __tmp00;
         infile onef truncover pad ;
         input intext $200.;
         if index(intext,"SAS LOG FILE SCANNED") gt 0 then do;
            __a + 1;
			__b = 0;
         end;
         if index(intext,("_ERRO"||"R_=1")) gt 0 then do;
            __b + 1;
         end;		 
         if __a ne 0;         
      run;

      data __tmp000;
         set __tmp00;
         if index(upcase(compress(intext)),"USER:") gt 0 or index(upcase(compress(intext)),"DATE(OFSCAN):") gt 0
            or index(upcase(compress(intext)),"TIME(OFSCAN):") gt 0 or index(upcase(compress(intext)),"OPERATINGSYSTEM(OFSCAN):") gt 0
            or index(upcase(compress(intext)),"SASVERSION(OFSCAN):") gt 0 or __b eq 1; 
         if missing(intext) then delete;
         if index(intext,("_ERRO"||"R_=1")) gt 0 then delete;
         if index(intext,"----------") gt 0 then delete;         
      run;

      proc sql noprint;         
         select * from __tmp000;
      quit;

      proc sql noprint;
         select count(distinct intext) into :intnum separated by ','         
         from __tmp000
         where __b eq 0;
      quit;

      %if &sqlobs eq 0 or &intnum ne 5 %then %do;
         data __tmpdt_&fnami;
            length pgm pgm_d status $50  col1-col5 intext $200;
	        pgm = "&fnami..sas"; pgm_d = "&fnami..sas"; status = "Can't be classified, need to check!"; col1_d = "Unclear"; col1 = "Unclear"; col2 = " "; col3 = " "; col4 = " "; col5 = " "; intext = "Log is questionable or Multiple Scans in Log."; __c = 1; output;
         run;
      %end;

	  %else %do;

      data __tmp0;
         set __tmp000;
         length pgm $50;
         pgm = "&fnami..sas";
         __c + 1;
      run;

      proc transpose data = __tmp0(where=(__c lt 6)) prefix = col out = __tmp1;
         by __a pgm;
         id __c;
         var intext;
      run;

      proc sql noprint;
         create table __tmp0_nofind as
         select * from __tmp0 where intext eq "N o    s e a r c h e d    m e s s a g e s    f o u n d  !";
      quit;
	  
      %if &sqlobs gt 0 %then %do;
      data __tmp2;
         merge __tmp1 __tmp0_nofind;
         by __a;
      run;
	  %end;

	  %else %do;
      data __tmp2;
         merge __tmp1 __tmp0(where=(__c ge 6));
         by __a;
      run;
	  %end;

      data __tmpdt_&fnami;
         set __tmp2;
         by __a;
         length status $50.;
         array char_val{5} $ col1-col5; 
         do i = 1 to 5; 
            char_val{i} = compbl(char_val{i});
         end;
         pgm_d = pgm;
         col1_d = col1;
         col2_d = col2;
         if not first.__a then do;
            col1 = ""; col2 = ""; col3 = ""; col4 = ""; col5 = ""; pgm = "";
         end;
         if index(intext,"N o    s e a r c h e d    m e s s a g e s    f o u n d  !") gt 0 and __c ge 6 then do;
            status = "OK.";
         end;
         else do;
            status = "Need to check!!";
         end;
         drop __a __b _NAME_ i;
      run;

	  %end;
   %end;
%end;

data __tmp_overall;
   set __tmpdt_:;
   array char_col{6} $ col1 col2 col4 col5 col1_d col2_d; 
      do i = 1 to 6; 
      if ^missing(char_col{i}) then char_col{i} = trim(left(scan(char_col{i},-1,":")));
   end;
   if ^missing(col3) then col3 = trim(left(substr(col3,16)));
   %if %length(&pgmer) gt 0 %then %do;
      %let pgmer_chk = %lowcase(&pgmer);
      if lowcase(col1_d) in ("&pgmer","unclear");
   %end;
   %if %length(&pgmdate) gt 0 %then %do;
      if ^missing(col2_d) and lowcase(col1_d) ne "unclear" then _scandt=input(col2_d,date9.);
      _cutdt = mdy(input(substr("&pgmdate",7,2),best.),input(substr("&pgmdate",9,2),best.),input(substr("&pgmdate",3,4),best.));
      if ^missing(_scandt) and ^missing(_cutdt) and _scandt &pgmdate_opr _cutdt or lowcase(col1_d) eq "unclear";         
   %end;
run;

proc sql;
   create table __summ_freq as
   select distinct "Total programs checked:" as pgm_desc,count(pgm) as pgm_count from __tmp_overall where ^missing(status) and ^missing(pgm)
   union all
   select distinct "Need to check again:" as pgm_desc,count(pgm) as pgm_count from __tmp_overall where status eq "Need to check!!" and ^missing(pgm)
   union all
   select distinct "Can't be classified:" as pgm_desc,count(pgm) as pgm_count from __tmp_overall where status eq "Can't be classified, need to check!" and ^missing(pgm)
   union all
   select distinct "No findings in log:" as pgm_desc,count(pgm) as pgm_count from __tmp_overall where status eq "OK." and ^missing(pgm);

   create table __summ_count as
   select distinct pgm,col1,col2,col3,col4,col5,status from __tmp_overall where status eq "OK." and ^missing(pgm)
   union all
   select distinct pgm,col1,col2,col3,col4,col5,status from __tmp_overall where status ne "OK." and ^missing(pgm)
   order by status,col1,pgm;
quit;

proc sql;
   create table __summ_details_no as
   select pgm,col1,intext,col1_d,pgm_d,__c from __tmp_overall where status not in ("OK.")
   order by col1_d,pgm_d,__c;
quit;

%if &sqlobs eq 0 %then %do;
   data __summ_details_no;
      length pgm $50;
	  pgm = "No findings in log.";col1 = " "; intext = " "; col1_d = " "; pgm_d = " "; __c = 1; output;    
   run;   
%end;

%if %length(&outrpt) ne 0 %then %do;

%if &referenc = TDTM %then %do;
   %let dev_phase=qa; /*program and output location*/
   %let dev_phase2=qa; /*ads location*/
%end;

%else %if &referenc = PDTM %then %do;
   %let dev_phase=qa; /*program and output location*/
   %let dev_phase2=prd; /*ads location*/
%end;

%else %if &referenc = PDPM %then %do;
   %let dev_phase=prd; /*program and output location*/
   %let dev_phase2=prd; /*ads location*/
%end;

%let prp_tmpfile=&parse_filedir.&sep%lowcase(%sysfunc(compress(&outrpt.&sysdate9..rtf)));

filename rtfout "&prp_tmpfile";
ods listing;
filename tmpfile temp;
proc printto new print=tmpfile;
run;

title1 j=l "Study Logs Summary";
title2 j=l "For Snapshot &analy_phase";
title3 j=l "%upcase(&study)";

proc report data = __summ_freq nowindows split="#" headline headskip spacing = 0;
   column ("--" pgm_desc pgm_count);   
   define pgm_desc / width=33 left "Overall Summary";
   define pgm_count / width=100 left "Frequency";

   compute before _page_;
      line @1 "Study Logs Overall Summary";      
      line " ";
   endcomp;

   compute after _page_;
      line " ";      
      line @1 &ls.*"-";
      line @1 " ";
      line @1 "Program Location: &sep.&sep.&dir_root.&sep.&dev_phase.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.&pgm_dir.&sep.&pgm_nm";
      line @1 "Output Location: &sep.&sep.&dir_root.&sep.&dev_phase.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.&pgm_dir.&sep.system_files&sep.&outrpt.&sysdate9..rtf";	
      line @1 "Dataset Location: &sep.&sep.&dir_root.&sep.&dev_phase2.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.&pgm_dir.&sep.system_files";
   endcomp;
run;
quit;

proc report data = __summ_count nowindows split="#" headline headskip spacing = 0;
   column ("--" pgm col1 col2 col3 col4 col5 status);
   define pgm / width=30 left "Program Name" flow;
   define col1 / width=10 left "User";
   define col2 / width=15 left "Log Creation#Date";
   define col3 / width=15 left "Log Creation#Time";
   define col4 / width=32 left "Program Platform" flow;
   define col5 / width=10 left "SAS#Version";
   define status / width=21 left "Status" flow;

   compute before _page_;
      line @1 "Study Logs Status";
      line " ";
   endcomp;

   compute after _page_;
      line " ";      
      line @1 &ls.*"-";
      line @1 " ";
      line @1 "Program Location: &sep.&sep.&dir_root.&sep.&dev_phase.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.&pgm_dir.&sep.&pgm_nm";
      line @1 "Output Location: &sep.&sep.&dir_root.&sep.&dev_phase.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.&pgm_dir.&sep.system_files&sep.&outrpt.&sysdate9..rtf";	
      line @1 "Dataset Location: &sep.&sep.&dir_root.&sep.&dev_phase2.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.&pgm_dir.&sep.system_files";
   endcomp;
run;
quit;

%if %length(&rptdetail) gt 0 and %upcase(&rptdetail) eq Y %then %do;
proc report data = __summ_details_no nowindows split="#" headline headskip spacing = 0;
   column ("--" col1_d pgm_d __c pgm col1 intext);
   define col1_d / noprint order;
   define pgm_d / noprint order;
   define __c / noprint order;
   define pgm / width=30 left "Program Name" flow;
   define col1 / width=10 left "User";
   define intext / width=93 left "Log" flow;

   compute before _page_;
      line @1 "Study Log Details";
      line " ";
   endcomp;

   compute after pgm_d;
      line " ";      
   endcomp;

   compute after _page_;
      line " ";
      line @1 &ls.*"-";
      line @1 " ";
      line @1 "Program Location: &sep.&sep.&dir_root.&sep.&dev_phase.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.&pgm_dir.&sep.&pgm_nm";
      line @1 "Output Location: &sep.&sep.&dir_root.&sep.&dev_phase.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.&pgm_dir.&sep.system_files&sep.&outrpt.&sysdate9..rtf";	
      line @1 "Dataset Location: &sep.&sep.&dir_root.&sep.&dev_phase2.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.&pgm_dir.&sep.system_files";
   endcomp;
run;
quit;
%end;

proc printto ;
run;

%a_out2rtf(in = tmpfile, out = rtfout ,_o2r_PrpMdYN=Y ,_o2r_PrpMd=&referenc.);

filename tmpfile clear;
filename rtfout clear;

%end;

%if %length(&debug) gt 0 and %upcase(&debug) eq N %then %do;
proc datasets library=work;
   delete __tmpdt_: __tmp:;
run;
quit;
%end;

%exit:
%mend chn_ut_logsumm;


