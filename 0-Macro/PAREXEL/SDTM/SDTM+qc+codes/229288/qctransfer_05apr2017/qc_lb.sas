/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: wangfu $
  Creation Date:         27Jun2016 / $LastChangedDate: 2017-03-20 22:34:16 -0400 (Mon, 20 Mar 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_lb.sas $

  Files Created:         qc_LB.log
                         LB.sas7bdat

  Program Purpose:       To QC Findings About Laboratory Test Results Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 145 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=LB;
%jjqcvaratt(domain=LB);
%jjqcdata_type;
%put &where_raw_lab;

*------------------- Read raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier sitegroup instanceid 
             instancerepeatnumber folderid folder targetdays datapageid recorddate recordid 
             mincreated maxupdated savets ;
data LB_ONC_004;
    set raw.LB_ONC_004(where=(&raw_sub));
    drop &dropvar;
run;

data LB_ONC_005;
    set raw.LB_ONC_005(where=(&raw_sub));
    drop &dropvar;
run;

data LB_GL_904_3;
    set raw.LB_GL_904_3(where=(&raw_sub));
    drop &dropvar LBCAT;
run;

data LB_MDS_006;
    set raw.LB_MDS_006(where=(&raw_sub));
    drop &dropvar;
run;

data LB_GL_903;
    set raw.LB_GL_903(where=(&raw_sub));
    drop &dropvar LBCAT LBPERF;
run;

data LB_GL_904;
    set raw.LB_GL_904(where=(&raw_sub));
    drop &dropvar LBCAT LBPERF;
run;

data LB_ONC_001;
    set raw.LB_ONC_001(where=(&raw_sub));
    drop &dropvar LBPERF;
run;

*------------------- Mapping --------------------;
%macro LB(where=,LBTESTCD=,LBORRES=,LBORRESU=,LBMETHOD=,LBCAT=,LBSPEC=);
    if &where then do;
        LBTESTCD = "&LBTESTCD";
        LBTEST   = put(LBTESTCD,$LB_TESTCD.);
        %if %scan(&LBORRES,1,|) = N %then LBORRES = put(%scan(&LBORRES,2,|),best. -l);;
        %if %scan(&LBORRES,1,|) = C %then LBORRES= strip(upcase(%scan(&LBORRES,2,|)));;
        LBORRESU = &LBORRESU;
        LBMETHOD = &LBMETHOD;
        %if &LBCAT ne %then LBCAT = &LBCAT;;
        %if &LBSPEC ne %then %str(LBSPEC = &LBSPEC;);%else %str(LBSPEC= '';);       
        output;
    end;
%mend;
/* Form Local Efficacy Lab Results - Serum */
data LB_1a;
    set LB_ONC_004;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    LBSPID  = catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME), put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    %jjqcdate2iso(in_date =LBDAT, in_time=, out_date=LBDTC);
    %LB(where=^missing(MCPROT),         LBTESTCD=MCPROT,  LBORRES=N|MCPROT,      LBORRESU=MCPROTU, LBMETHOD="",  LBCAT='CHEMISTRY', LBSPEC  ='SERUM');
    %LB(where=^missing(MCPROTIM_STD),   LBTESTCD=MCPROT,  LBORRES=C|MCPROTIM_STD,LBORRESU="",      LBMETHOD="IMMUNOFIXATION",  LBCAT='CHEMISTRY',LBSPEC  ='SERUM');
    %LB(where=^missing(IGA),            LBTESTCD=IGA,     LBORRES=N|IGA,         LBORRESU=IGAU,    LBMETHOD="",  LBCAT='IMMUNOLOGY');
    %LB(where=^missing(IGG),            LBTESTCD=IGG,     LBORRES=N|IGG,         LBORRESU=IGGU,    LBMETHOD="",  LBCAT='IMMUNOLOGY');
    %LB(where=^missing(IGM),            LBTESTCD=IGM,     LBORRES=N|IGM,         LBORRESU=IGMU,    LBMETHOD="",  LBCAT='IMMUNOLOGY');
    %LB(where=^missing(IGD),            LBTESTCD=IGD,     LBORRES=N|IGD,         LBORRESU=IGDU,    LBMETHOD="",  LBCAT='IMMUNOLOGY');
    %LB(where=^missing(IGE),            LBTESTCD=IGE,     LBORRES=N|IGE,         LBORRESU=IGEU,    LBMETHOD="",  LBCAT='IMMUNOLOGY');
    %LB(where=^missing(B2MICG),         LBTESTCD=B2MICG,  LBORRES=N|B2MICG,      LBORRESU=B2MICGU, LBMETHOD="",  LBCAT='CHEMISTRY');
    %LB(where=^missing(KLCFR),          LBTESTCD=KLCFR,   LBORRES=N|KLCFR,       LBORRESU=KLCFRU,  LBMETHOD="",  LBCAT='IMMUNOLOGY',LBSPEC  ='SERUM');
    %LB(where=^missing(LLCFR),          LBTESTCD=LLCFR,   LBORRES=N|LLCFR,       LBORRESU=LLCFRU,   LBMETHOD="",  LBCAT='IMMUNOLOGY',LBSPEC  ='SERUM');
    %LB(where=^missing(KLCLLCFR),       LBTESTCD=KLCLLCFR,LBORRES=N|KLCLLCFR,    LBORRESU=KLCLLCFRU,LBMETHOD="",  LBCAT='IMMUNOLOGY',LBSPEC  ='SERUM');

    call missing(of LBSEQ LBGRPID LBSCAT LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBNAM LBBLFL
                    VISITNUM VISIT VISITDY EPOCH LBENDTC LBDY LBENDY LBSTAT LBREASND);
    drop LBSEQ LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBNAM LBBLFL
                    VISITNUM VISIT VISITDY EPOCH LBENDTC LBDY LBENDY LBSTAT LBREASND;
    drop MCPROT MCPROTU MCPROTIM_STD IGA IGAU IGG IGM IGD IGE B2MICG KLCFR LLCFR KLCLLCFR
         IGGU IGMU IGDU IGEU B2MICGU KLCFRU LLCFRU KLCLLCFRU LBDAT:;
