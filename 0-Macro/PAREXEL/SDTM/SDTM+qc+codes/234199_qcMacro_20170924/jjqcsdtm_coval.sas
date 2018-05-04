/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 54767414MMY1006
  PXL Study Code:        228657

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:               Qingjie Zeng $LastChangedBy: xiaz $
  Creation Date:         13Oct2014 / $LastChangedDate: 2017-07-26 03:18:49 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/macros/jjqcsdtm_coval.sas $

  Files Created:         sdtm_coval.log

  Program Purpose:       To add variables for the text exceeding 200 characters

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 2 $
-----------------------------------------------------------------------------*/

%MACRO jjqcsdtm_coval ( indata =, outdata=, invar =, outvar =, rvar =);
	OPTIONS nomprint nomlogic nosymbolgen;
PROC SQL noprint;
	select max(ceil(length(&invar)/200)-1) into: n from &indata;
QUIT;

%put &n;


DATA &outdata;
	SET &indata.;
	ovar=&invar; 
	%if &n=0 %then %do;
	   attrib COVAL label="Comment" length=$200.;
	   COVAL=COVAL_t;
	%end;

	%else %if &n>0 %then %do i=1 %to &n;
	if length(&invar)>200 then do;
		length temp $200; 
		temp=substr(&invar,1,200);
		reverse=reverse(temp);

		pos=indexc(reverse, ",. ");

		if substr(reverse(temp),1,1) in (" ", ".",",")
			or substr(&invar,201,1) in (" ", ".", ",") then do;
			&outvar._&i=temp;
			&rvar._&i=substr(&invar.,201);
		end;

		else do ;
			&outvar._&i=substr(temp,1,200-pos+1);
			&rvar._&i=substr(&invar,200-pos+2);
		end;
    end;
	else if length(&invar) le 200 then &outvar._&i=&invar;

	%if &i=1 %then %do;
		coval=&outvar._&i;
		if length(&rvar._&i) le 200 then coval1=&rvar._&i;
	%end;

	%if &i^=1 %then %do;
	%let j=%eval(&i-1);
	coval&j=strip(&outvar._&i);
	if length(&rvar._&i) le 200 then coval&i=strip(&rvar._&i);
%end;
	&invar=&rvar._&i;

	%end;
RUN;
%MEND;
