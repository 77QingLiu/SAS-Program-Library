  %MACRO ut_xpt2ds(INPFILE = _default_,
                   OUTPUT  = _default_,
                   VERBOSE = _default_,
                   DEBUG   = _default_ );
                   

/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME   		   : ut_xpt2ds
CODE TYPE			   : Broad-Use Module
DESCRIPTION        	: This Utility Broad Use Module explodes an input transport file residing 
                       in specified location into SAS datasets, which are finally copied to a 
                       user specified output location.
SOFTWARE/VERSION#  	: SAS Version 9.1.3
INFRASTRUCTURE     	: SDD Version 3.4
LIMITED-USE MODULES	: N/A
BROAD-USE MODULES  	: UT_PARMDEF, UT_ERRMSG, UT_LOGICAL
INPUT              	: User specified parameters INPFILE
OUTPUT         	   : User specified parameters OUTPUT
VALIDATION LEVEL   	: 6
REQUIREMENTS		   : Explode an input transport file to SAS datasets and save datasets to 
					        user specified location
ASSUMPTIONS        	: N/A
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION:

BROAD-USE MODULE TEMPORARY OBJECT PREFIX:  _2ds
PARAMETERS:
---------------------------------------------------------------------------------
   Parameters:
   Name     Type     Default  	Description and Valid Values
   -------- -------- -------- 	-------------------------------------------------
   INPFILE  required            Name and path of the input transport file      
   OUTPUT   required            Name of the final output library
   VERBOSE  optional  1         %ut_logical value specifying whether verbose mode is on or off
   DEBUG    optional  0         %ut_logical value specifying whether debug mode is on or off
----------------------------------------------------------------------------------

USAGE NOTES: N/A

TYPICAL WAY TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

     %ut_xpt2ds(INPFILE = '&inlib/ut_xpt2ds_test.xpt',
                OUTPUT  = outlib,
                VERBOSE = Y,
                DEBUG   = N );
 
The parameters passed in the above call signifies:-
1. &inlib is the input location which is specified in the SDD parameters window. 
2. ut_xpt2ds_test.xpt is the name of the transport file.
3. outlib is the output SAS library.Path to the output SAS library is also specified in the SDD parameter window. 
4. Y is the verbose option.
5. N is the debug option.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver#   Peer Reviewer   			 Code History Description
---- ----------------   		 ------------------------------------------------
  1.0   Anubhav Srivastav        As per CR05668818
                                 Original version of the broad-use module is created
                                 by Shilp Agrawal-TCS Data Movement Offshore Team.
 
        <Peer Reviewer>          See the name of electronic approval of completed Quality 
                                 Review Tool and Test Plan in QA.
**eoh************************************************************************/

%*===================================================================================================;
%* WRITE THE NAME OF THIS MACRO TO THE SAS PROGRAM LOG.                                              ;
%*===================================================================================================;

  %Local _2DSPGM;
  %Let _2DSPGM = ut_xpt2ds Version 1.0;
  %Put NOTE : NOW EXECUTING MACRO &_2DSPGM;

%*==============================================================================================;
%*ASSIGNING THE DEFAULT VALUES TO THE OPTIONAL PARAMETER VERBOSE                                                   ; 
%*==============================================================================================;
  
  %ut_parmdef(VERBOSE,Y);
  
  %if &VERBOSE= %then %do;
    %let VERBOSE=1;
  %end; 
    
  %ut_logical(verbose);
%*===================================================================================================;
%* ASSIGNING THE DEFAULT VALUES TO THE OPTIONAL PARAMETER DEBUG                                      ;
%*===================================================================================================;
  

  %ut_parmdef(DEBUG,N);

  %if &debug= %then %do;
    %let debug = 0;
  %end; 

  %ut_logical(DEBUG);

%*===================================================================================================;
%* Switching the Debug options based on the value passed in the Debug Parameter                      ;
%*===================================================================================================;

  %If &DEBUG = 1 %Then %Do; 
    Options SYMBOLGEN MLOGIC MPRINT;
  %End;