run;

/* Form Local Efficacy Lab Results - Urinalysis */
data LB_1b;
    set LB_ONC_005;
    attrib &&&domain._varatt_;
    STUDYID = strip(PROJECT);
    DOMAIN  = "&domain";
    USUBJID = catx("-",PROJECT,SUBJECT);
    LBSPID  = catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME), put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    LBCAT   = 'CHEMISTRY';
    %jjqcdate2iso(in_date =LBDAT, in_time=LBTIM, out_date=LBDTC);
    %jjqcdate2iso(in_date =LBENDAT, in_time=LBENTIM, out_date=LBENDTC);
    %LB(where=^missing(MCPROT),         LBTESTCD=MCPROT,  LBORRES=N|MCPROT,      LBORRESU=MCPROTU, LBMETHOD="", LBSPEC  = 'URINE');
    %LB(where=^missing(MCPROTIM_STD),   LBTESTCD=MCPROT,  LBORRES=C|MCPROTIM_STD,LBORRESU="",      LBMETHOD="IMMUNOFIXATION", LBSPEC  = 'URINE');
    call missing(of LBSEQ LBGRPID LBSCAT LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBNAM LBBLFL
                    VISITNUM VISIT VISITDY EPOCH LBDY LBENDY LBSTAT LBREASND);
    drop LBSEQ LBGRPID LBSCAT LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBNAM LBBLFL
                    VISITNUM VISIT VISITDY EPOCH LBDY LBENDY LBSTAT LBREASND;
    drop MCPROT MCPROTIM_STD MCPROTU LBDAT: LBENDAT:;
run;    

/* Form Local Efficacy Lab Results - Ionized Calcium */
data LB_1c;
    set LB_GL_904_3;
    attrib &&&domain._varatt_;
    STUDYID = strip(PROJECT);
    DOMAIN  = "&domain";
    USUBJID = catx("-",PROJECT,SUBJECT);
    LBSPID  = catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME), put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    LBCAT   = 'CHEMISTRY';
    %jjqcdate2iso(in_date =LBDAT, in_time=, out_date=LBDTC);
    %LB(where=^missing(IOCA),   LBTESTCD=CAION,  LBORRES=N|IOCA,  LBORRESU='', LBMETHOD="");
    call missing(of LBSPEC LBSEQ LBGRPID LBSCAT LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBNAM LBBLFL
                    VISITNUM VISIT VISITDY EPOCH LBENDTC LBDY LBENDY LBSTAT LBREASND);
    drop LBSPEC LBSEQ LBGRPID LBSCAT LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBNAM LBBLFL
                    VISITNUM VISIT VISITDY EPOCH LBENDTC LBDY LBENDY LBSTAT LBREASND;    
run;

