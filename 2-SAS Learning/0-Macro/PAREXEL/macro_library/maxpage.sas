%macro maxpage(in_data=, in_var=page);

%******************************************************************************;
%*                          PAREXEL INTERNATIONAL LTD                          ;
%*                                                                             ;
%* CLIENT:            PAREXEL                                                  ;
%*                                                                             ;
%* PROJECT:           maxpage    macro                                         ;
%*                                                                             ;
%* TIMS CODE:         56981                                                    ;
%*                                                                             ;
%* SOPS FOLLOWED:     1213                                                     ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* PROGRAM NAME:      maxpage.sas                                              ;
%*                                                                             ;
%* PROGRAM LOCATION:  /opt/pxlcommon/stats/macros/sas/code/maxpage/ver002      ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* USER REQUIREMENTS: The macro provides an global macro variable containing   ;
%*                    the maximum number of pages indicated by a page variable ;
%*                    in the input SAS dataset                                 ;
%*                                                                             ;
%* TECHNICAL          N/A                                                      ;
%* SPECIFICATIONS:                                                             ;
%*                                                                             ;
%* EXAMPLE:                                                                    ;
%*    %maxpage(in_data=rin1 , in_var=page)                                     ;
%*                                                                             ;
%* INPUT:             Macro Parameters:                                        ;
%*                        in_data - SAS dataset                                ;
%*                        in_var  - page variable                              ;
%*                                                                             ;
%* OUTPUT:                                                                     ;
%*                        lastpage- global SAS macro variable                  ;
%*                                                                             ;
%* PROGRAMS CALLED:   N/A                                                      ;
%*                                                                             ;
%* ASSUMPTIONS/                                                                ;
%* REFERENCES                                                                  ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* MODIFICATION HISTORY                                                        ;
%*-----------------------------------------------------------------------------;
%* VERSION:           1                                                        ;
%* AUTHOR:            Frank Schuetz (B&P Berlin)                               ;
%* QC BY:             N/A                                                      ;
%*                                                                             ;
%*-----------------------------------------------------------------------------;
%* VERSION:           2                                                        ;
%*                                                                             ;
%* RISK ASSESSMENT                                                             ;
%* Business:          High   [ ]: System has direct impact on the provision of ;
%*                                business critical services either globally   ;
%*                                or at a regional level.                      ;
%*                    Medium [X]: System has direct impact on the provision of ;
%*                                business critical services at a local level  ;
%*                                only.                                        ;
%*                    Low    [ ]: System used to indirectly support the        ;
%*                                provision of a business critical service or  ;
%*                                operation at a global, regional or local     ;
%*                                level.                                       ;
%*                    None   [ ]: System has no impact on the provision of a   ;
%*                                business critical service or operation.      ;
%*                                                                             ;
%* Regulatory:        High   [ ]: System has a direct impact on GxP data and/  ;
%*                                or directly supports a GxP process.          ;
%*                    Medium [X]: System has an indirect impact on GxP data    ;
%*                                and supports a GxP process.                  ;
%*                    Low    [ ]: System has an indirect impact on GxP data or ;
%*                                supports a GxP process.                      ;
%*                    None   [ ]: System is not involved directly or           ;
%*                                indirectly with GxP data or a GxP process.   ;
%*                                                                             ;
%* REASON FOR CHANGE: 1) Validation of program to standards required by        ;
%*                       WSOP 1213.                                            ;
%*                    2) No changes to code required.                          ;
%*                                                                             ;
%* TESTING            Peer code review and review of test output created by    ;
%* METHODOLOGY:       Q:\Programming Steering Committee\SoftwareValidation\    ;
%*                    Software\SASMacros\Pageno\paging3_Val.sas                ;
%*                                                                             ;
%* DEVELOPER:         Frank Schuetz (B&P Berlin)        Date : 11.05.2005      ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* CODE REVIEWER:     Ralf Ludwig   (B&P Berlin)        Date : 18/05/2005      ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* USER:              Ralf Ludwig   (B&P Berlin)        Date : 18/05/2005      ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%******************************************************************************;

%GLOBAL lastpage;

%*;
%* Reset of Variable MAXPAGE;
%*;
%*;
%LET lastpage=1;

%*Sorts input dataset;
%*;
proc sort data=&in_data. out=__temp;
   by &in_var.;
run;

%*;
%* Create Variable MAXPAGE;
%*;
data __temp;
   set __temp;
   by &in_var.;
   if last.&in_var. then call symput("lastpage", put(&in_var., 3.));
run;

%mend maxpage;
