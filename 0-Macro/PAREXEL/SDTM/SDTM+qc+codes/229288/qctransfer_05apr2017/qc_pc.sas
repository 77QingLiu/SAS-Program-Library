/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Pengfei Lu $LastChangedBy: liuc5 $
  Creation Date:         05Jul2016 / $LastChangedDate: 2016-08-25 06:09:18 -0400 (Thu, 25 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_pc.sas $

  Files Created:         qc_pc.log
                         qc_pc.txt
                         /projects/janss229288/stats/transfer/data/qtransfer/pc.sas7bdat

  Program Purpose:       To QC Pharmacokinetic Concentrations Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 33 $
-----------------------------------------------------------------------------*/
%jjqcclean;

*------------------- Get meta data --------------------;
%let domain=PC;
%jjqcvaratt(domain=PC);
%jjqcdata_type;

*------------------- Read raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier sitegroup instanceid 
             instancerepeatnumber folderid folder targetdays datapageid recorddate recordid 
             mincreated maxupdated savets;
data PC_RAW; /* Form: Survival Data */
    set raw.PC_GL_900(where=(&raw_sub))
        raw.PC_GL_900_1(where=(&raw_sub))
        raw.PC_GL_900_2(where=(&raw_sub))
        raw.PC_GL_900_3(where=(&raw_sub))
        raw.PC_GL_900_4(where=(&raw_sub))
        ;
    rename PCTPT=PCTPT_ PCSPEC=PCSPEC_;
    drop &dropvar;
run;

/*start to create*/
data pc_(drop=VISIT VISITNUM VISITDY PCDY PCBLFL EPOCH PCSEQ);
  attrib &&&domain._varatt_;
  set PC_RAW;

   call missing(PCORRES,PCORRESU,PCSTRESC,PCSTRESN,PCSTRESU,PCNAM,PCBLFL,
                PCLLOQ,EPOCH,VISIT,VISITNUM,VISITDY,PCDY,PCSEQ);

   STUDYID  = strip(PROJECT);
   DOMAIN   = "&domain";
   USUBJID  = catx("-",PROJECT,SUBJECT);
   PCSPID   = upcase(catx("-","RAVE",INSTANCENAME,DATAPAGENAME,cats(PAGEREPEATNUMBER),cats(RECORDPOSITION)));

   PCTESTCD = 'PCALL';
   PCTEST = put(PCTESTCD,$PC_TESTCD.);
   PCCAT = 'ANALYTE';
   PCSPEC = 'BLOOD';

   if cats(PCTPT_STD) in ('PREDOSE') then do; PCTPT = 'PREDOSE'; PCTPTNUM = -0.001; end;
   else if ^missing(PCTPT_STD) then do;
       if index(PCTPT_STD,'M') then do;
	      PCTPTNUM = round(input(tranwrd(PCTPT_STD,'M',''),best.)/60,0.001);
	      PCTPT = cats(PCTPT_STD,'IN');
	   end;
       if index(PCTPT_STD,'H') then do;
	      PCTPTNUM = input(tranwrd(PCTPT_STD,'H',''),best.);
	      PCTPT = cats(PCTPT_STD);
	   end;
   end;

   %jjqcdate2iso(in_date=PCDAT, in_time=PCTIM, out_date=&domain.DTC);

   if upcase(PCYN) = 'NO' then do; PCSTAT = 'NOT DONE'; PCREASND = 'SAMPLE NOT COLLECTED'; output; end;
   else if upcase(PCYN) = 'YES' then do; PCSTAT = ''; PCREASND = ''; output; end;

  format _all_;
  informat _all_;

  keep &&&domain._varlst_ 
        sitenumber subject foldername instancename;
run;
proc sort; by sitenumber subject foldername instancename; run;


%jjqcvisit(in_data=pc_, out_data=pc_1_, date=);

/*calculate --STDY and --ENDY*/
%jjqccomdy(in_data=pc_1_, out_data=PC_1, in_var=PCDTC, out_var=PCDY);

/*add epoch*/
%jjqcmepoch(in_data=PC_1, out_data=PC_2,in_date=PCDTC);

/*add --blfl*/
%jjqcblfl(in_data  =PC_2,out_data =PC_3,DTC =PCDTC);
     
/*add seqnum*/
%jjqcseq(in_data=PC_3,out_data=PC_4,retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_);

%qcoutput(in_data =PC_4);


************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.PC
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