/* Form Serology Hepatitis */
data LB_1d;
    set LB_MDS_006;
    attrib &&&domain._varatt_;
    STUDYID = strip(PROJECT);
    DOMAIN  = "&domain";
    USUBJID = catx("-",PROJECT,SUBJECT);
    LBSPID  = catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME), put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));    
    if LBPERF_STD = 'N' then do;
        LBSTAT   = 'NOT DONE';
        LBTESTCD = 'LBALL';
        LBTEST   = put(LBTESTCD,$LB_TESTCD.);
        LBREASND = 'SAMPLE NOT COLLECTED';
        call missing(of LBORRES LBORRESU);
        output;
    end;
    %jjqcdate2iso(in_date =LBDAT, in_time=, out_date=LBDTC);
    %LB(where=^missing(HBSAG_3813_STD),   LBTESTCD=HBSAG,  LBORRES=C|HBSAG_3813_STD,  LBORRESU='', LBMETHOD="",LBCAT="IMMUNOLOGY");
    %LB(where=^missing(HBCAB_3163_STD),   LBTESTCD=HBCAB,  LBORRES=C|HBCAB_3163_STD,  LBORRESU='', LBMETHOD="",LBCAT="IMMUNOLOGY",LBSPEC='SERUM');
    %LB(where=^missing(HBVL_STD),         LBTESTCD=HBVVLD,  LBORRES=C|HBVL_STD,  LBORRESU='', LBMETHOD="ASSAY YIELDING QUALITATIVE RESULTS",LBCAT="CHEMISTRY");
    %LB(where=^missing(HCAB_3171_STD),    LBTESTCD=HCAB,  LBORRES=C|HCAB_3171_STD,  LBORRESU='', LBMETHOD="",LBCAT="IMMUNOLOGY");
    %LB(where=^missing(HCVL_STD),         LBTESTCD=HCVVLD,  LBORRES=C|HCVL_STD,  LBORRESU='', LBMETHOD="",LBCAT="CHEMISTRY");

    call missing(of LBSEQ LBGRPID LBSCAT LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBNAM LBBLFL
                    VISITNUM VISIT VISITDY EPOCH LBENDTC LBDY LBENDY);
    drop LBSEQ LBGRPID LBSCAT LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBNAM LBBLFL
                    VISITNUM VISIT VISITDY EPOCH LBENDTC LBDY LBENDY;    
    drop HBSAG_3813_STD HBCAB_3163_STD HBVL_STD HCAB_3171_STD HCVL_STD ;
run;

/* Form  Hematology*/
data LB_1e;
    set LB_GL_903;
    attrib &&&domain._varatt_;
    STUDYID = strip(PROJECT);
    DOMAIN  = "&domain";
    USUBJID = catx("-",PROJECT,SUBJECT);
    LBSPID  = catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME), put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));   
    LBCAT   = 'HEMATOLOGY';
    %jjqcdate2iso(in_date =LBDAT, in_time=, out_date=LBDTC);
    if LBPERF_STD ne 'Y' then do;
        LBSTAT   = 'NOT DONE';
        LBTESTCD = 'LBALL';
        LBTEST   = put(LBTESTCD,$LB_TESTCD.);
        LBREASND = ifc(LBPERF_STD = 'N','SAMPLE NOT COLLECTED','NOT APPLICABLE');
        call missing(of LBORRES LBORRESU);
        output;
    end;    
    call missing(of LBSTAT,LBTESTCD,LBREASND);
    %LB(where=^missing(WBC),    LBTESTCD=WBC,  LBORRES=N|WBC,  LBORRESU='', LBMETHOD="",LBCAT="HEMATOLOGY");
    %LB(where=^missing(NEUT),   LBTESTCD=NEUT,  LBORRES=N|NEUT,  LBORRESU='', LBMETHOD="",LBCAT="HEMATOLOGY");
/*     %LB(where=^missing(RBC),    LBTESTCD=RBC,  LBORRES=N|RBC,  LBORRESU='', LBMETHOD="",LBCAT="HEMATOLOGY");
 */    

 %LB(where=^missing(HGB),    LBTESTCD=HGB,  LBORRES=N|HGB,  LBORRESU='', LBMETHOD="",LBCAT="HEMATOLOGY");
    %LB(where=^missing(PLAT),   LBTESTCD=PLAT,  LBORRES=N|PLAT,  LBORRESU='', LBMETHOD="",LBCAT="HEMATOLOGY");
    call missing(of LBSPEC LBSEQ LBGRPID LBSCAT LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBNAM LBBLFL
                    VISITNUM VISIT VISITDY EPOCH LBENDTC LBDY LBENDY);
    drop LBSPEC LBSEQ LBGRPID LBSCAT LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBNAM LBBLFL
                    VISITNUM VISIT VISITDY EPOCH LBENDTC LBDY LBENDY;  
    drop WBC NEUT RBC HGB PLAT ;
run;

