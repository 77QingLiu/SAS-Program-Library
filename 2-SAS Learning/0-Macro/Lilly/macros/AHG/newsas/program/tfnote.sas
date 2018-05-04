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

%macro tfnote(myfootnote1=,myfootnote2=,addtitle1=I3Y-MC-JPBL,addtitle2=%str(DMC August 2016 (Data cutoff: 23JUN2016)),label_subgroup=,specd=specs.meta_tfl);
option NOQUOTELENMAX;
data meta;
  set &specd;
  where strip(upcase(display_identifier))=strip(upcase("&spec_name"));
run;

data footnote;
  set meta ;
  length  oneline $3000 realft  $%sysfunc(getoption(ls));
/*  ftpgm="Program Location: %str(&prg)&pgmname..sas"; */
/*  ftout="Output Location: %str(&rptfile)&outfile..rtf"; */
/*  ftdt="Data Set Location: &rptindat"; */
  array allft ABBREVIATIONS_FOOTNOTE DISPLAY_FOOTNOTES ;
/*  realft="___";*/
/*  output;*/
  realft='';
  do over allft;
    do i=1 to 10;
      if scan(allft,i,byte(10))='' then leave;
      else 
        do;
        oneline=scan(allft,i,byte(10)) ;

        DO j=1 TO 1000;
          if scan(oneline,j,' ')='' then 
            do;
            if not missing(realft) then output;
            realft='';
            leave;
            end;
          else 
            do;
            if length(catx(' ',realft,scan(oneline,j,' ')))>= %sysfunc(getoption(ls)) then 
               do;
               output;
               realft=scan(oneline,j,' ');
               end;
            else realft=catx(' ',realft,scan(oneline,j,' '));
            end;
        END;
        end;
    end; 
  end;
run;

/*data footnote;*/
/*  set footnote;*/
/*  output;output;output;*/
/*run;*/


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




%mend;
   

