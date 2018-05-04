%MACRO Message(title1=, title2=, title3=, title4=, text1= , text2=, text3=, text4=, text5=,
                by1=, by2=, by3=, by4=, by5=, by6=, by7=, by8=,
                clear=1, flag=_gMsg, RET=_NULL_);


%******************************************************************************;
%*                          PAREXEL INTERNATIONAL LTD                          ;
%*                                                                             ;
%* CLIENT:            PAREXEL                                                  ;
%*                                                                             ;
%* PROJECT:           message macro                                            ;
%*                                                                             ;
%* TIMS CODE:         68372                                                    ;
%*                                                                             ;
%* SOPS FOLLOWED:     1213                                                     ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* PROGRAM NAME:      message.sas                                              ;
%*                                                                             ;
%* PROGRAM LOCATION:  /opt/pxlcommon/stats/macros/sas/code/message/ver002      ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* USER REQUIREMENTS: The macro prints a user defined message to PRINT         ;
%*                    dependent on a flag variable.                            ;
%*                                                                             ;
%* TECHNICAL          If a global SAS macro variable is 1 (TRUE) then          ;
%* SPECIFICATIONS:    the user defined message will be written to PRINT.       ;
%*                    Otherwise nothing will be printed.                       ;
%*                    Dependent on the CLEAR option the flag will be set       ;
%*                    to 0 (FALSE).                                            ;
%*                                                                             ;
%* EXAMPLE:                                                                    ;
%*      %IFempty( )                                                            ;
%*      %message(text1=No adverse events were reported.)                       ;
%*                                                                             ;
%* INPUT:      Macro Parameters:                                               ;
%*                title1-title4   - text for SAS titles                        ;
%*                                  DEFAULT = BLANK (the current title are     ;
%*                                  active)                                    ;
%*                text1-text4     - text for the messages                      ;
%*                                  'BLANK' = a blank row will be written      ;
%*                                  DEFAULT = N/A                              ;
%*                by1-by8         - text for dummy by-variables                ;
%*                                  if BYVAL is used                           ;
%*                                  DEFAULT = BLANK                            ;
%*                clear           - boolean to clear the flag to 0 (FALSE)     ;
%*                                  0 = the flag variable will be kept as it   ;
%*                                  1 = the flag variable will be reseet to    ;
%*                                      0 (FALSE), the next call of the        ;
%*                                      message macro will not result in any   ;
%*                                      output                                 ;
%*                                  DEFAULT = 1                                ;
%*                flag            - name of a global macro variable (without   ;
%*                                  the ampersand!) which refers to a          ;
%*                                  a boolean if the message will be printed.  ;
%*                                  if the global macro                        ;
%*                                  variable does not exist it will be         ;
%*                                  created                                    ;
%*                                  &_gMsg = 0 dataset is not empty            ;
%*                                  &_gMsg = 1 dataset is empty                ;
%*                                  Default = _gMsg                            ;
%*                                  Default (&_gMsg) = 0                       ;
%*                                                                             ;
%* OUTPUT:                                                                     ;
%*                        RET     - name of a global macro variable (without   ;
%*                                  the ampersand!) which refers to the        ;
%*                                  return code for error handling             ;
%*                                  if the global macro                        ;
%*                                  variable does not exist it will be         ;
%*                                  created                                    ;
%*                                  &RET = 0 no error occurred                 ;
%*                                  &RET = 1 an error occurred                 ;
%*                                  Default = _NULL_                           ;
%*                                                                             ;
%* PROGRAMS CALLED:   N/A                                                      ;
%*                                                                             ;
%* ASSUMPTIONS/       The macro uses a flag variable created by the            ;
%* REFERENCES         IFempty macro.                                           ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* MODIFICATION HISTORY                                                        ;
%*-----------------------------------------------------------------------------;
%* VERSION:           1                                                        ;
%* AUTHOR:            Ralf Ludwig (B&P Berlin)                                 ;
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
%*                    Software\SASMacros\Pageno\message_Val.sas                ;
%*                                                                             ;
%* DEVELOPER:         Ralf Ludwig (B&P Berlin)          Date : N/A             ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* CODE REVIEWER:     Frank Schuetz (B&P Berlin)        Date : 18/05/2005      ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* USER:              Frank Schuetz (B&P Berlin)        Date : 18/05/2005      ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%******************************************************************************;

   %*** return value for error handling ***;
   %IF %UPCASE(&Ret.) EQ %STR(RET) %THEN %DO;
      %PUT %STR(ER)%STR(ROR:) (IFempty): Names conflict - MACRO parameter RET must not named as RET.;
      %GOTO Ende;
   %END;

   %GLOBAL &Ret.;
   %LET &Ret.=1;

   %*** return value for error handling ***;
   %IF %UPCASE(&flag.) EQ %STR(FLAG) %THEN %DO;
      %PUT %STR(ER)%STR(ROR:) (IFempty): Names conflict - MACRO parameter FLAG must not named as FLAG.;
      %GOTO Ende;
   %END;

   %GLOBAL &flag.;
   %*IF %STR(&&&flag)=%STR( ) %THEN %LET &flag=0;

   %LOCAL title1 title2 title3 title4 text1 text2 text3 text4 text5 ;

   %IF &&&flag %THEN %DO;
      %IF %QUOTE(&title1) NE %STR( ) %THEN %DO; TITLE1 "&title1"; %END;
      %IF %QUOTE(&title2) NE %STR( ) %THEN %DO; TITLE2 "&title2"; %END;
      %IF %QUOTE(&title3) NE %STR( ) %THEN %DO; TITLE3 "&title3"; %END;
      %IF %QUOTE(&title4) NE %STR( ) %THEN %DO; TITLE4 "&title4"; %END;

      DATA _Message_;
             LENGTH text $200;
             sBY1="&by1"; sBY2="&by2"; sBY3="&by3"; sBY4="&by4"; sBY5="&by5"; sBY6="&by6"; sBY7="&by7"; sBY8="&by8";

             IF TRANWRD(" &text1", "BLANK", " ") NE " " THEN DO; text=" &text1"; OUTPUT; END;
             IF " &text1" = " BLANK" THEN DO; text=" "; OUTPUT; END;
             IF TRANWRD(" &text2", "BLANK", " ") NE " " THEN DO; text=" &text2"; OUTPUT; END;
             IF " &text2" = " BLANK" THEN DO; text=" "; OUTPUT; END;
             IF TRANWRD(" &text3", "BLANK", " ") NE " " THEN DO; text=" &text3"; OUTPUT; END;
             IF " &text3" = " BLANK" THEN DO; text=" "; OUTPUT; END;
             IF TRANWRD(" &text4", "BLANK", " ") NE " " THEN DO; text=" &text4"; OUTPUT; END;
             IF " &text4" = " BLANK" THEN DO; text=" "; OUTPUT; END;
             IF TRANWRD(" &text5", "BLANK", " ") NE " " THEN DO; text=" &text5"; OUTPUT; END;
             IF " &text5" = " BLANK" THEN DO; text=" "; OUTPUT; END;
      RUN;

      OPTIONS NOBYLINE;
      PROC REPORT DATA=_Message_ NOWD ;
         BY sBY1 sBY2 sBY3 sBY4 sBY5 sBY6 sBY7 sBY8 ;
         COLUMN text;
         DEFINE text    / ORDER=DATA " " WIDTH=90 FLOW;
      RUN;
      QUIT;
      OPTIONS BYLINE;
   %END;

   %IF &clear %THEN %LET &flag = 0;


   %LET &Ret.=0;

   %Ende:
   %*;
   %*End;
   %*;


%MEND message;
