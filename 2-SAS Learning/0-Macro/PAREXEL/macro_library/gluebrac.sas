%macro gluebrac ( var= , bracket='(', drop=1, tmpvar=_glue_in );
%******************************************************************************;
%*                          PAREXEL INTERNATIONAL LTD                          ;
%*                                                                             ;
%* CLIENT:            PAREXEL                                                  ;
%*                                                                             ;
%* PROJECT:           Macro to move leading bracket (or other specified text)  ;
%*                    to be after any spaces between the bracket and the next  ;
%*                    non-space character                                      ;
%*                                                                             ;
%* TIMS CODE:         68372                                                    ;
%*                                                                             ;
%* SOPS FOLLOWED:     1213                                                     ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* PROGRAM NAME:      GLUEBRAC.SAS                                             ;
%*                                                                             ;
%* PROGRAM LOCATION:  /opt/pxlcommon/stats/macros/sas/code/gluebrac/ver002     ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* USER REQUIREMENTS: If a text variable has a bracket followed by at least one;
%*                     space, followed by a text string, the macro should move ;  
%*                     the bracket to be after the space(s) and just before the;
%*                     text string.                                            ;
%*                                                                             ;
%* TECHNICAL          The macro used the INDEX function to identify the        ;
%* SPECIFICATIONS:     position of the bracket, and then uses the SUBSTR       ;
%*                     function to check if the next character is a space. If  ;
%*                     it is, the space is deleted from this position and moved;
%*                     to before the bracket. If the next character is not a   ;
%*                     space, the macro ends.                                  ;
%*                                                                             ;
%* INPUT:             Macro paramters:                                         ;
%*                      VAR=text variable to be amended                        ;
%*                      BRACKET=character to be seacrhed for (defaults to '(') ;
%*                      DROP=specifies whether the TMPVAR variable created by  ;
%*                           the macro should be dropped (0=No, 1=Yes)         ;
%*                           (defaults to 1)                                   ;
%*                      TMPVAR=variable containing the position of the BRACKET ;
%*                             variable within the VAR variable                ;
%*                             (defaults to _GLUE_IN)                          ;
%*                                                                             ;
%* OUTPUT:            An output dataset with the original VAR variable amended ;
%*                     as required. If requested the TMPVAR variable will also ;            
%*                     be included.                                            ;
%*                                                                             ;
%* PROGRAMS CALLED:   N/A                                                      ;
%*                                                                             ;
%* ASSUMPTIONS/       This macro must be called inside a datastep and not in   ;
%* REFERENCES:        open code                                                ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* MODIFICATION HISTORY                                                        ;
%*-----------------------------------------------------------------------------;
%* VERSION:           1                                                        ;
%* AUTHOR:            Alex Karpov (Moscow)                                     ;
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
%*                    Medium [ ]: System has an indirect impact on GxP data    ;
%*                                and supports a GxP process.                  ;
%*                    Low    [X]: System has an indirect impact on GxP data or ;
%*                                supports a GxP process.                      ;
%*                    None   [ ]: System is not involved directly or           ;
%*                                indirectly with GxP data or a GxP process.   ;
%*                                                                             ;
%* REASON FOR CHANGE: 1) Validation of program to standards required by        ;
%*                       WSOP 1213.                                            ;
%*                    2) Code itself not amended from Version 1                ;
%*                                                                             ;
%* TESTING            Peer code review and review of the test output from      ;
%* METHODOLOGY:       GLUEBRAC_VAL.SAS                                         ;
%*                                                                             ;
%* DEVELOPER:         Alex Karpov (Moscow)              Date : 5 November 2004 ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* CODE REVIEWER:     Simon Gillis (Sheffield)          Date : 3 March 2005    ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* USER:              Simon Gillis (Sheffield)          Date : 3 March 2005    ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%******************************************************************************;
%* Tested on UNIX platform:-                                                   ;
%*                                                                             ;
%* USER:              Dan Higgins                       Date : 14/07/2005      ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%******************************************************************************;

 &tmpvar.=index(&var.,&bracket.) ;
 if &tmpvar. gt 0 then do while ( ((&tmpvar.+1) lt length(&var.)) and (substr(&var.,&tmpvar.+1,1) eq ' ')) ;
  substr(&var.,&tmpvar.,1) = ' ' ;
  &tmpvar. = &tmpvar. + 1 ;
  substr(&var.,&tmpvar.,1) = &bracket. ;
 end ;
 %if &drop. eq 1 %then %do;
  drop &tmpvar. ;
 %end;

%mend gluebrac ;
