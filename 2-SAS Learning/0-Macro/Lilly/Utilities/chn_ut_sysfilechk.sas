/*soh**************************************************************************************************************************************************
Eli Lilly and Company -   Global Statistical Sciences
CODE NAME              : chn_ut_sysfilechk.sas
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
filedir   not required default folder (&sysfile) input pgms folder
outrpt    not required missing                   RTF report name
rptdetail not required N(no details)             Create detailed RTF report

USAGE NOTES:
   Users may call the chn_ut_sysfilechk macro to get the overall check of programming system files.
   Restricts:
   1. This macro works with macro a_out2rtf.sas to generate the report.
   2. At least one program file or one system file in the default or target folder, otherwise put error.
   3. Can't specify the physical folder for filedir under SDD.
   4. Only rtf file name is needed, no extension name in parameter outrpt.
   5. The lst file name should follow the sas variable naming rule, only numeric, alphabetic and underscore characters are acceptable.   

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

/No folder or library specified, check all files by default folder
%chn_ut_sysfilechk;

/Library specified, check all logs
libname lib "D:\lillysdd\lillyce\qa\ly2439821\I1F_JE_RHAT\intrm2\programs_stat";
%chn_ut_sysfilechk(filedir=lib);

/Folder specified, check all logs
%let fdir = D:\lillysdd\lillyce\qa\ly2439821\I1F_JE_RHAT\intrm2\programs_stat;
%chn_ut_sysfilechk(filedir=&fdir);

/No folder or library specified, check all logs by default folder, export the report without details information
%chn_ut_sysfilechk(outrpt=sys_summ);

/No folder or library specified, check all logs by default folder, export the report with details information
%chn_ut_sysfilechk(outrpt=sys_summ,rptdetail=Y);

-------------------------------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------------------------------------------------------
DOCUMENTATION AND REVISION HISTORY SECTION (required):

       Author &
Ver# Validator        Code History Description
---- ----------------     -----------------------------------------------------------------------------------------------------
1.0   Xiaofeng Shi       Original version of the code
       
**eoh*************************************************************************************************************************************************/

%macro chn_ut_sysfilechk(filedir=pgmfile,outrpt=,rptdetail=N);

** Clear out log, output;
DM 'out; clear;'; 
DM 'log; clear;'; 
run;

%put;
%put -----------------------------------------------------------------------------;
%put --- Start of %upcase(&sysmacroname) macro, Version 11FEB2015 ;
%put ---                                                                                          	 ;
%put --- Macro parameter values                                                   		 ;
%put ---     filedir         		= &filedir                                             		 ;
%put ---     outrpt         		= &outrpt                                            		 ;
%put ---     rptdetail         		= &rptdetail                                             		 ;
%put -----------------------------------------------------------------------------;
%put;

%local filedir outrpt rptdetail parse_filedir pgm_nm;

%let pgm_nm = %sysget(sas_execfilename);

%if &filedir eq pgmfile %then %do;
   %let parse_filedir = %sysfunc(pathname(pgmfile));
   %let parse_sysfiledir = %sysfunc(pathname(pgmfile))&sep.system_files;
%end;

%else %if &filedir ne pgmfile and %index(&filedir,&sep) eq 0 %then %do;
   %let parse_filedir = %sysfunc(pathname(&filedir));
   %let parse_sysfiledir = %sysfunc(pathname(pgmfile))&sep.system_files;
%end;

%else %do;
   %let parse_filedir = &filedir;
   %let parse_sysfiledir = &filedir.&sep.system_files;
