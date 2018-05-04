%macro mu_words
(string=
,root=_root_
,numw=_numw_
,delim=%str( )
,report_missing_string=NO
);
/*****************************************************************************************
******************************** PAREXEL International ***********************************
******************************************************************************************

Sponsor name: Generic
Study name: Generic, applicable to all
PAREXEL number: Generic

Program name: mu_word.sas
Program location: generic/macros/

Requirements/Purpose: MACRO UTILITY (MU): Determines the type (character or numeric) of a variable within a dataset
                      This macro parses a character string and returns:
                      1. an array of GLOBAL macro variables consisting of the individual elements 
                         of the string as defined by a user supplied delimiter.
                      2. optionally, a GLOBAL macro variable containing the number of elements in the 
                         string as defined by a user supplied delimiter

References: None

Assumptions: None

Input  : STRING                - The text string to count the words contained
         ROOT                  - Variable prefice (root) of the output macro variables containing each word
         NUMW                  - Variable containing the number of words found
         DELIMITER             - The delimiter between words, default is a SPACE
         REPORT_MISSING_STRING - Boolean flag to control if a NULL string is reported in the SAS/Log

Output : Macro variables called the value of &ROOT suffixed by a number, containing the value of each
         word found

Usage Notes: 

Programs called: None

******************************************************************************************
Version: 1

Release Date: 06-Jun-2012

Developer/Programmer: Darrell Edgley

*****************************************************************************************
Version: N (always increment by full integers)

Release Date: dd-mon-yyyy date code gets released in to production

Developer/Programmer: enter name of programmer finalizing this change

Details of change: provide a summary of all implemented changes
If applicable list any changes to requirements, references, assumptions, inputs, outputs or
called
*****************************************************************************************
*/

  %local word count;
  %let count=1;

  %if %str("&string") = %str("") and %upcase(%substr(%str(&report_missing_string), 1, 1)) ne N %then %do;
        %put USER NOTE: parameter STRING is empty in MU_WORDS call;
  %end;
  %if &root = %str() %then %do;
        %put ALERT_I:  parameter ROOT is empty in MU_WORDS call.  _ROOT_ will be assigned.;
        %let root=_root_;
  %end;
  %if &numw = %str() %then %do;
        %put ALERT_I: parameter NUMW is empty in MU_WORDS call.  _NUMW_ will be assigned;
        %let numw = _numw_;
  %end;
  %else %if %upcase(&numw) = NUMW %then %do;
        data _null_;
        put "ALERT_P: Attempt to GLOBAL a name (NUMW) which exists in a local environment in MU_WORDS call. Program will ABORT.";
        put "ALERT_P: Assign the a different name to the parameter NUMW in MU_WORDS call.";
        ABORT;
        run;
  %end;
  %if "&delim" = "" %then %do;
        %put ALERT_I: parameter DELIM is empty in MU_WORDS call.  A space will be assigned.;
        %let delim = %str( );
  %end;

  %* scans the &STRING and finds the first value with the value of count, which is one and
     has the delimeter set as a &delim;

  %let word=%quote(%nrquote(%scan(&string,&count,&delim)));

  %* while &WORD is not missing then &ROOT&COUNT is equal to &WORD. Also &COUNT represents
     the incremental increase. The &STRING is scanned for the first argument. ;

  %do %while(&word^=);
    %global &root&count;
    %let &root&count=%unquote(&word);
    %let count=%eval(&count+1);
    %let word=%quote(%nrquote(%scan(&string,&count,&delim)));
  %end;

  %* if a value has been specified for macro variable NUMW then a macro variable of that name
     will be created containing a count of the number of words in the STRING;

  %if %length(&numw) > 0 %then %do;
    %global &numw;
    %let &numw = %eval(&count-1);
  %end;
%mend mu_words;
