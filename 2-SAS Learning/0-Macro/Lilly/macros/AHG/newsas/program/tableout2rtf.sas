/**soh******************************************************************************************************************
Eli Lilly and Company (required)- GSS
CODE NAME (required)              : home/lillyce/prd/ly2189265/h9x_cr_gbdk/intrm1/programs_nonsdd/author_component_modules/tableout2rtf.sas
PROJECT NAME (required)           : H9X-CR-GBDK | LY2189265
DESCRIPTION (required)            : Generate rtf output from text output and have additional
                                    features for portrait and landscape settings of reports and for alignments of titles.
SPECIFICATIONS(required)          : N/A
VALIDATION TYPE (required)        : Peer Review
INDEPENDENT REPLICATION (required): N/A
ORIGINAL CODE (required)          : This is the original code
COMPONENT CODE MODULES            : 
SOFTWARE/VERSION# (required)      : SAS/Version 9.2
INFRASTRUCTURE                    : 
DATA INPUT                        : 
OUTPUT                            : 
SPECIAL INSTRUCTIONS              : 
------------------------------------------------------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------------------------------------------------------
DOCUMENTATION AND REVISION HISTORY SECTION (required):

     Author &
Ver# Validator        Code History Description
---- ---------------- -----------------------------------------------------------------------------------------------------
1.0  Xiang Liu        Original version of the code
     Jiashu Li 
     Bin Zhang 
**eoh*******************************************************************************************************************/

