%macro ut_titlstrt(tstartvar=_default_,debug=_default_);
/*soh***************************************************************************
Eli Lilly and Company - Global Statistical Sciences                    
CODE NAME           :  ut_titlstrt  
CODE TYPE           :  Broad-use Module   
PROJECT NAME        : 
DESCRIPTION         :  Determines what the first unused title line number
                       is and returns the value in a macro variable
                       specified by the  tstartvar parameter
SOFTWARE/VERSION#   :  SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      :  SDD v3.4 and Windows 
LIMITED-USE MODULES :  N/A                
BROAD-USE MODULES   :  ut_parmdef, ut_logical
INPUT               :  N/A
OUTPUT              :  N/A 
VALIDATION LEVEL    :  6                  
REQUIREMENTS        :  /lillyce/qa/general/bums/validation_pilot/ut_titlstrt_validation/
                       documentation/ut_titlstrt_sdd_dl.doc                   
ASSUMPTIONS         :  N/A                
--------------------------------------------------------------------------------
BROAD-USE MODULE SPECIFIC INFORMATION:                        
BROAD-USE MODULE TEMPORARY OBJECT PREFIX: N/A                          
                      
  Parameters:
   Name      Type     Default  Description and Valid Values
   --------  -------- -------- -------------------------------------------------
   TSTARTVAR required titlstrt Name of macro variable that is assigned the 
                                first available title line number
   DEBUG     required 0        %logical value specifying whether to turn debug
                                mode on or not
--------------------------------------------------------------------------------
  Usage Notes:
                      
--------------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

    %local titlstrt;
    %titlstrt;
    title&titlstrt "this is the first unused title line";
    title%eval(&titlstrt + 1) "the next unused title line";
    .
    .
    .
    %titlstrt&titlstrt;  to be put at end of macro to clear titles it used

--------------------------------------------------------------------------------
REVISION HISTORY SECTION:                 
                      
        Author &      
  Ver#   Peer Reviewer   Request #        Code History Description
  ----  ---------------  ---------------  ---------------------------------
  1.0   Greg Steffens                     Original version of the broad-use
         John Reese                        module 23Jun2004
  2.0   Greg Steffens    BMRMSR24JUL2007 
  3.0   Craig Hansen     BMRCSH01DEC2010e Updated header to reflect code 
         Keyi Wu                           validated for SAS v9.2.  Modified
                                           header to maintain compliance with
                                           current SOP Code Header.
 **eoh*************************************************************************/
%*=============================================================================;
%* Initialization;
%*=============================================================================;
%ut_parmdef(tstartvar,titlstrt,_pdmacroname=ut_titlstrt)
%ut_parmdef(debug,0,_pdmacroname=ut_titlstrt)
%ut_logical(debug)
%local maxtitle dsid rc;
%let &tstartvar = 1;
%*=============================================================================;
%* Find highest title line number used and add 1 to it;
%*=============================================================================;
%let dsid = %sysfunc(open(sashelp.vtitle (where = (type = 'T')),i));
%if &dsid > 0 %then %do;
  %if &debug %then %put (titlstrt) dsid=&dsid;
  %let &tstartvar = %eval(%sysfunc(attrn(&dsid,nlobsf)) + 1);
  %let rc = %sysfunc(close(&dsid));
  %if &debug %then %do;
    %put (titlstrt) dsid=&dsid close of vtitle view rc=&rc
     &tstartvar=&&&tstartvar;
    proc print data = sashelp.vtitle;
    run;
  %end;
%end;
%else %put UWARNING (titlestart) Unable to open sashelp.vtitle dsid=&dsid;
%*=============================================================================;
%* If the title line number is invalid then set it to 10;
%*=============================================================================;
%if &&&tstartvar < 1 | &&&tstartvar > 10 %then %do;
  %put UWARNING (titlestrt) maximum number of title lines is invalid -
   resetting to 10;
  %let &tstartvar = 10;
%end;
%if &debug %then %put titlstrt macro ending;
%mend ut_titlstrt;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******
<?xml version="1.0" encoding="UTF-8"?>
<process sessionid="1837697:10e18ba3b88:2735" sddversion="3.1" cdvoption="N">
  <parameters hideinvalidparms="N">
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="TSTARTVAR" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="1" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="DEBUG" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="2" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="DSID" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="3" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="RC" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="4" />
  </parameters>
</process>

******PACMAN******************************************PACMAN******/
