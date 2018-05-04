 %macro pageno (file=, justify=right);

 %******************************************************************************;
 %* PAREXEL INTERNATIONAL LTD ;
 %* ;
 %* CLIENT: PAREXEL ;
 %* ;
 %* PROJECT: Page Numbering Macro ;
 %* ;
 %* TIMS CODE: 68372 ;
 %* ;
 %* SOPS FOLLOWED: 1213 ;
 %* ;
 %******************************************************************************;
 %* ;
 %* PROGRAM NAME: pageno.sas ;
 %* ;
 %* PROGRAM LOCATION: /opt/pxlcommon/stats/macros/sas/code/pageno/ver002 ;
 %* ;
 %******************************************************************************;
 %* ;
 %* USER REQUIREMENTS: Macro to substitute all occurences of string ;
 %* 'Page XXXX of YYYY' (in a text file) with page numbers. ;
 %* XXXX is replaced with the actual page number and YYYY is ;
 %* replaced with the actual number of pages in the file. ;
 %* ;
 %* TECHNICAL The macro reads from and outputs to the text file using ;
 %* SPECIFICATIONS: sas data steps. All occurences of 'Page XXXX of YYYY' ;
 %* are replaced by the data steps. XXXX is replaced with ;
 %* page number starting at 1 and incrementing by 1 for each ;
 %* occurance of 'Page XXXX of YYYY'. YYYY is replaced by ;
 %* the total number of occurences of 'Page XXXX of YYYY' in ;
 %* the file. ;
 %* ;
 %* INPUT: Macro Parameters: ;
 %* FILE - Name of text file to execute macro on. ;
 %* Argument can be either fileref of fully ;
 %* qualified filename. If filename is used it ;
 %* must be quoted. ;
 %* JUSTIFY - <left|center|right> (default=right) ;
 %* Determines the justification of the ;
 %* replaced string relative to the 'template' ;
 %* string as in the following examples: ;
 %* Template string Page XXXX of YYYY ;
 %* Justify=left Page 1 of 13 ;
 %* Justify=center Page 1 of 13 ;
 %* Justify=right Page 1 of 13 ;
 %* ;
 %* OUTPUT: N/A ;
 %* ;
 %* PROGRAMS CALLED: N/A ;
 %* ;
 %* ASSUMPTIONS/ When the original text file is created, each page should ;
 %* REFERENCES contain one occurence of the 'template' string ;
 %* 'Page XXXX of YYYY'. ;
 %* ;
 %******************************************************************************;
 %* ;
 %* MODIFICATION HISTORY ;
 %*-----------------------------------------------------------------------------;
 %* VERSION: 1 ;
 %* AUTHOR: Philip Primak (RTP) ;
 %* QC BY: N/A ;
 %* ;
 %*-----------------------------------------------------------------------------;
 %* VERSION: 2 ;
 %* ;
 %* RISK ASSESSMENT ;
 %* Business: High [ ]: System has direct impact on the provision of ;
 %* business critical services either globally ;
 %* or at a regional level. ;
 %* Medium [X]: System has direct impact on the provision of ;
 %* business critical services at a local level ;
 %* only. ;
 %* Low [ ]: System used to indirectly support the ;
 %* provision of a business critical service or ;
 %* operation at a global, regional or local ;
 %* level. ;
 %* None [ ]: System has no impact on the provision of a ;
 %* business critical service or operation. ;
 %* ;
 %* Regulatory: High [ ]: System has a direct impact on GxP data and/ ;
 %* or directly supports a GxP process. ;
 %* Medium [X]: System has an indirect impact on GxP data ;
 %* and supports a GxP process. ;
 %* Low [ ]: System has an indirect impact on GxP data or ;
 %* supports a GxP process. ;
 %* None [ ]: System is not involved directly or ;
 %* indirectly with GxP data or a GxP process. ;
 %* ;
 %* REASON FOR CHANGE: 1) Validation of program to standards required by ;
 %* WSOP 1213. ;
 %* 2) No changes to code required. ;
 %* ;
 %* TESTING Peer code review and review of test output created by ;
 %* METHODOLOGY: Q:\Programming Steering Committee\SoftwareValidation\ ;
 %* Software\SASMacros\Pageno\Pageno_Val.sas ;
 %* ;
 %* DEVELOPER: Philip Primak (RTP) Date : 06/09/1996 ;
 %* ;
 %* SIGNATURE: ................................ Date : ............... ;
 %* ;
 %* CODE REVIEWER: Dan Higgins Date : 07/03/2005 ;
 %* ;
 %* SIGNATURE: ................................ Date : ............... ;
 %* ;
 %* USER: Dan Higgins Date : 07/03/2005 ;
 %* ;
 %* SIGNATURE: ................................ Date : ............... ;
 %* ;
 %******************************************************************************;
 %* Tested on UNIX platform:- ;
 %* ;
 %* USER: Dan Higgins Date : 19/07/2005 ;
 %* ;
 %* SIGNATURE: ................................ Date : ............... ;
 %* ;
 %******************************************************************************;


 %local numpages;

 %*=========================================================================;
 %* DETERMINE NUMBER OF PAGES IN THE ORIGINAL DOCUMENT. ;
 %*=========================================================================;

 data _null_;
 infile &file length=reclen end=final lrecl=32767;
 input @1 record $varying300. reclen;
 if index(upcase(record),'PAGE XXXX OF YYYY') then pagenum+1;
 if final then call symput('numpages',compress(put(pagenum,8.)));
 run;

 %*=========================================================================;
 %* SUBSTITUTE 'TEMPLATE' NUMBERS WITH THE ACTUAL PAGE NUMBER AND TOTAL ;
 %* NUMBER OF PAGES IN THE DOCUMENT. ;
 %*=========================================================================;

 data _null_;
 infile &file length=reclen sharebuffers lrecl=32767;
 input @1 record $varying300. reclen;
 file &file;
 length blankstr $17 pageword $4 ofword $2;

 if index(upcase(record),'PAGE XXXX OF YYYY') then do;
 pagenum+1;
 digitnum=1+(pagenum>=10)+(pagenum>=100)+(pagenum>=1000);
 startpos=index(upcase(record),'PAGE XXXX OF YYYY');

 if upcase("&justify")='RIGHT' then
 indent=8-digitnum-length("&numpages");
 else if upcase("&justify")='CENTER' then
 indent=int(0.5*(8-digitnum-length("&numpages")));
 else indent=0;

 blankstr=repeat(' ',16);
 pageword=substr(record,startpos,4);
 ofword=substr(record,startpos+10,2);

 put @(startpos) blankstr $17.
 @(startpos+indent) pageword $4.
 @(startpos+indent+5) pagenum 4. -l
 @(startpos+indent+5+digitnum+1) ofword $2.
 @(startpos+indent+5+digitnum+1+3) "&numpages";
 end;
 run;

 %mend;