/* Form  Chemistry*/
data LB_1f;
    set LB_GL_904;
    attrib &&&domain._varatt_;
    STUDYID = strip(PROJECT);
    DOMAIN  = "&domain";
    USUBJID = catx("-",PROJECT,SUBJECT);
    LBSPID  = catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME), put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));   
    LBCAT   = 'CHEMISTRY';
    if LBPERF_STD ne 'Y' and ^missing(LBPERF_STD) then do;
        LBSTAT   = 'NOT DONE';
        LBTESTCD = 'LBALL';
        LBTEST   = put(LBTESTCD,$LB_TESTCD.);
        LBREASND = ifc(LBPERF_STD = 'N','SAMPLE NOT COLLECTED','NOT APPLICABLE');
        call missing(of LBORRES LBORRESU);
        output;
    end;    
    %jjqcdate2iso(in_date =LBDAT, in_time=, out_date=LBDTC);
    %LB(where=^missing(SODIUM),   LBTESTCD=SODIUM,  LBORRES=N|SODIUM,  LBORRESU='', LBMETHOD="",LBCAT="CHEMISTRY");
    %LB(where=^missing(K),   LBTESTCD=K,  LBORRES=N|K,  LBORRESU='', LBMETHOD="",LBCAT="CHEMISTRY");
    %LB(where=^missing(CREAT),   LBTESTCD=CREAT,  LBORRES=N|CREAT,  LBORRESU='', LBMETHOD="",LBCAT="CHEMISTRY");
    %LB(where=^missing(GLUC),   LBTESTCD=GLUC,  LBORRES=N|GLUC,  LBORRESU='', LBMETHOD="",LBCAT="CHEMISTRY");
    %LB(where=^missing(BILI),   LBTESTCD=BILI,  LBORRES=N|BILI,  LBORRESU='', LBMETHOD="",LBCAT="CHEMISTRY");
    %LB(where=^missing(AST),   LBTESTCD=AST,  LBORRES=N|AST,  LBORRESU='', LBMETHOD="",LBCAT="CHEMISTRY");
    %LB(where=^missing(ALT),   LBTESTCD=ALT,  LBORRES=N|ALT,  LBORRESU='', LBMETHOD="",LBCAT="CHEMISTRY");
    %LB(where=^missing(ALP),   LBTESTCD=ALP,  LBORRES=N|ALP,  LBORRESU='', LBMETHOD="",LBCAT="CHEMISTRY");
    %LB(where=^missing(URATE),   LBTESTCD=URATE,  LBORRES=N|URATE,  LBORRESU='', LBMETHOD="",LBCAT="CHEMISTRY");
    %LB(where=^missing(CA),   LBTESTCD=CA,  LBORRES=N|CA,  LBORRESU='', LBMETHOD="",LBCAT="CHEMISTRY");
    %LB(where=^missing(ALB),   LBTESTCD=ALB,  LBORRES=N|ALB,  LBORRESU='', LBMETHOD="",LBCAT="CHEMISTRY");
    /* %LB(where=^missing(PHOS),   LBTESTCD=PHOS,  LBORRES=N|PHOS,  LBORRESU='', LBMETHOD="",LBCAT="CHEMISTRY"); */
/* FW Updated on 20Mar2017 due to mirgration */
    call missing(of LBSPEC LBSEQ LBGRPID LBSCAT LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBNAM LBBLFL
                    VISITNUM VISIT VISITDY EPOCH LBENDTC LBDY LBENDY);
    drop LBSPEC LBSEQ LBGRPID LBSCAT LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBNAM LBBLFL
                    VISITNUM VISIT VISITDY EPOCH LBENDTC LBDY LBENDY;  
    drop SODIUM K CREAT GLUC BILI AST ALT ALP URATE CA ALB;
run;

/* Form  Bone Marrow for Morphology*/
data LB_1g;
    set LB_ONC_001;
    attrib &&&domain._varatt_;
    STUDYID = strip(PROJECT);
    DOMAIN  = "&domain";
    USUBJID = catx("-",PROJECT,SUBJECT);
    LBSPID  = catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME), put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));   
    LBCAT   = 'IMMUNOLOGY';
    LBSPEC  = strip(LBSPEC_ONC1_STD);
    if LBPERF_STD ne 'Y' then do;
        LBSTAT   = 'NOT DONE';
        LBTESTCD = 'LBALL';
        LBTEST   = put(LBTESTCD,$LB_TESTCD.);
        LBREASND = ifc(LBPERF_STD = 'N','SAMPLE NOT COLLECTED','NOT APPLICABLE');
        call missing(of LBORRES LBORRESU);
        output;
        call missing(of LBSTAT lbTESTCD, LBREASND);
    end;     
    %jjqcdate2iso(in_date =LBDAT, in_time=, out_date=LBDTC);
    %LB(where=^missing(PLSCECE),  LBTESTCD=PLSCECE,  LBORRES=N|PLSCECE,  LBORRESU=PLSCECEU, LBMETHOD="MICROSCOPY",LBSPEC=LBSPEC_ONC1_STD, LBCAT="IMMUNOLOGY");
    %LB(where=^missing(CELLULP),  LBTESTCD=CELLULTY,  LBORRES=N|CELLULP,  LBORRESU=CELLULPU, 
              LBMETHOD="MICROSCOPIC EXAMINATION YIELDING PERCENTAGE/FRACTION RESULTS",LBSPEC=LBSPEC_ONC1_STD, LBCAT="IMMUNOLOGY");
    %LB(where=^missing(CELLULTY),  LBTESTCD=CELLULTY,  LBORRES=C|CELLULTY,  LBORRESU='', LBSPEC=LBSPEC_ONC1_STD, 
              LBMETHOD="MICROSCOPIC EXAMINATION YIELDING DESCRIPTIVE RESULTS",LBCAT="IMMUNOLOGY");
    call missing(of LBSEQ LBGRPID LBSCAT LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBNAM LBBLFL
                    VISITNUM VISIT VISITDY EPOCH LBENDTC LBDY LBENDY);
    drop LBSEQ LBGRPID LBSCAT LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBSTNRC LBNRIND LBNAM LBBLFL
                    VISITNUM VISIT VISITDY EPOCH LBENDTC LBDY LBENDY ;      
    drop PLSCECE PLSCECEU CELLULP CELLULPU CELLULTY;
