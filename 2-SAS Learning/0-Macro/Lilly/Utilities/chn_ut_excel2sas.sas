/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : CHN_UT_EXCEL2SAS.SAS
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : Standard output macro for Lilly China internal use 

DESCRIPTION               : This code is used to read the study metadata.
SOFTWARE/VERSION#         : SAS/Version 9.2
INFRASTRUCTURE            : SDD version 3.4

LIMITED-USE MODULES       : n/a

BROAD-USE MODULES         : n/a
INPUT                     : n/a
OUTPUT                    : n/a
 
VALIDATION LEVEL          : 3
REQUIREMENTS              : n/a
ASSUMPTIONS               : Prior to using this macro, users need to check if
                            the metadata is set up
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: n/a

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: n/a

PARAMETERS:

Name          Type         Default            Description and Valid Values
---------     ------------ ------------------ ----------------------------------

USAGE NOTES:
   Users may call the CHN_UT_EXCEL2SAS macro to read the study metadata. But this macro
   is called by macro output_pre automatically. Users don't need to invoke it
   by themselves.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

%chn_ut_excel2sas(indata=c:\a.xlsx,sheetnm=sheet1,outdata=sas_a);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Xiaofeng Shi        Original version of the code
      
**eoh************************************************************************/

%macro chn_ut_excel2sas(indata=,sheetnm=,outdata=);
proc import out= work.&outdata datafile= "&indata" dbms=excel replace;
     sheet="&sheetnm$"; 
     getnames=yes;
     mixed=no;
     scantext=yes;
     usedate=yes;
     scantime=yes;
     textsize=32767;
run;
%mend chn_ut_excel2sas;
