%macro ut_htmlhead(title=_default_,end=_default_,headtags=_default_);
/*soh***************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME           : ut_htmlhead
CODE TYPE           : Broad-use Module
PROJECT NAME        : N/A
DESCRIPTION         : Writes standard HTML header tags - tags DOCTYPE, HTML, HEAD 
                      and TITLE and HTML ending tags - /BODY and /HTML
SOFTWARE/VERSION#   : SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      : SDD v3.4 and MS Windows
LIMITED-USE MODULES : N/A
BROAD-USE MODULES   : /lillyce/prd/general/bums/macro_library/
                      ut_parmdef, ut_logical
INPUT               : optional title and header tags as defined by parameters 
                      TITLE and HEADTAGS
OUTPUT              : literal text strings output by a PUT statement that create 
                      HTML file start tags: HTML, HEAD, META and style
PROGRAM PURPOSE     : N/A
VALIDATION LEVEL    : 6
REQUIREMENTS        : /lillyce/qa/general/bums/ut_htmlhead/documentation/ut_htmlhead_rd.doc
ASSUMPTIONS         : Must be called inside a data step - this macro generates a 
                      PUT statement.  The current FILE in the data step must be the 
                      html file being created.
--------------------------------------------------------------------------------
BROAD-USE MODULE SPECIFIC INFORMATION:
BROAD-USE MODULE TEMPORARY OBJECT PREFIX: none needed

PARAMETERS:
Name       Type      Default   Description and Valid Values
---------  --------  --------  -------------------------------------------------
TITLE      optional            Title text to insert in title tag
END        required  0         If 1 then the end tags are generated
                               If 0 then the start tags are generated
HEADTAGS   optional            other html header tags to include - use PUT 
                               statement syntax.  These tags will be added to
                               the standard tags this macro automatically
                               generates - inside <head>    </head>.
--------------------------------------------------------------------------------
USAGE NOTES:

  The header tags added when END is false (default) are:

    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
    <HTML>
    <HEAD>
    <META http-equiv="Content-Style-Type" content="text/css">
    <META http-equiv="Content-Type" Content="text/html; charset=ISO-8859-1">
    <title>&title</title>
    the value of the HEADTAGS parameter are inserted here
    <style type="text/css">
    PRE { font-size: 12pt }
    </style></HEAD><BODY>

  When END is true then these tags are added instead:
    </BODY>
    </HTML>    

   This macro defines a CHARSET tag of ISO-8859-1 and as such does not support
   the full Greek alphabet.  The Greek letter mu is supported.
--------------------------------------------------------------------------------
TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION:

  data _null_;
    set input_data end=eof;
    file 'my.html';
    %ut_htmlhead(title=My HTML title)
    put 'other html content ...';
    if eof then %ut_htmlhead(end=yes);
  run;
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

     Author &
Ver# Peer Reviewer    Request #        Broad-Use MODULE History Description
---- ---------------- ---------------- -----------------------------------------
1.0  Gregory Steffens BMRGCS03Apr2005A Original version of the broad-use module
      Srinivasa Gudipati                
1.1  Gregory Steffens BMRMSR21FEB2007B Migration to SAS version 9
      Michael Fredericksen
2.0  Gregory Steffens BMRGCS10JAN2008  Changed macro name in calls to
      Shong Demattos                    ut_parmdef from ut_html_head to
                                        ut_htmlhead
3.0  Craig Hansen     BMRCSH28MAR2011  Update header to reflect code validated
      Shong Demattos                    for SAS v9.2.  Modified header to maintain
                                        compliance with current SOP Code Header.
**eoh**************************************************************************/

%ut_parmdef(title,_pdrequired=0,_pdmacroname=ut_htmlhead,_pdverbose=1)
%ut_parmdef(end,0,_pdrequired=1,_pdmacroname=ut_htmlhead,_pdverbose=1)
%ut_parmdef(headtags,_pdrequired=0,_pdmacroname=ut_htmlhead,_pdverbose=1)
%ut_logical(end)
put
 %*=============================================================================;
 %* Put tags required at the top of an HTML document when END is false;
 %*============================================================================;
 %if ^ &end %then %do;
   '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">' /
   '<HTML>' /
   '<HEAD>' /
   '<META http-equiv="Content-Style-Type" content="text/css">' /
   '<META http-equiv="Content-Type" Content="text/html; charset=ISO-8859-1">' /
   "<title>&title</title>" /
   %if %bquote(&headtags) ^= %then %do;
     &headtags /
   %end;
   '<style type="text/css">' /
   'PRE { font-size: 12pt }' /
   '</style></HEAD><BODY>'
 %end;
 %else %do;
   %*===========================================================================;
   %* Put tags required at the end of an HTML document when END is true;
   %*==========================================================================;
   '</BODY>' /
   '</HTML>' /
 %end;
;
%mend;