%end;


   %if %upcase(%nrbquote(&sysscp)) = WIN %then %do;
   filename indata pipe "dir &parse_filedir.\ /b";

   data __tmp_file_list_sas;
      length fname $50.;
      infile indata truncover; /* infile statement for file names */
      input fname $50.; /* read the file names from the directory */
      if index(upcase(fname),".SAS");
   run;

   filename insys pipe "dir &parse_sysfiledir.\ /b";

   data __tmp_file_list_sys;
      length fname $50.;
      infile insys truncover; /* infile statement for file names */
      input fname $50.; /* read the file names from the directory */
      if index(upcase(fname),".LST") or index(upcase(fname),".LOG");
   run;
   %end;

   %else %do;
   filename _dir_ "%bquote(&parse_filedir.)";
   data __tmp_file_list_sas(keep=fname where=(index(upcase(fname),".SAS")));
      length fname $50.;
      handle=dopen( '_dir_' );
      if handle > 0 then do;
         count=dnum(handle);
         do i=1 to count;
            fname=dread(handle,i);
            output __tmp_file_list_sas;
         end;
      end;
      rc=dclose(handle);
      if index(upcase(fname),".SAS");
   run;

   filename _dirsys_ "%bquote(&parse_sysfiledir.)";
   data __tmp_file_list_sys(keep=fname where=(index(upcase(fname),".LST") or index(upcase(fname),".LOG") or index(upcase(fname),".SAS7BDAT")));
      length fname $50.;
      handle=dopen( '_dirsys_' );
      if handle > 0 then do;
         count=dnum(handle);
         do i=1 to count;
            fname=dread(handle,i);
            output __tmp_file_list_sys;
         end;
      end;
      rc=dclose(handle);
      if index(upcase(fname),".LST") or index(upcase(fname),".LOG") or index(upcase(fname),".SAS7BDAT");
   run;

   filename _dir_ clear;
   filename _dirsys_ clear;
   %end;

   proc sql noprint;
      select count(distinct fname), fname into :fnum, :fname separated by ' '
      from __tmp_file_list_sas;
   quit;

   proc sql noprint;
      select count(distinct fname), fname into :fnumsys, :fnamesys separated by ' '
      from __tmp_file_list_sys;
   quit;

   %if &fnum eq 0 and &fnumsys ne 0 %then %do;
      proc datasets library=work;
         delete __tmpdt_: __tmp:;
      run;
      quit;

      %put ERROR:  No SAS program file is found.  System files check not performed.;
      %goto exit;
   %end;

   %else %if &fnum eq 0 and &fnumsys eq 0 %then %do;
      proc datasets library=work;
         delete __tmpdt_: __tmp:;
      run;
      quit;

      %put ERROR:  No SAS program file and system files are found.  System files check not performed.;
      %goto exit;
   %end;

   %else %if &fnum ne 0 and &fnumsys eq 0 %then %do;
      proc datasets library=work;
         delete __tmpdt_: __tmp:;
      run;
      quit;

      %put ERROR:  No system files is found.  System files check not performed.;
      %goto exit;
   %end;

   proc sql;
      create table __tmp0_sas as
      select fname as col_sas,scan(fname,1,".") as col_name from __tmp_file_list_sas order by col_name;
      create table __tmp0_lst as
      select fname as col_lst,scan(fname,1,".") as col_name from __tmp_file_list_sys where index(upcase(fname),".LST") gt 0 order by col_name;
      create table __tmp0_log as
      select fname as col_log,scan(fname,1,".") as col_name from __tmp_file_list_sys where index(upcase(fname),".LOG") gt 0 order by col_name;
      %if %upcase(%nrbquote(&sysscp)) ne WIN %then %do;
      create table __tmp0_parmdt as
      select fname as col_parmdt,scan(fname,1,".") as col_name from __tmp_file_list_sys where index(upcase(fname),".SAS7BDAT") gt 0 order by col_name;
	  %end;
   quit;

   data __tmp0;
      merge __tmp0_sas __tmp0_log __tmp0_lst
      %if %upcase(%nrbquote(&sysscp)) ne WIN %then %do;
      __tmp0_parmdt
      %end;
      ;
      by col_name;
      length rslt $100;

      %if %upcase(%nrbquote(&sysscp)) eq WIN %then %do;
      if missing(col_sas) eq 1 and missing(col_log) eq 1 and missing(col_lst) eq 0 then rslt = "5. PROGRAM and LOG are missing.";
      else if missing(col_sas) eq 1 and missing(col_log) eq 0 and missing(col_lst) eq 1 then rslt = "6. PROGRAM and LST are missing.";
      else if missing(col_sas) eq 1 and missing(col_log) eq 0 and missing(col_lst) eq 0 then rslt = "3. PROGRAM is missing.";
      else if missing(col_sas) eq 0 and missing(col_log) eq 1 and missing(col_lst) eq 1 then rslt = "4. LOG and LST are missing.";
      else if missing(col_sas) eq 0 and missing(col_log) eq 1 and missing(col_lst) eq 0 then rslt = "1. LOG is missing.";
      else if missing(col_sas) eq 0 and missing(col_log) eq 0 and missing(col_lst) eq 1 then rslt = "2. LST is missing.";
      else if missing(col_sas) eq 0 and missing(col_log) eq 0 and missing(col_lst) eq 0 then rslt = "0. OK.";
      %end;

      %else %do;
      if missing(col_sas) eq 1 and missing(col_log) eq 1 and missing(col_lst) eq 1 and missing(col_parmdt) eq 0 then rslt = "12. PROGRAM, LOG and LST are missing.";
      else if missing(col_sas) eq 1 and missing(col_log) eq 1 and missing(col_lst) eq 0 and missing(col_parmdt) eq 1 then rslt = "13. PROGRAM, LOG and PARAMETER DATASET are missing.";
      else if missing(col_sas) eq 1 and missing(col_log) eq 1 and missing(col_lst) eq 0 and missing(col_parmdt) eq 0 then rslt = "08. PROGRAM and LOG are missing.";
      else if missing(col_sas) eq 1 and missing(col_log) eq 0 and missing(col_lst) eq 1 and missing(col_parmdt) eq 1 then rslt = "14. PROGRAM, LST and PARAMETER DATASET are missing.";
      else if missing(col_sas) eq 1 and missing(col_log) eq 0 and missing(col_lst) eq 1 and missing(col_parmdt) eq 0 then rslt = "09. PROGRAM and LST are missing.";
      else if missing(col_sas) eq 1 and missing(col_log) eq 0 and missing(col_lst) eq 0 and missing(col_parmdt) eq 1 then rslt = "10. PROGRAM and PARAMETER DATASET are missing.";
      else if missing(col_sas) eq 1 and missing(col_log) eq 0 and missing(col_lst) eq 0 and missing(col_parmdt) eq 0 then rslt = "04. PROGRAM is missing.";
      else if missing(col_sas) eq 0 and missing(col_log) eq 1 and missing(col_lst) eq 1 and missing(col_parmdt) eq 1 then rslt = "11. LOG, LST and PARAMETER DATASET are missing.";
      else if missing(col_sas) eq 0 and missing(col_log) eq 1 and missing(col_lst) eq 1 and missing(col_parmdt) eq 0 then rslt = "05. LOG and, LST are missing.";
      else if missing(col_sas) eq 0 and missing(col_log) eq 1 and missing(col_lst) eq 0 and missing(col_parmdt) eq 1 then rslt = "06. LOG and PARAMETER DATASET are missing.";
      else if missing(col_sas) eq 0 and missing(col_log) eq 1 and missing(col_lst) eq 0 and missing(col_parmdt) eq 0 then rslt = "01. LOG is missing.";
      else if missing(col_sas) eq 0 and missing(col_log) eq 0 and missing(col_lst) eq 1 and missing(col_parmdt) eq 1 then rslt = "07. LST and PARAMETER DATASET are missing.";
      else if missing(col_sas) eq 0 and missing(col_log) eq 0 and missing(col_lst) eq 1 and missing(col_parmdt) eq 0 then rslt = "02. LST is missing.";
      else if missing(col_sas) eq 0 and missing(col_log) eq 0 and missing(col_lst) eq 0 and missing(col_parmdt) eq 1 then rslt = "03. PARAMETER DATASET is missing.";
      else if missing(col_sas) eq 0 and missing(col_log) eq 0 and missing(col_lst) eq 0 and missing(col_parmdt) eq 0 then rslt = "00. OK.";
      %end;
   run;

   proc freq data = __tmp0 noprint;
      tables rslt / out = __summ_syschk(drop=PERCENT);
   run;

   proc sort data = __tmp0 out = __summ_syschk_details;
      by rslt col_name;
   run;

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