run;

******************************* Mapping LB Original related results *************************************************;
/* Mapping LBORRES and LBNRIND from  raw.lab*/
proc format;
    value $analytename(default=200)  
                        "WBC"    = "Leukocytes"
                        "NEUT"   = "Neutrophils"
                        "RBC"    = "Erythrocytes"
                        "HGB"    = "Hemoglobin"
                        "PLAT"   = "Platelets"
                        "SODIUM" = "Sodium"
                        "K"      = "Potassium"
                        "CREAT" = "Creatinine"
                        "GLUC"   = "Glucose"
                        "BILI"   = "Bilirubin"
                        "AST"    = "Aspartate Aminotransferase"
                        "ALT"    = "Alanine Aminotransferase"
                        "ALP"    = "Alkaline Phosphatase"
                        "URATE"  = "Urate OR Uric Acid"
                        "CA"     = "Calcium"
                        "ALB"    = "Albumin"
                        'CAION'  = 'Ionized Calcium'
                        "PHOS"   = "Phosphate OR Inorganic Phosphate OR Phosphorus"
                        ;
run;

data LB_1_cef1;
    set LB_1c LB_1e LB_1f;
    analytename = put(LBTESTCD,$analytename.);
    keep sitenumber subject INSTANCENAME foldername STUDYID DOMAIN USUBJID LBSPID lbTESTCD lbTEST LBCAT LBORRES 
         LBORRESU LBMETHOD LBDTC analytename LBSTAT LBREASND ;
run;

%jjqcgfname(fname=SRC2ORG, type=xls);
proc import datafile="&SPECPATH.&fname..xls" /* SRC20RG for standard LBORRESU */
    out=SRC2ORG(drop=UNITCODE UNITDESC ) dbms=xls replace;
    sheet="SRC2ORG_2016_03";
    getnames=yes;
    datarow=2;
    guessingrows=32767;
run;

proc sql;
    create table LB1_cef_2 as 
    select a.*, 
            put(b.lablow,best. -l) as LBORNRLO, 
            put(b.labhigh,best. -l) as LBORNRHI,b.labunits, 
            case when coalescec(c.LBORRESU,b.labunits) ='N/A' then ''
                 when coalescec(c.LBORRESU,b.labunits) ='INR' then ''
                 else coalescec(c.LBORRESU,b.labunits) end as LBORRESU length=20, upcase(b.labname) as LBNAM length=80
    from LB_1_cef1(drop=LBORRESU) as a 
            left join raw.lab as b 
                on a.subject=b.subject and a.INSTANCENAME=b.INSTANCENAME and a.foldername=b.foldername and a.analytename=b.analytename
            left join SRC2ORG as c 
                on b.labunits=c.SRCU;
quit;


******************************* Mapping LB Standard related results *************************************************;
data LB_2;
    set LB_1a LB_1b LB_1d LB1_cef_2 LB_1g;
    keep sitenumber subject INSTANCENAME foldername STUDYID DOMAIN USUBJID LBSPID LBTESTCD LBTEST LBCAT LBORRES LBSPEC 
         LBORRESU LBMETHOD LBDTC analytename LBORNRHI LBORNRLO LBSTAT LBREASND LBENDTC LBGRPID LBSCAT LBNAM
         LBIMFI1 LBIMFI2 LBIMFI3 LBIMFI4 LBIMFI5 LBIMFI6 LBIMFI7 LBIMFI8 LBIMFI9 LBIMFI10 LBIMFI11 LBIMFI12
         LBIMFI13 LBIMFI14 LBIMFI15 LBIMFI16 LBIMFI17 LBCLARIF;    
run;

%jjqcgfname(fname=LABDICT, type=xls);

proc import datafile="&SPECPATH.&fname..xls"
    out=ludwig(drop=LBTEST) dbms=xls replace;
    sheet="LABDICT";
    getnames=yes;
    datarow=2;
    guessingrows=32767;
run;

proc sql;
    create table LB_3 as 
    select a.* ,b.SICFACT, b.LBSTRESU, b.TESTTYPE
    from LB_2 as a left join ludwig as b 
    on a.LBTESTCD=b.LBTESTCD and a.LBCAT=b.LBCAT and a.LBSPEC=b.LBSPEC and a.LBMETHOD=b.LBMETHOD and a.LBORRESU=b.LBORRESU;
quit;

