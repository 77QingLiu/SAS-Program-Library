/**************************************************************************************************************************************************
Eli Lilly and Company - GSS (required)
CODE NAME (required)                : /lillyce/prd/ly2835219/i3y_mc_jpbm/dmc_blinded2/programs_nonsdd/tfl/titlefootnote.sas
PROJECT NAME (required)             : I3Y_MC_JPBM
DESCRIPTION (required)              : Title footnote set up
SPECIFICATIONS(required)            : N/A
VALIDATION TYPE (required)          : N/A This is a component modeule 
INDEPENDENT REPLICATION (required)  : N/A
ORIGINAL CODE (required)            : N/A, it is original code
COMPONENT CODE MODULES              : N/A
SOFTWARE/VERSION# (required)        : SAS Version 9.2
INFRASTRUCTURE                      : AWE
DATA INPUT                          : N/A
OUTPUT                              : N/A
SPECIAL INSTRUCTIONS                : N/A
-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
DOCUMENTATION AND REVISION HISTORY SECTION (required):

       Author &
Ver# Validator            Code History Description
---- ----------------     -----------------------------------------------------------------------------------------------------------------------
1.0  Ella Cheng              Original version of the code
     Jenny Zhou
This program is copied from RUM and updated to coordinate with study specific needs:
    1) title/footnote should be read from &specd because the main program is run outside of Taffy interface;
    2) &spec_name should exist outside of this macro to target the selected table;
    3) two additional titles and footnotes are allowed to assign - this is consistent with taffy
    4) label_subgroup is changed to be manually assigned
    5) other open environment macro variables are defined in tfl_setup.sas e.g.production_status,prg,rptfile,rptindat,_lstot_,_pstot_, _ls_
    6) should be used before proc report
**eoh***********************************************************************************************************************************************/

%macro titlefootnote(myfootnote1=,myfootnote2=,addtitle1=I3Y-MC-JPBL,addtitle2=%str(),label_subgroup=,specd=specs.meta_tfl);
option NOQUOTELENMAX;
data meta;
  set &specd;
  where strip(upcase(display_identifier))=strip(upcase("&spec_name"));
run;

data meta1;
  set meta;
  length _Abfot  $1000;
  array a[10] $1000 fot1-fot10  ;
  _Abfot=Abbreviations_Footnote;
  i=0;
  if index (_Abfot,byte(10))>0 then do;
    i=1;
    do while (missing(scan(_Abfot,i,byte(10)))=0 and i<=10);
      a[i]=scan(_Abfot,i,byte(10));
	  if anyalnum(a[i]) then do;
	    call symput('footnote'||strip(put(i,best.)),strip(a[i]));
	    i=i+1;
      end;
	  else a[i]='';
	end;
	i=i-1;
  end; 
  else if cmiss(_abfot)=0 then do; fot1=  _Abfot;
      i=1; 
  	  call symput('footnote1',strip(_Abfot));
  end;
  if i>=1 then do;
    call symput('abvf',strip(put(i+2,best.)));
    call symput('footnote'||strip(put(i+1,best.)),'');
  end;
  else do;
   call symput('abvf',strip(put(i+1,best.)));
  end;
run;

data meta2;
  set meta;
  length _dsfot  $1000;
  array a[10] $1000 fot1-fot10  ;
  _dsfot=display_Footnotes;
   i=&abvf;
   j=1;
  if index (_dsfot,byte(10))>0 then do;
    do while (missing(scan(_dsfot,j,byte(10)))=0 and j<=10);
      a[i]=scan(_dsfot,j,byte(10));
	  if anyalnum(a[i]) then do;
	    call symput('footnote'||strip(put(i,best.)),strip(a[i]));
		i=i+1;
      end;
	  j=j+1;
	end;
	i=i-1;
  end; 
  else if cmiss(_dsfot)=0 then do;  fot1=  _dsfot;
    i=&abvf; 
  	call symput('footnote'||"&abvf",strip(_dsfot));
  end;
  else i=i-1;
  call symput('fnm_',strip(put(i,best.)));

run;

data meta3;
  set meta;
  i=1;
  if cmiss(strip(Table_Title))=0 then do; call symput('title'||strip(put(i,best.)),strip(Table_Title)); i=i+1;end;
  if cmiss(strip(SECONDARY_TITLES))=0 then do; call symput('title'||strip(put(i,best.)),strip(SECONDARY_TITLES));i=i+1;end;
  if cmiss(strip(Population_Title))=0 then do; call symput('title'||strip(put(i,best.)),strip(Population_Title));i=i+1;end;
  if cmiss(strip(ADDITIONAL_TITLES))=0 then do;call symput('title'||strip(put(i,best.)),strip(ADDITIONAL_TITLES));i=i+1;end;
  %if %superq(addtitle1)^= %then %Do;
  call symput('title'||strip(put(i,best.)),strip("&addtitle1"));i=i+1;
  %end;
  %if %superq(addtitle2)^= %then %Do;
  call symput('title'||strip(put(i,best.)),strip("&addtitle2"));i=i+1;
  %end;
  i=i-1;
  call symput('tnm_',strip(put(i,best.)));

