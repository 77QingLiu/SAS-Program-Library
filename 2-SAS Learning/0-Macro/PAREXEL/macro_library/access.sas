%macro access(study=, user=);
     %******************************************************************************;
     %*                          PAREXEL INTERNATIONAL                              ;
     %*                                                                             ;
     %* CLIENT:            PAREXEL                                                  ;
     %*                                                                             ;
     %* PROJECT:           UNIX Study access                                        ;
     %*                                                                             ;
     %* TIMS CODE:         3000                                                     ;
     %*                                                                             ;
     %* SOPS FOLLOWED:     1213                                                     ;
     %*                                                                             ;
     %******************************************************************************;
     %*                                                                             ;
     %* PROGRAM NAME:      ACCESS.SAS                                               ;
     %*                                                                             ;
     %* PROGRAM LOCATION:  Q:\Programming Steering Committee\...                    ;
     %*                      ...SAS platform implementation\StandardProgs           ;
     %*                                                                             ;
     %******************************************************************************;
     %*                                                                             ;
     %* USER REQUIREMENTS: (1) Query the Unix groups management file and retrieve   ;
     %*                        the list of usernames and study groups to be         ;
     %*                        reported in an easily read format.                   ;
     %*                                                                             ;
     %* TECHNICAL          Refer to comments in code.                               ;
     %* SPECIFICATIONS:                                                             ;
     %*                                                                             ;
     %* INPUT:             Macro parameter definition:                              ;
     %*                                                                             ;
     %*                 STUDY    =   Name of the study area on the UNIX system.     ;
     %*                              N.B. This parameter is optional, and not       ;
     %*                              specifying it lists all study areas.           ;
     %*                                                                             ;
     %*                 USER     =   User name of a user to query.                  ;
     %*                              N.B. This parameter is options, and not        ;
     %*                              specifying it lists all users.                 ;
     %*                                                                             ;
     %* OUTPUT:            Summary reports are written to the SAS Output window.    ;
     %*                                                                             ;
     %* PROGRAMS CALLED:   None.                                                    ;
     %*                                                                             ;
     %* ASSUMPTIONS/       Any specified values are valid.                          ;
     %* REFERENCES:                                                                 ;
     %*                                                                             ;
     %******************************************************************************;
     %*                                                                             ;
     %* MODIFICATION HISTORY                                                        ;
     %*-----------------------------------------------------------------------------;
     %* VERSION:           1                                                        ;
     %*                                                                             ;
     %* RISK ASSESSMENT                                                             ;
     %* Business:          High   [ ]: System has direct impact on the provision of ;
     %*                                business critical services either globally   ;
     %*                                or at a regional level.                      ;
     %*                    Medium [ ]: System has direct impact on the provision of ;
     %*                                business critical services at a local level  ;
     %*                                only.                                        ;
     %*                    Low    [X]: System used to indirectly support the        ;
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
     %*                    Low    [ ]: System has an indirect impact on GxP data or ;
     %*                                supports a GxP process.                      ;
     %*                    None   [X]: System is not involved directly or           ;
     %*                                indirectly with GxP data or a GxP process.   ;
     %*                                                                             ;
     %* TESTING            Peer code review and review of the test output           ;
     %* METHODOLOGY:                                                                ;
     %*                                                                             ;
     %* DEVELOPER:         MICHAEL CARTWRIGHT                Date : 12-JUL-2006     ;
     %*                                                                             ;
     %* SIGNATURE:         ................................  Date : ............... ;
     %*                                                                             ;
     %* CODE REVIEWER:     MIKE BRADBURN                     Date : 12-JUL-2006     ;
     %*                                                                             ;
     %* SIGNATURE:         ................................  Date : ............... ;
     %*                                                                             ;
     %* USER:              MIKE BRADBURN                     Date : 12-JUL-2006     ;
     %*                                                                             ;
     %* SIGNATURE:         ................................  Date : ............... ;
     %*                                                                             ;
     %******************************************************************************;

     *  Check for any specified input parameters.                                   *;
     *  If input parameters have been specified, then create local macro variables  *;
     *  which are used to filter the final report at the end.                       *;
     %local _stud _usr _opts;
     %if %length(&study) > 0 %then %let _stud = where=(upcase(study)=upcase("&study"));
     %if %length(&user) > 0 %then %let _usr = where=(upcase(user)=upcase("&user"));


     *  Read in the UNIX group file.  *;
     data _acc1;
          infile "/etc/group" delimiter="," dsd missover firstobs=1;
          informat %do i = 1 %to 1000; _col&i %end; $100.;
          input %do i = 1 %to 1000; _col&i $ %end;;
     run;


     *  Break up the initial character string into sub-parts.  *;
     data _acc2 (drop = _col1);
          attrib study label="Study" length=$50.;
          set _acc1;
          length _col1a $20.;
          study = compress(substr(_col1, 1, index(_col1, ":")), ":");
          _col1a = substr(_col1, index(tranwrd(_col1, "::", "##"), ":")+1);
     run;

     proc sort data=_acc2(rename=(_col1a=_col1)) out=_acc3;
          by study;
     run;


     *  Transpose the columns in to rows and keep only populated rows.  *;
     proc transpose data=_acc3 out=_acc4(drop = _name_ where=(col1 ne ""));
          by study;
          var %do i = 1 %to 1000; _col&i %end;;
     run;


     *  Order the columns into a user friendly order, and add labels.  *;
     data _acc5(&_usr);
          format study user;
          attrib user label="User" length=$20.;
          set _acc4 (rename=(col1=user) &_stud);
     run;

     *  Store current date option, then reset to add date to title *;
     data _opt1;
          set sashelp.voption(where=(upcase(optname) = "DATE"));
     run;

     proc sql noprint;
          select setting into :_opts separated by " "
          from _opt1;
     run;
     quit;

     option date;


     *  Print out the output with a suitable header.  *;
     proc print data=_acc5 noobs label;
          var study user;
          %if %length(&study) > 0 and %length(user) > 0 %then %do;
               title "Access to &study for &user";
          %end;
          %else %if %length(&study) > 0 and %length(&user) = 0 %then %do;
               title "Users with access to &study";
          %end;
          %else %if %length(&study) = 0 and %length(&user) > 0 %then %do;
               title "Study access for &user";
          %end;
          %else %do;
               title "Study access for all studies and all users";
          %end;
     run;


     *  Remove all temporary data sets and reset options.  *;
     option &_opts;

     proc datasets nolist lib=work memtype=data;
          delete _opt1 _acc1-_acc5
     run;
     quit;
     title;
%mend access;