%let prp_tmpfile=&parse_filedir.&sep.system_files&sep%lowcase(%sysfunc(compress(&outrpt.&sysdate9..rtf)));

filename rtfout "&prp_tmpfile";
ods listing;
filename tmpfile temp;
proc printto new print=tmpfile;
run;

title1 j=l "Study Programming System Files Overall Check";
title2 j=l "For Snapshot &analy_phase";
title3 j=l "%upcase(&study)";

proc report data = __summ_syschk nowindows split="#" headline headskip spacing = 0;
   column ("--" rslt count);   
   define rslt / width=60 left "Overall Summary";
   define count / width=73 left "Frequency";

   compute before _page_;
      line @1 "Study Programming System Files Overall Check Summary";      
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
proc report data = __summ_syschk_details nowindows split="#" headline headskip spacing = 0;
   %if %upcase(%nrbquote(&sysscp)) eq WIN %then %do;
   column ("--" rslt col_name col_sas col_log col_lst);
   define rslt / order width=40 left "Results";
   define col_name / noprint order;
   define col_sas / width=30 left "Program" flow;
   define col_log / width=31 left "LOG" flow;
   define col_lst / width=32 left "LST" flow;
   %end;
   %else %do;
   column ("--" rslt col_name col_sas col_log col_lst col_parmdt);
   define rslt / order width=60 left "Results";
   define col_name / noprint order;
   define col_sas / width=18 left "Program" flow;
   define col_log / width=18 left "LOG" flow;
   define col_lst / width=18 left "LST" flow;
   define col_parmdt / width=19 left "Parameter#Dataset" flow;
   %end;

   compute before _page_;
      line @1 "Study Programming System Files Overall Check Details";
      line " ";
   endcomp;

   compute after col_name;
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

proc datasets library=work;
   delete __tmpdt_: __tmp:;
run;
quit;

%exit:
%mend chn_ut_sysfilechk;