run;

 data title1; 
      length name $32 value $200;
      do i=1 to &tnm_;
         if symexist('title'||compress(put(i,best.))) then do; 
            name='TITLE'||compress(put(i,best.));
            value=symget(name);
           output;
          end;
      end;
   run;

  data title2; set title1 end=eof;
   length string $200;
   if strip(upcase(value))='NULL' then value='09'x;      
   if upcase(name)='TITLE1' then string='title1 j=l "'||strip(value)||'  (page xxx)'||'"; ';
   else if upcase(name)='TITLE2' then string='title2 j=l "'||strip(value)||'  (date xxx)'||'"; ';
   else if upcase(name)='TITLE3' then string='title3 j=l "'||strip(value)||"  (dmpm: &production_status)"||'"; ';   
   else if upcase(name)='TITLE4' then string='title4 j=l "'||strip(value)||'"; ';
   else if upcase(name)='TITLE5' then string='title5 j=l "'||strip(value)||'"; ';
   else if upcase(name)='TITLE6' then string='title6 j=l "'||strip(value)||'"; ';
   else if upcase(name)='TITLE7' then string='title7 j=l "'||strip(value)||'"; ';
   else if upcase(name)='TITLE8' then string='title8 j=l "'||strip(value)||'"; ';
   
   output;
  run;

  proc sort data=title2 out=title3 nodupkeys; by string; run;
 
  data title; set title3 end=eof;
    titlen=input(tranwrd(scan(string,1),'title',''),best.);
	     output;
  %if &label_subgroup^= %then %do;
   if eof then do;
	 titlen+1;
	 string='title'||put(titlen,1.)||' j=l "'||strip("&label_subgroup")||'";';
     output;
	end;
  %end;
  run;

  proc sort data=title; by string; run;
  
    data _null_; set title;
    call execute(string);
	run;**;


   %let mft1=%sysfunc(ifc(%length(&myfootnote1)>0,&myfootnote1,NULL));
   %let mft2=%sysfunc(ifc(%length(&myfootnote2)>0,&myfootnote2,NULL));

   data footnote_shell;
    length ftn 8. footnote $500 mft1 mft2 $200;
  
	mft1="&mft1"; mft2="&mft2"; 
    retain ftn 0;

	ftn=1; footnote="___"; output;
	%do __i=1 %to &fnm_;
	ftn=&__i+1; footnote=strip("&&footnote&__i"); output;
	%end;	                                                                      

    if mft1 ne 'NULL' then do;
	 ftn+1; footnote="&myfootnote1";  output; 
    end;
    if mft2 ne 'NULL' then do;
	 ftn+1; footnote="&myfootnote2";  output; 
    end;
	 ftn+1; footnote=" ";   output;                                                                                                                   

    ftn+1; footnote="Program Location: %str(&prg)&pgmname..sas";   output;                                                                                                                   
    ftn+1; footnote="Output Location: %str(&rptfile)&outfile..rtf"; output; 
    ftn+1; footnote="Data Set Location: &rptindat"; output;
  run;


    ***female and male gender specfic AE footnote***;
	***footnote letter***;
	
   ***wrap footnote by comma, for footnote a and b gender specific***;
    data footnote2; set 
    footnote_shell(rename=(footnote=old_footnote));
	length footnote $200 ;
	 do until (compress(old_footnote)='');
      if length(old_footnote)>&_lstot_ then do;
	    ___lenx=indexc(reverse(substr(old_footnote,1,&_lstot_)),'; ,/-_');*wrap at separators;
	    footnote=substr(old_footnote,1,&_lstot_-max(1,___lenx)+1); output;
	    old_footnote=substr(old_footnote,&_lstot_-max(1,___lenx)+2 );
	  end;
      else do;
	    footnote=old_footnote;
        old_footnote='';
        output;
	  end;
	 end;
	run;

	data _null_;
	set footnote2 end=eof;
	if eof then call symputx('__nooffoot',strip(put(_n_,best.)),'g');
	run;

	****for exmpty table, keep 3 lines footnote***;

	proc transpose data=footnote2 out=footnote prefix=ft;
	var footnote;
	run;

%mend titlefootnote;
   
