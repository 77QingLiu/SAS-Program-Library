/**soh******************************************************************************************************************
Eli Lilly and Company (required)- GSS
CODE NAME (required)              : chn_ut_readN.sas
PROJECT NAME (required)           : component_modules
DESCRIPTION (required)            : read big N in rtf - China Internal Use
SPECIFICATIONS(required)          : Validation Process in Handbook - China Internal Use
VALIDATION TYPE (required)        : Peer Review
INDEPENDENT REPLICATION (required): 
ORIGINAL CODE (required)          : N/A, this is the original code
COMPONENT CODE MODULES            : 
SOFTWARE/VERSION# (required)      : SAS/version 9.2
INFRASTRUCTURE                    : 
DATA INPUT                        : 
OUTPUT                            : 
SPECIAL INSTRUCTIONS              : the refference is http://www2.sas.com/proceedings/sugi31/066-31.pdf
                                    chn_ut_readrtf will be called as a submacro when this macro is executed
-------------------------------------------------------------------------------------------------------------------------------  
-------------------------------------------------------------------------------------------------------------------------------
DOCUMENTATION AND REVISION HISTORY SECTION (required):
   Author &
Ver# Validator        Code History Description
---- ---------------- -----------------------------------------------------------------------------------------------------
1.0   Jiashu Li        Original version of the code
 		     

PARAMETERS:

Name        Type         Default                  Description and Valid Values
---------   ------------ ------------------       --------------------------------------
indir       required                              input folder
select      not required missing                  all/*.rtf/sm*.rtf/f*.rtf
population  not required ITT/MITT/SAFETY          XXXXXXXX/xxxxxxxx
                         PER-PROTOCOL
                         ALL ENTERED PATIENTS
                         ALL RANDOMIZED PATIENTS                         
                         FULL ANALYSIS SET   
outfile     required                              output html file 
cleanup     required                              yes/no

Example:
%chn_ut_readN(indir=&indir,select=*.rtf,population=,outfile=&x_check,cleanup=yes)

  
**eoh*******************************************************************************************************************/





%macro chn_ut_readN(indir=, select=, population=,outfile=, cleanup=);
  %if %substr(&indir,%length(&indir),1)=\ %then %let indir=%substr(&indir,1,%length(&indir)-1);
 
  %let select=%upcase(&select);
  %let select=%sysfunc(tranwrd(&select,.RTF,));
  %if "&select"="ALL" or "&select"="" %then %let select=*;	

  %fwords06(string=&select, root=fbrowse);
  %do i=1 %to &nwords;
  	data rtfs;
	    length filename $96 folder $260;
	    set _null_;
	    call missing(filename,folder); /*to avoid uninitia lized message*/
  	run;
    %let fbrowse&i=&&fbrowse&i...RTF;
    %if %index(&&fbrowse&i,*)>0 or %index(&&fbrowse&i,?)>0 %then %do;
      filename fin pipe "dir /b &indir\&&fbrowse&i";
      data fbrowse01;
        infile fin truncover;
        input filename $96.;
        folder="&indir";
      run;
      data rtfs;
        set rtfs fbrowse01;
		if  substr(upcase(filename),1,2) not in ('LS','GR'); 
      run;
    %end;
    %else %if %sysfunc(fileexist(&indir\&&fbrowse&i))=0 %then
      %put WARNING: "&indir\&&fbrowse&i" is not f ound.;
    %else %do;
      data fbrowse02;
        filename="&&fbrowse&i";
        folder="&indir";
      run;
      data rtfs;
        set rtfs fbrowse02;
		if  substr(upcase(filename),1,2) not in ('LS','GR'); 
      run;
    %end;
  %end;


  proc sql ;
	  select count(filename) into : nrtf
	  from rtfs;
	  select distinct filename into: rtf1-:rtf%trim(&nrtf)
	  from rtfs;
  quit;

  *_____________________________KEY_____________________________;

  %do p=1 %to &nrtf;
		%readrtf(indir=&indir, rtf=&&&rtf&p, if=, outds=_out&p, cleanup=&cleanup);
  %end;

  *_____________________________________________________________;

  %put &nrtf;

	  data _outa;
		set %do k=1 %to &nrtf; _out&k  %end; ;
	  run;

	proc sql noprint;
	select name into: cmax
	from sashelp.vcolumn
	where libname='WORK' and memname='_OUTA' and upcase(name) like "C%"
	having varnum=max(varnum);
	quit;

	 data _outb;
	 	set _outa;
	 	length ninfor $500.;
		ninfor=catx(' ', of c1-&cmax);
		if ninfor='' then ninfor='Not Available';
	  run;

	%*----------------- Make the inform in one record per N value;
	  proc sort data=_outb;
	  by filename;
	  run;

	  proc transpose data=_outb out=_outc(drop=_name_ rename=(col1=cola col2=colb));
	  by filename;
      var ninfor;
     run;
	 proc sort data=_outc;by cola colb;run;
    proc transpose data=_outc out=_outd;
	by cola colb;
	  var filename;
     run;

	proc sql noprint;
	select name into: colmax2
	from sashelp.vcolumn
	where libname='WORK' and memname='_OUTD'
	having varnum=max(varnum);
	quit;

	%put &colmax2;

	data _bign;
	  set _outD;
	  length tables $500.;
	  analset=colA;
	  bign=colB;
	  tables=catx('; ',of col1-&colmax2);
	  label analset='Population' bign='Big N Information' tables='Output(s)';
	run;
	proc sort;by analset;run;

	%let today=%sysfunc(date(),date9.);

	ods listing close;
	ods html file="&outfile..html" style=egdefault;

	title "Big N in &indir\ &select..rtf";
	title2 "---report created on &today";
	 proc report data=_bign nowindows headline headskip split="#" headline spacing = 0 missing;
    column analset bign tables;
     Define analset / display id group width =20 flow left ;
     Define bign / display width =46 flow left ;
     Define tables / display width =66 flow left ;
     compute after analset;
  line " ";
   endcomp;
   run;

	ods html close;
	ods listing;
	%if %upcase(&cleanup)=YES %then %do;
		proc datasets memtype=data;
		delete _out:;
		quit;
	%end;

%mend;