data lb_4;
    set LB_3;
    length lbstnrc $200;
    if TESTTYPE = 'CONTINUOUS' then do;
        if ^missing(input(LBORRES,??best.)) and ^missing(SICFACT) then  LBSTRESN = input(LBORRES,??best.)*SICFACT;
        if missing(LBSTRESN) then LBSTRESC=LBORRES; else LBSTRESC = put(LBSTRESN,best. -l);
        LBSTNRC = '';
    end;
    else if TESTTYPE = 'DISCRETE' then do;
        LBSTRESC = upcase(strip(LBORRES));
    end;
    if ^missing(input(LBORNRHI,??best.)) and ^missing(SICFACT) then LBSTNRHI = round(input(LBORNRHI,??best.)*SICFACT,0.0001);
    if ^missing(input(LBORNRLO,??best.)) and ^missing(SICFACT) then LBSTNRLO = round(input(LBORNRLO,??best.)*SICFACT,0.0001);
    if prxmatch('/(\-)?(\d+)(\.)?(\d+)?/',cats(LBORRES)) and not prxmatch('/(>|<|=)/',cats(LBORRES))
    and not prxmatch('/(\d+)\-(\d+)/', cats(LBORRES)) and LBSTRESN=. and SICFACT^=. and index(lborres,'-')>1 then do;
            LBSTRESN=.;
            a=round((input(scan(strip(lborres),1,'-'),best.)*sicfact),0.0001);
            b=round((input(scan(strip(lborres),2,'-'),best.)*sicfact),0.0001);
            LBSTRESC=catx("-",a,b);
    end;
    if prxmatch('/(\-)?(\d+)(\.)?(\d+)?/',cats(LBORRES)) and not prxmatch('/(>|<|=)/',cats(LBORRES))
        and LBSTRESN=. and SICFACT^=. and index(lborres,'-')<=1 then do;
        LBSTRESN=round((input(LBORRES,best.)*SICFACT),0.0001);
        LBSTRESC=cats(LBSTRESN);
    end;
    if prxmatch('/(\-)?(\d+)(\.)?(\d+)?/',cats(LBORRES)) and prxmatch('/(>|<|=)/',cats(LBORRES))
        and LBSTRESN=. and SICFACT^=. and index(lborres,'-')<=1 then do;
        col=substr(lborres,1,1);
        col2=substr(lborres,2);
        LBSTRESN_=round((input(col2,best.)*SICFACT),0.0001);
        LBSTRESC=strip(col)||cats(LBSTRESN_);
    end;
    if prxmatch('/(\-)?(\d+)(\.)?(\d+)?/',cats(LBORRES)) and prxmatch('/(\d+)\-(\d+)/', cats(LBORRES))
        and LBSTRESN=. and SICFACT^=. then do;
        col3=scan(lborres,1,'-');
        col4=scan(lborres,2,'-');
        LBSTRESN_1=round((input(col3,best.)*SICFACT),0.0001);
                    LBSTRESN_2=round((input(col4,best.)*SICFACT),0.0001);
        LBSTRESC=cats(lbstresn_1)||'-'||cats(lbstresn_2);
    end;
    if prxmatch('/(\-)?(\d+)(\.)?(\d+)?/',cats(LBORRES)) and LBSTNRLO=. and /*LBORNRLO^="" and */SICFACT^=. then do;
        if prxmatch('/(>|<|=)/',cats(LBORNRLO)) then col4=substr(LBORNRLO,2);
        else if not prxmatch('/(>|<|=)/',cats(LBORNRLO)) then col4=LBORNRLO;
        if not missing(col4) then LBSTNRLO=round((input(col4,best.)*SICFACT),0.0001);
        if prxmatch('/(>|<|=)/',cats(LBORNRHI)) then col5=substr(LBORNRHI,2);
        else if not prxmatch('/(>|<|=)/',cats(LBORNRHI)) then col5=LBORNRHI;
        if not missing(col5) then LBSTNRHI=round((input(col5,best.)*SICFACT),0.0001);
    end;    
run;

proc import
    datafile="&SPECPATH.Lab Data Handling and Derivation documentation Appendix 2.xlsx"
        out=STD1(rename = (a = a_std b = b_std)) dbms=xlsx replace;
        sheet="sheet1";
        getnames=no;
run;

proc sql;
    create table lb_5 as
    select lb.*, std.a_std
    from lb_4 as lb
    left join std1(where=(^missing(b_std))) as std
    on lb.LBORRES = std.b_std;
quit;

data lb_6;
    set lb_5;
    if LBORRES^='' & LBSTRESC='' and TESTTYPE="DISCRETE"  then do;
    if  a_std^='' then LBSTRESC=a_std;
    else if  a_std='' then  LBSTRESC =upcase(LBORRES); end;    
     
   if upcase(lborres) in 
   ('TOO NUMEROUS TO COUNT' 'POSITIVE' 'OCCASIONAL' 'NON-REACTIVE' 'NONE' 'NEGATIVE'
    'MODERATELY POSITIVE' 'BELOW LIMIT OF QUANTIFICATION') then lbstresc=upcase(lborres);
run;

