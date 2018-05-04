 *************************************************************;
 *** %OS_FVARS MACRO DEFINITION                            ***;
 ***                                                       ***;
 *** FUNCTION:                                             ***;
 ***    Use global macro variables set-up in %def_os macro ***;
 ***    to create further global macro variables for use   ***;
 ***    in all sas programs throughout current study to    ***;
 ***    reference directories on current operating         ***;
 ***    platform                                           ***;
 ***                                                       ***;
 *** MACRO ARGUMENTS:                                      ***;
 ***    mvar     - Global macro variable to create         ***;
 ***    projpath - Directory path (from top level project  ***;
 ***               directory &_proj_pre).                  ***;
 ***               Seperate directory levels with :.       ***;
 ***               example: projpath=data:dm               ***;
 *************************************************************;
 %macro os_fvars (mvar=, projpath=);

         %** SETUP GLOBAL MACRO VARIABLE ***;
         %global &mvar;
         data _null_;
       mvar=upcase("&mvar");
                 %if &projpath= %then %do;
          path="&_projpre"||"&_suffix";
                 %end;
                 %else %do;
          path="&_projpre"||"&_divider"||trim(left(tranwrd("&projpath",":","&_divider")))
             ||"&_suffix";
                 %end;
       call symput(mvar,trim(left(path)));
       put "NOTE: os_fvars macro has set-up the following global macro variable:-";
         put "NOTE: " mvar ": " path;
    run;

 %mend os_fvars;
 