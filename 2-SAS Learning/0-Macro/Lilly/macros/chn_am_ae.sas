/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : chn_am_ae.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : 

DESCRIPTION               : Providing 3 levels frequency count  for AE or CM                           

SOFTWARE/VERSION#         : SAS/Version 9.2
INFRASTRUCTURE            : SDD version 3.5

LIMITED-USE MODULES       : n/a

BROAD-USE MODULES         : n/a
INPUT                     : n/a
OUTPUT                    : n/a
 
VALIDATION LEVEL          : 4
REQUIREMENTS              : n/a
ASSUMPTIONS               : Prior to using this macro, users need to create the
                            proper dataset as the input dataset
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: n/a

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: n/a

PARAMETERS:
Name                 Type     Default    Description and Valid Values
---------            -------- ---------- --------------------------------------------------
inds	             required             Input dataset(with all the treatment group include 'total')
indemo               required             Input demo dataset
trt                  required             treatment group or subgroup(F/M) - need to be prepared before this macro - numeric type
cond                 optional             where can put the selecting condition  
level                optional             level 1 - SOC/HLTERM/SMQ/Subcategory   character type   
level2               optional             PTERM - character type
level3               optional             AESEVlnm- character type
pval                 optional             if &pval is not missing then p-value will be output
                                          p-value is from Fisher's exact test
                                          maxtime=300
tnb                  optional             treatment group number(if one treatment group has no ae 
                                          and it need to be presented as 0 (0.0) then put the treament number here)
sumorder             optional             for AE summary and other one level summary
type                 optional             specifies summary text to be printed in the report, for example, Patients with >= 1 TEAE
outstats             required             output dataset

There are several sort variable in the output dataset(varorder, ord, ordn, ordnn). 

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:
2 level(socterm/pterm)
chn_am_ae(inds=events, indemo=subjinfo,trt=trtn,cond=trtn^=.,level= SOCterm,level2=PTERM,type=Patients with >= 1 TEAE,outstats=AERPT) ;
3 level(socterm/pterm/aesevlnm with/without p-value) 
chn_am_ae(inds=events, indemo=subjinfo,trt=trtn,cond=trtn^=.,level= SOCterm,level2=PTERM,level3=aesevlnm,type=Patients with >= 1 TEAE,outstats=AERPT) ; 
chn_am_ae(inds=events, indemo=subjinfo,trt=trtn,cond=trtn^=.,level= SOCterm,level2=PTERM,level3=aesevlnm,pval=Y,type=Patients with >= 1 TEAE,outstats=AERPT) ; 
1 level(pterm)
chn_am_ae(inds=events, indemo=subjinfo,trt=trtn,cond=trtn^=.,level= ,level2=PTERM,type=Patients with >= 1 TEAE,outstats=AERPT) ; 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

          Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Jiashu Li         Original version of the code
       
**eoh************************************************************************/
%macro chn_am_ae(inds=, indemo=,trt=,cond=,level= ,level2=,level3=,tnb=,pval=,type=,sumorder=,outstats=) ; 
    data sumae;
	       set &inds;
		   %if &cond ne %then %do;
                  where &cond;
           %end;
	  run;

/** Total Adverse Events **/
     %chn_freq_ae(inds= sumae, indemo=&indemo,trt=&trt,tnb=&tnb, type=&type,varorder=1 );


/*SOC or SMQ need */
   %if &level ne %then %do;
      /** individual Adverse Events SOC or SMQ **/
      proc sql NOPRINT;
            select count (distinct &level) into: bodn from  sumae;
            select distinct &level into: bod1-:bod%cmpres(&bodn)  from  sumae;
      quit;
      %macro doit;

	       %do x=1 %to &bodn;
	          	%chn_freq_ae(inds= sumae, indemo=&indemo,where= &level = "&&bod&x", trt=&trt,tnb=&tnb,varorder=%eval(1+&x) );
	       %end;

       %mend doit;

       %doit;
  %end;


/*SOC or SMQ is not need */
  %else %if &level2 ne %then %do;
	           %chn_freq_ae(inds= sumae, indemo=&indemo,where=%str(&trt^=.), tnb=&tnb,trt=&trt,varorder=2 );
  %end;
        data &outstats;
             set stat_rpt;
			 %if &sumorder ne %then %do;
                    sumorder=&sumorder;
			 %end;
        run;
%mend;
