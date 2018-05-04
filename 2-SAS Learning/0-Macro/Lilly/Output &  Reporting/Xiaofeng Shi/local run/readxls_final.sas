/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : READXLS_FINAL.SAS
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
   Users may call the READXLS macro to read the study metadata. But this macro
   is called by macro output_pre automatically. Users don't need to invoke it
   by themselves.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

%readxls;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Xiaofeng Shi        Original version of the code
      Weishan Shi
**eoh************************************************************************/

%macro readxls_final(metadata=);
proc import out= work.loa datafile= "&irpathu.\&prp_proj.\lums\&metadata..xls" dbms=excel replace;
     sheet="loa$"; 
     getnames=yes;
     mixed=no;
     scantext=yes;
     usedate=yes;
     scantime=yes;
     textsize=32767;
run;

data work.loa;
   set work.loa;
   where &analy_pop is not missing;
run;
%mend readxls_final;
