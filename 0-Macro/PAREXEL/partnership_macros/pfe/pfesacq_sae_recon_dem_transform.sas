/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_sae_recon 
               
                         Call from parent submacro pfesacq_sae_recon.sas:
                         %pfesacq_sae_recon_dem_transform(indsdm=demg,
                                                          outdir=/projects/pfizr216611/dm/listings/current);

-------------------------------------------------------------------------------
 
  Author:                Shiva Bhimreddy, $LastChangedBy: bhimres $
  Creation Date:         05MAY2015                       $LastChangedDate: 2015-10-01 17:22:10 -0400 (Thu, 01 Oct 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_sae_recon_dem_transform.sas $
 
  Files Created:         None
 
  Program Purpose:       Map raw EDC dataset into Standard sACQ dataset as per sACQ structre
						  and Recon specifications
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 

  Macro Output:  

  Macro Dependencies:    Note: Part of program: pfesacq_sae_recon 

                         This is a submacro dependant on calling parent macro: 
                         pfesacq_sae_recon.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2284 $
  
-----------------------------------------------------------------------------*/

%macro pfesacq_sae_recon_dem_transform();
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_DEM_TRANSFORM: Start of Submacro;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_DEM_TRANSFORM: indsdm=&indsdm, study=&study, subjid=&subjid, sex=&sex, dob=&dob;
    %put ---------------------------------------------------------------------;
    %put ;

	%local nobs dobtype doblen sextype;

	libname outdir "&path_listings./current";

	%if %sysfunc(exist(download.&indsdm)) %then %do;

	proc sql noprint;
		select count(*) into:nobs
		from download.&indsdm;
	quit;

	%if &nobs=0 %then %goto macerr;

	*** Read the input demography dataset and Create variables as per the sACQ Specs***;

	data dm1;
		set download.&indsdm(rename=(&dob=birthday &sex=sex11));
	run;

	proc contents data=dm1 noprint out=dmcont;
	run;

	data _null_;
		set dmcont;
		where upcase(name)='BIRTHDAY';
		typec=strip(put(type,best.));
		lengthc=strip(put(length,best.));
		call symput ("dobtype", typec);
		call symput ("doblen",  lengthc);
	run;
	data _null_;
		set dmcont;
		where upcase(name)='SEX11';
		typec=strip(put(type,best.));
		call symput ("sextype", typec);
	run;

	data demo;

		attrib  STUDY   length = $200 label = 'Clinical Study'
				SUBJID  length = $200 label = 'Subject ID'
				SEX     length = $200 label = 'Gender Code'
				DOB     length = $200 label = 'Date of Birth';

		set download.&indsdm (rename=(&study=study1 &subjid=subjid1 &sex=sex1 &dob=dob1));

		study  = upcase(study1);
		subjid = compress(subjid1,'-|_ ');

		%if       &sextype=2 %then %do;
									if substr(upcase(sex1),1,1)='F' then sex = 'FEMALE';
									if substr(upcase(sex1),1,1)='M' then sex = 'MALE';
									if substr(upcase(sex1),1,1)='2' then sex = 'FEMALE';
									if substr(upcase(sex1),1,1)='1' then sex = 'MALE';
                                    %end;
		%else %if &sextype=1 %then %do;
									if sex1=2 then sex = 'FEMALE';
									if sex1=1 then sex = 'MALE';
                                    %end;


		%if       &dobtype=1 %then %do;dob = strip(put(dob1,yymmdd10.));%end;
		%else %if &dobtype=2 %then %do;
							dob2=dob1;
							dob1=upcase(compress(dob1,'-_'));
							if indexc(dob1,'ABCDEFGHIJKLMNOPQRSUVWXYZ')>0 and (substr(dob1,1,2) not in ('UN','XX') and substr(dob1,3,3) not in ('UNK','XXX')  
                               and substr(dob1,6,3) not in ('UNK','XXX') ) and length(dob1)>=9 then do;
										dobn = input(dob1,date9.);
										if dobn ne . then dob=strip(put(dobn,yymmdd10.));
																						            end;
                             else do;
								if length(dob1)=8 and anyalpha(dob1)=0 then dob = compress(substr(dob1,1,4)||'-'||substr(dob1,5,2)||'-'||substr(dob1,7,2));
							 end;

							if dob='' and dob2 ne '' then dob=dob2;

								   %end;
												        

		*if length(dob)<10 then dob='';

	run;

	proc sort data=demo nodupkey;
		by study subjid1;
	run;

	data outdir.dm_crf;
		set demo;
		keep study subjid sex dob;
	run;

	proc datasets library=work nolist;
		delete dm1 dmcont demo;
	quit;

	%end;

	%else %do;
    			%put %str(ERR)OR:[PXL]------------------------------------------------------------------------;
    			%put %str(ERR)OR:[PXL] PFESACQ_SAE_RECON_DEM_TRANSFORM: alert: Dataset &indsdm does not exist.;
    			%put %str(ERR)OR:[PXL]------------------------------------------------------------------------;
		  %end;


	%goto macend;
	%macerr:;
	%put %str(ERR)OR:[PXL] -------------------------------------------------------------------------------------;
	%put %str(ERR)OR:[PXL] PFESACQ_SAE_RECON_DEM_TRANSFORM: The input dataset &indsdm has zero (0) observations.;
	%put %str(ERR)OR:[PXL] -------------------------------------------------------------------------------------;

    %macend:;
    %put ;
    %put ---------------------------------------------------------------------;
    %put NOTE:[PXL] PFESACQ_SAE_RECON_DEM_TRANSFORM: End of Submacro;
    %put ---------------------------------------------------------------------;
    %put ;

%mend pfesacq_sae_recon_dem_transform;