data lb_7;
    set lb_6;
    format _all_;
    informat _all_;
    length lborres_ lbstnrc $200 lbtest $40 LBNRIND $8;
    if prxmatch('/(\-)?(\d+)(\.)?(\d+)?/',cats(LBORRES)) and not prxmatch('/(>|<|=)/',cats(LBORRES)) then do;
        if ^missing(LBORNRLO) and prxmatch('/(\-)?(\d+)(\.)?(\d+)?/',cats(LBORNRLO)) then do;
            if input(LBORRES,best.)<input(prxchange('s/[^\d|^.]//',-1,LBORNRLO),best.) then LBNRIND='LOW';
        end;
        if ^missing(LBORNRLO) and prxmatch('/(\>)/',cats(LBORNRLO)) then do;
            if input(LBORRES,best.)<=input(prxchange('s/[^\d|^.]//',-1,LBORNRLO),best.) then LBNRIND='LOW';
        end;

        if ^missing(LBORNRHI) and prxmatch('/(\-)?(\d+)(\.)?(\d+)?/',cats(LBORNRHI)) then do;
            if input(LBORRES,best.)>input(prxchange('s/[^\d|^.]//',-1,LBORNRHI),best.) then LBNRIND='HIGH';
        end;
        if ^missing(LBORNRHI) and prxmatch('/(\<)/',cats(LBORNRHI)) then do;
            if input(LBORRES,best.)>=input(prxchange('s/[^\d|^.]//',-1,LBORNRHI),best.) then LBNRIND='HIGH';
        end;

        if ^missing(LBORNRLO) and ^missing(LBORNRHI) then do;
            if prxmatch('/(\-)?(\d+)(\.)?(\d+)?/',cats(LBORNRLO))
               and prxmatch('/(\-)?(\d+)(\.)?(\d+)?/',cats(LBORNRHI)) then do;
                if input(prxchange('s/[^\d|^.]//',-1,LBORNRLO),best.)<=input(LBORRES,best.)
                   <=input(prxchange('s/[^\d|^.]//',-1,LBORNRHI),best.) then LBNRIND='NORMAL';
            end;
            if prxmatch('/(\>)/',cats(LBORNRLO)) and prxmatch('/(\-)?(\d+)(\.)?(\d+)?/',cats(LBORNRHI)) then do;
                if input(prxchange('s/[^\d|^.]//',-1,LBORNRLO),best.)<input(LBORRES,best.)
                   <=input(prxchange('s/[^\d|^.]//',-1,LBORNRHI),best.) then LBNRIND='NORMAL';
            end;
            if prxmatch('/(\-)?(\d+)(\.)?(\d+)?/',cats(LBORNRLO)) and prxmatch('/(\<)/',cats(LBORNRHI)) then do;
                if input(prxchange('s/[^\d|^.]//',-1,LBORNRLO),best.)<=input(LBORRES,best.)
                   <input(prxchange('s/[^\d|^.]//',-1,LBORNRHI),best.) then LBNRIND='NORMAL';
            end;
        end;
    end;
    if prxmatch('/(<)/',cats(LBORRES)) then do;
        LBORRES_=prxchange('s/(<)//', -1, LBORRES);
        if ^missing(LBORNRLO) and prxmatch('/(\-)?(\d+)(\.)?(\d+)?/',cats(LBORNRLO)) then do;
            if input(LBORRES_,best.)<=input(prxchange('s/[^\d|^.]//',-1,LBORNRLO),best.) then LBNRIND='LOW';
        end;
        if ^missing(LBORNRLO) and prxmatch('/(\<)/',cats(LBORNRLO)) then do;
            if input(LBORRES_,best.)<=input(prxchange('s/[^\d|^.]//',-1,LBORNRLO),best.) then LBNRIND='LOW';
        end;
    end;
    if prxmatch('/(>)/',cats(LBORRES)) then do;
        LBORRES_=prxchange('s/(>)//', -1, LBORRES);
        if ^missing(LBORNRHI) and prxmatch('/(\-)?(\d+)(\.)?(\d+)?/',cats(LBORNRHI)) then do;
            if input(LBORRES_,best.)>input(prxchange('s/[^\d|^.]//',-1,LBORNRHI),best.) then LBNRIND='HIGHT';
        end;
        if ^missing(LBORNRHI) and prxmatch('/(\>)/',cats(LBORNRHI)) then do;
            if input(LBORRES_,best.)>=input(prxchange('s/[^\d|^.]//',-1,LBORNRHI),best.) then LBNRIND='HIGH';
        end;
    end;

    if not missing(a) then do;
        if a>input(prxchange('s/[^\d|^.]//',-1,LBORNRHI),best.)>. then LBNRIND='HIGH';
        if .<b<input(prxchange('s/[^\d|^.]//',-1,LBORNRLO),best.) then LBNRIND='LOW';
        if a>input(prxchange('s/[^\d|^.]//',-1,LBORNRLO),best.)>. AND
    .<b<input(prxchange('s/[^\d|^.]//',-1,LBORNRHI),best.) THEN LBNRIND='NORMAL';
    end;

    lbstnrc = "";
    lbTEST=put(lbTESTCD, $&domain._TESTCD.);
    drop a b;

    if not (lborres = "" and lbstat = "");/* delete the missing result */
    lborres = upcase(lborres);

    if ^missing(LBSTRESN) then LBSTRESN = round(LBSTRESN,0.0001);
    if ^missing(LBSTRESN) then LBSTRESC = cats(LBSTRESN);