%*===================================================================================================;
%* VERIFY THAT ALL THE REQUIRED PARAMETERS ARE PRESENT AND ARE VALUED                                ;
%* STOP THE MACRO IF ANY ERRORS IN THE PARAMETERS                                                    ;
%*===================================================================================================;

  %ut_parmdef(INPFILE,_pdrequired=1,_pdverbose = &verbose);
  %If %length(&INPFILE) = 0 %Then %Do; 
    %ut_errmsg(msg=No input file specified. Terminating execution of macro, type=error, macroname=ut_xpt2ds);
    %goto mac_end;
  %End;

  %ut_parmdef(OUTPUT,_pdrequired=1,_pdverbose = &verbose);
  %If &OUTPUT =  %Then %Do; 
    %ut_errmsg(msg=No output location specified. Terminating execution of macro, type=error, macroname=ut_xpt2ds);
    %goto mac_end;
  %End;

 

%*===================================================================================================;
%* PRINT AN ERROR MESSAGE IN THE LOG AND STOP THE MACRO PROCESSING IF THE INPUT TRANSPORT FILE       ;
%* SPECIFIED BY THE INPFILE PARAMETER IS NOT PRESENT                                                 ;
%*===================================================================================================;
        
  %If %sysfunc(fileexist(&INPFILE))= 0 %Then %Do;
    %ut_errmsg(msg=Input file does not exist. Terminating execution of macro, 
               type=error, macroname=ut_xpt2ds);
    %goto mac_end;
  %End;


%*===================================================================================================;
%* PRINT AN ERROR MESSAGE IN THE LOG AND STOP THE MACRO PROCESSING IF THE OUTPUT LOCATION            ;
%* SPECIFIED BY THE OUTPUT PARAMETER DOES NOT EXIST                                                  ;
%*===================================================================================================;

	%If (%sysfunc(libref(&OUTPUT)))  %Then %Do;
	  %ut_errmsg(msg=Output location does not exist. Terminating execution of macro, 
					 type=error, macroname=ut_xpt2ds);
	  %goto mac_end;
	%End;

%*===================================================================================================;
%* EXPLODE THE TRANSPORT FILE PASSED VIA THE INPFILE PARAMETER AND COPIED THE INDIVIDUAL SAS DATASETS;
%* TO THE OUTPUT LOCATION.                                                                           ;
%*===================================================================================================;

  PROC CIMPORT Infile = &INPFILE LIBRARY = &OUTPUT;
  Run;

  %mac_end:
%*===================================================================================================;
%* Switching the Debug options OFF and resetting the environment options based on the value passed   ;
%* in the Debug Parameter                                                                            ;
%*===================================================================================================;

  %If &DEBUG = 1 %Then %Do;
    Options NOSYMBOLGEN NOMLOGIC NOMPRINT;
  %End;

  %Put NOTE : NOW ENDING MACRO &_2DSPGM;

  %MEND ut_xpt2ds;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="e6d1d6:11f13774437:1e9f" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS log" systemtype="&star;LOG&star;" tabname="System Files" baseoption="A" advanced="N" order="1" id="&star;LOG&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="LOG"*/
/*   processid="P1" required="N" resolution="INPUT" enable="N" type="LOGFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS output" systemtype="&star;LST&star;" tabname="System Files" baseoption="A" advanced="N" order="2" id="&star;LST&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="LST"*/
/*   processid="P1" required="N" resolution="INPUT" enable="N" type="LSTFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="Process parameter values" systemtype="SDDPARMS" tabname="System Files" baseoption="A" advanced="N" order="3" id="SDDPARMS" canlinktobasepath="Y" protect="N" userdefined="S" filetype="SAS7BDAT"*/
/*   processid="P1" required="N" resolution="INPUT" enable="N" type="PARMFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS program" systemtype="&star;PGM&star;" tabname="System Files" baseoption="A" advanced="N" order="4" id="&star;PGM&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="SAS"*/
/*   processid="P1" required="N" resolution="INPUT" enable="N" type="PGMFILE">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="5" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="INPFILE" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="6" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="OUTPUT" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="7" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DEBUG" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="8" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_2DSPGM" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="9" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="VERBOSE" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/