%macro tableout2rtf(
  in = ,
  out = ,  
  center = ,      
  ps = %sysfunc(getoption(ps)),   
  orient = L,
  outname = ,
  maskttl1 = N,
  strclm = 2
);                    

  %put  --- now executing macro out2rtf ---;
  %local ls pblines;

  %*============================================================================;
  %* adjust the parameter settings if necessary.                                ;
  %*============================================================================;

  %if %upcase(&orient) = P %then %let orient = P;
  %else %let orient = L;

  %** get linesize;
  %LET ls = %sysfunc(getoption(ls)); 
  %put ls = &ls;

  filename tofile temp; %* define a temporary file to write to before the final output;

  filename tofile1 temp; 

  %*============================================================================;
  %* Find the page break characters                                              ;
  %*============================================================================;

  /** read in file and write it back out with special rtf   **
  ** tags protected                                        **
  ** dataset pbs will have one record per line that has a **
  ** page break as the first character                     **/

  data pbs (keep = n);
    infile &in lrecl = 16383 recfm = F length = len;
    file tofile lrecl = 32767 recfm = N ;
    retain n 1;
    input @1 b $char1. @;
    do i = 1 to len;
      input @i b $char1. @;
      %** change all \ to \\ and pagebreaks to null chars **;
      if b in ('\' '{' '}') then put '\' @;
      if b = '0C'x then output;
      else put b $char1. @;
      %** new line found **;
      if b = '0A'x then n + 1;
    end;
    put;
  run;

  data _null_;
    infile tofile lrecl = 16383;
    file tofile1 lrecl = 32767; 
    input;
    %if %length(&outname) > 0 %then 
      %do;
        %if &strclm = 3 %then 
          %do;
            if index(_infile_,'Output Location' ) > 0 then _infile_ = "  Output Location: &outname";
          %end;
        %else 
          %do; 
            if index(_infile_,'Output Location' ) > 0 then _infile_ = " Output Location: &outname";
          %end;
      %end;
    put _infile_;
  run; 


  /** Generate a list of page break line numbers **/
  %let pblines = ;
  proc sql noprint;
    select n into :pblines separated by ' ' from pbs;
  quit;

  /** actually write rtf **/;
  data _null_;
    retain l pagebreak maskbreak 0;
    retain 
    MASKPREF '\fs12{\field\fldlock{\*\fldinst comments '
             MASKSUFF '}{\fldrslt}}\fs0 '
             NORMPREF '\par \pard\plain \b\f11\fs16 '
             PBPREF   '\par \pard\plain \b\f11\fs16\page '
/*      maskpref '\fs12{\field\fldlock{\*\fldinst comments '*/
/*      masksuff '}{\fldrslt}}\fs0'*/
/*      normpref '\par \pard\plain \s34\sl-179\slmult0\nowidctlpar \b0\hich\af0\dbch\af13\loch\f11\fs16 '*/
/*      pbpref   '\par \pard\plain \s34\sl-179\slmult0\nowidctlpar \b0\hich\af0\dbch\af13\loch\f11\fs16\page'*/
    ;
    infile tofile1 lrecl = 1000 end = last;
    file &out lrecl = 1000 ;   
   
    /** read the line **/;
    input;

    /** write rtf file header including margins and fonts **/;
    if _n_ = 1 then 
      do;
        put
          '{\rtf1\ansi\deff4\deflang1033' /
          '{\fonttbl {\f4\froman\fcharset134\fprq2 Arial;}' /
          '          {\f5\fswiss\fcharset134\fprq2 Arial;}'           /
          '          {\f11\fmodern\fcharset134\fprq1 Courier New;}'   /
          '          {\f14\fmodern\fcharset134\fprq2 Modern;}}'     /
          '{\stylesheet{\sb14\sa144\sl-300\slmult0\nowidctlpar \f4 \snext0 Normal;}' 
          '{\s27\fi-1944\li1944\sb240\sa120\sl259\slmult0\keep\keepn\nowidctlpar'
          ' \b\f5\fs22 \sbasedon43\snext0 Tbl Title Cont;}'  
          '{\s34\sl-179\slmult0\nowidctlpar \b\hich\af0\dbch\af13\loch\f11\fs16 '
          '\sbasedon41\snext34 md_SAS Tbl Entry;}'  
          '{\s41\sl259\slmult0 \keep\keepn\nowidctlpar \f4\fs20 '
          '\sbasedon0\snext41 md_Tbl Entry;}'                         
          '{\s43\fi-1944\li1944\sb240\sa120\sl259\slmult0\keep\keepn\nowidctlpar '
          '\b\f5\fs22 \sbasedon0\snext0 Tbl Title;}} ' @
        ;
        %if %upcase(&orient) = L %then 
          %do; 
            %*Landscape - note that for L, margins are L = 1.5, R,T,B = 1.0 *;
            %*            header = 1.25 in, footer = .75 in.                *;
            put
              '\paperw15840\paperh12240\margl1440\margr1440\margt1440\margb1440\gutter0 '
              /*
              '\paperw15840\paperh12240\margl1440\margr1440\margt2160\margb1440\gutter0 '
              */
              '\widowctrl\ftnbj \sectd\lndscpsxn\headery1800\footery1080\linex0 \fs0 ' @
            ;
          %end;
        %else 
          %do;  
            %*Portrait - note that for P, margins are L=1.5, R,T,B=1.0 *;
            %*            header=0.5 in, footer=0.5 in                 *;
            put
              '\paperw12240\paperh15840\margl2160\margr1440\margt1440\margb1440\gutter0 '
              '\widowctrl\ftnbj \sectd\headery720\footery720 \linex0 \fs0 ' @
            ;
          %end;
        L = 0;
      end; %* _n_ = 1;    
    else 
      do; %* _n_ > 1, flag pagebreaks;
        %if %length(&pblines) = 0 %then 
          %do;
            if mod(_n_, &ps) = 1 then 
              do;
                pagebreak = 1;
                L = 0;
              end;
            else pagebreak = 0;
          %end;
        %else 
          %do;
            if _n_ in (&pblines) then 
              do;
                pagebreak = 1;
                L = 0;
              end;
            else pagebreak = 0;
          %end;
      end; %* _n_ > 1, flag pagebreaks;
      L + 1;

    %if %upcase(&maskttl1) = Y %then 
      %do;  %* handle masking;
        if index(upcase(_infile_),'PRODUCTION DATA - PRODUCTION MODE') > 0 then 
          do;
            if pagebreak then 
              do;
                put '\par \pard\plain' @;
                maskbreak = 1;
                pagebreak = 0;
              end;
            put maskpref _infile_ masksuff;
          end;
        %if &center ^= %then 
          %do; %*handle centering;
            else 
              do;
                if L in (&center) then leading = int((&ls - length(_infile_)) / 2);
                else leading = 0;
                if maskbreak or pagebreak then 
                  do;
                    put pbpref +leading _infile_ ;
                    maskbreak = 0;
                  end;
                else put normpref +leading _infile_;
              end;
          %end;
        %else 
          %do;  %* no centering specified;
            else 
              do;
                if maskbreak or pagebreak then 
                  do;
                    put pbpref _infile_;
                    maskbreak = 0;
                  end;
                else put normpref _infile_;
            end;
          %end;
      %end; %* handle masking;
    %else 
      %do; %*no masking;
        %if &center ^= %then 
          %do; %*handle centering;
            if L in (&center) then leading = int((&ls - length(_infile_)) / 2);
            else leading = 0;
            if pagebreak and index(_infile_, 'Page ') then 
              do;
                put pbpref +leading _infile_;
                pagebreak = 0;
              end;
            else put normpref +leading _infile_;
          %end;
        %else 
          %do;
            if prxmatch('m/page\s*\d+\s*of\s*\d+/i',_infile_) and _n_ ne 1 then 
              do;
                put pbpref _infile_; 
                pagebreak = 0;
              end;
            else put normpref _infile_;
          %end;
      %end; %* no masking; 
    /** close rtf **/;
    if last then put '}';
  run;

  filename tofile;
  filename tofile1;

  proc datasets lib = work nolist;
    delete pbs;
  run;
  quit; 
%mend tableout2rtf;