run;

*------------------- Visit --------------------;
%jjqcvisit(in_data=lb_7, out_data=lb_8, date=, time=);

*------------------- DY --------------------;
%jjqccomdy(in_data=lb_8,out_data=lb_9, in_var=LBDTC, out_var=LBDY);
%jjqccomdy(in_data=lb_9,out_data=lb_10, in_var=LBENDTC, out_var=LBENDY);

*------------------- Epoch --------------------;
%jjqcmepoch(in_data=lb_10,out_data=lb_11, in_date=LBDTC);

*------------------- BLFL --------------------;
%jjqcblfl(in_data=lb_11,out_data=lb_12,DTC=LBDTC,ExtraVar=VISITNUM);

*------------------- LBSEQ --------------------;
%jjqcseq(in_data=lb_12, out_data=lb_13, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =lb_13 );

*------------------- Compare --------------------;
%let GMPXLERR=0;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

/*
data a1;
    set transfer.lb;
run;

data b1;
    set qtrans.lb;
run;

%let where=%str(where find(lbspid,'Serology Hepatitis','i'););
data transfer.lb;
    set a1 ;
    &where;
run;

data qtrans.lb;
    set b1;
    &where;
run;

 */

***********************************SUPPLB*******************************************;
*------------------- Get meta data --------------------;
%let domain=SUPPLB;
%jjqcvaratt(domain=SUPPLB);
proc format;
    value check 1='Y'
                0='N';
run;

*------------------- Mapping --------------------;
%macro supp(where=,QNAM=,QVAL=);
    if ^missing(&where) then do;
        QNAM   = "&QNAM";
        QLABEL = put(QNAM,LB_QL.);
        %if %scan(&QVAL,1,|) = N %then QVAL = put(%scan(&QVAL,2,|),check.);;
        %if %scan(&QVAL,1,|) = C %then QVAL= strip(upcase(%scan(&QVAL,2,|)));;
        output;
    end;
%mend;

data SUPPLB_1;
    set lb_13;
    attrib &&&domain._varatt_;
    RDOMAIN  ="LB";
    IDVAR    ='LBSEQ';
    IDVARVAL =put(LBSEQ,best. -l);
    QEVAL    ='';    
    QORIG    ='CRF';
    if LBTESTCD='MCPROT' and LBMETHOD='IMMUNOFIXATION' and LBCAT='CHEMISTRY' and ^missing(LBORRES) then do;
        %supp(where=LBIMFI1,QNAM=LBIMFI1,QVAL=N|LBIMFI1);
        %supp(where=LBIMFI2,QNAM=LBIMFI2,QVAL=N|LBIMFI2);
        %supp(where=LBIMFI3,QNAM=LBIMFI3,QVAL=N|LBIMFI3);
        %supp(where=LBIMFI4,QNAM=LBIMFI4,QVAL=N|LBIMFI4);
        %supp(where=LBIMFI5,QNAM=LBIMFI5,QVAL=N|LBIMFI5);
        %supp(where=LBIMFI6,QNAM=LBIMFI6,QVAL=N|LBIMFI6);
        %supp(where=LBIMFI7,QNAM=LBIMFI7,QVAL=N|LBIMFI7);
        %supp(where=LBIMFI8,QNAM=LBIMFI8,QVAL=N|LBIMFI8);
        %supp(where=LBIMFI9,QNAM=LBIMFI9,QVAL=N|LBIMFI9);
        %supp(where=LBIMFI10,QNAM=LBIMFI10,QVAL=N|LBIMFI10);
        %supp(where=LBIMFI11,QNAM=LBIMFI11,QVAL=N|LBIMFI11);
        %supp(where=LBIMFI12,QNAM=LBIMFI12,QVAL=N|LBIMFI12);
        %supp(where=LBIMFI13,QNAM=LBIMFI13,QVAL=N|LBIMFI13);
        %supp(where=LBIMFI14,QNAM=LBIMFI14,QVAL=N|LBIMFI14);
        %supp(where=LBIMFI15,QNAM=LBIMFI15,QVAL=N|LBIMFI15);
        %supp(where=LBIMFI16,QNAM=LBIMFI16,QVAL=N|LBIMFI16);
        %supp(where=LBIMFI17,QNAM=LBIMFI17,QVAL=N|LBIMFI17);
    end;
    if LBTESTCD='CELLULTY' and LBMETHOD='MICROSCOPIC EXAMINATION YIELDING DESCRIPTIVE RESULTS' then do;
        %supp(where=LBCLARIF,QNAM=LBCLARIF,QVAL=C|LBCLARIF);
    end;
run;

*------------------- Output --------------------;
%qcoutput(in_data =SUPPLB_1);

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );