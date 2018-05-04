%macro ut_putfile(inlib   = _default_,
				      infile  = _default_,
				      outlib  = _default_,
				      outfile = _default_,
				      debug   = _default_);
/*soh**************************************************************************************
  Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME   : Ut_putfile.sas
   TYPE                    : user utility
   DESCRIPTION             : This utility is used to copy a given object from the specified 
				                 source location to the destination location.
   DOCUMENT LIST           : \\quark\quark.grp\DELTA_QA\Broad Use Modules\Ut_putfile\QA Documentation
	SOFTWARE/VERSION#       : SAS version 8 and 9
   INFRASTRUCTURE          : Windows XP/SDD Version 3.3
   BROAD-USE MODULES       : ut_parmdef, ut_logical
   INPUT                   : file(s) stored on the specified input location
   OUTPUT                  : files(s) directed to the specified output location
   VALIDATION LEVEL        : Level 6
   REGULATORY STATUS       : GCP
   TEMPORARY OBJECT PREFIX : N/A
   
--------------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description
   -------- -------- -------- --------------------------------------------------
  INLIB		required		   Reference Name of Library in which input file is present.
  INFILE	required		   input file name                                
  OUTLIB	required		   Reference Name of Library where output file should be copied to.
  OUTFILE	optional		   output file name (not required if input file name is desired).                             
  DEBUG		required  N		   %logical value specifying whether debug mode is
                               on or off.
  VERBOSE   required  1        %ut_logical value specifying whether verbose mode
                               is on or off /*This BUM was developed prior to the creation of
				                                the BUM utility which uses this parameter. Since
				                                this BUM does not use VERBOSE at all, this 
				                                parameter will not be included in this BUM ***
  MODE      required           Mode for setting Diagnostic options
                              /*This BUM was developed prior to the creation of the BUM utility 
                                which uses this parameter. Since this BUM does not use VERBOSE 
                                at all, this parameter will not be included in this BUM ***
--------------------------------------------------------------------------------
  Usage Notes:
  This BUM can be used in Windows, PC-SAS interacting with SPREE and within SDD environments.
  To copy a single file or dataset from one directory to another, provide the library reference 
  name as parameter inlib and the file name as parameter infile.
--------------------------------------------------------------------------------
  Assumptions: None
--------------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

    %ut_putfile(inlib=work,
                infile=test.sas,
                outlib=outlib,
                outfile=test_out.sas);

--------------------------------------------------------------------------------
                     BROAD-USE MODULE HISTORY
  Ver#  Author &
        Peer Reviewer       Request #            Description
  ----  ---------------  -------------------------------------------------------
  1.0   Dhirendra Singh   BMRDJG22NOV2004A    Original version of the broad-use module
        <Peer Reviewer>                       See Peer Reviewer's name and signature in the 
                                              completed Quality Review Tool 
  2.0	Dhirendra Singh	  BMRMAB10FEB2005a    1.Added check that if the destination is in SPREE and file extension contains
				  		                        more than 4 charecters then the file extension name will be stripped out.
				  		                      2.Functionality for copying of multiple files from the source directory
				  			                    has been removed.
        <Peer Reviewer>                       See Peer Reviewer's name and signature in the 
                                              completed Quality Review Tool 
  3.0   Shilp Agrawal     CR05226330          1. Modified processing to allow the ut_putfile BUM to work in SDD using SAS9 
                                              2. Updated the header as per the new template
                                              3. Updated the logic for SPREE environment to check for the resolved 
                                                 path of the output library
					                          4. Updated the logic to ensure that the input parameters are not equal to the
					                             output parameters.
        <Peer Reviewer>                       See Peer Reviewer's name and signature in the completed Quality Review Tool 
**eoh*********************************************************************************************************/

  %put Now executing macro ut_putfile Version 3.0;

  %ut_parmdef(debug,0);
  %ut_logical(debug) ;

  %IF &debug=1 %THEN %DO;
    options mprint symbolgen mlogic;
  %END;

  %ut_parmdef(inlib);
  %ut_parmdef(infile);
  %ut_parmdef(outlib);
  %ut_parmdef(outfile);  

%if (%index(%upcase(&SYSSCP),WIN)) %then %do;

%*===============================================================*;
%* Ensure all the Paths specified are correct                    *;
%*===============================================================*;
%*---------------------------------------------------------------*;
%*  Ensure input path was specified                              *;
%*---------------------------------------------------------------*;

  %if %length(&inlib)=0 %then %do;
    %put UERROR:  No input path specified.;
    %goto error_out;
  %end;

%*---------------------------------------------------------------*;
%*  Ensure input file was specified                              *;
%*---------------------------------------------------------------*;

  %if %length(&infile)=0 %then %do;
    %put UERROR:  No input file specified.;
    %goto error_out;
  %end;

%*---------------------------------------------------------------*;
%*  Resolve the inlib parameter to a physical path               *;
%*---------------------------------------------------------------*;

  %let inlib = %sysfunc(pathname(&inlib));

%*---------------------------------------------------------------------------*;
%*  Concatenate input path and input file and ensure the input file exists   *;
%*---------------------------------------------------------------------------*;
  
  %let putfile_in = "&inlib\&infile";
  %if %sysfunc(fileexist(&putfile_in))=0 %then %do;
    %put UERROR:  Input file does not exist.;
    %goto error_out;
  %end;

%*---------------------------------------------------------------------------*;
%*  Ensure output path was specified                                         *;
%*---------------------------------------------------------------------------*;
 
  %if %length(&outlib)=0 %then %do;
    %put UERROR:  No output path specified.;
    %goto error_out;
  %end;

%*---------------------------------------------------------------------------*;
%*  Resolve the outlib parameter to a physical path                          *;
%*---------------------------------------------------------------------------*;

  %let outlib = %sysfunc(pathname(&outlib));

%*---------------------------------------------------------------------------*;
%*  Ensure output directory exists                                           *;
%*---------------------------------------------------------------------------*;
%*---------------------------------------------------------------------------*;
%* Updated as per CR05226330 to check for non-existing libname values in call*;
%*---------------------------------------------------------------------------*;
  
  %if %sysfunc(fileexist(&outlib))=0 or %length(&outlib)=0 %then %do;
    %put UERROR:  Output directory does not exist.;
    %goto error_out;
  %end;

%*---------------------------------------------------------------------------*;
%*  If all input files in the directory were specified, do not allow         *;
%*  copying of files.                                                        *;
%*---------------------------------------------------------------------------*;

  %if "&infile" = "*" %then %do;
    %put UERROR: Input file does not exist;
    %goto error_out;
  %end;

%*---------------------------------------------------------------------------*;
%*  Ensure output file was specified (unless all input files in the          *;
%*  directory were specified)                                                *;
%*---------------------------------------------------------------------------*;

  %if %length(&outfile)=0 %then %do;
    %put NOTE:  No output file specified. INFILE parameter (Input file name) assigned to OUTFILE parameter (Output file name);
    %let outfile=&infile;
  %end;

%*---------------------------------------------------------------------------*;
%*  Ensure that if output file is specified then its extension matches with  *;
%*  the extension of input file                                              *;
%*---------------------------------------------------------------------------*;

  %if %length(&infile) > 0 and %length(&outfile) > 0 %then %do;
    %let infile_lspt  = %scan(&infile, -1, '.');
	 %let outfile_lspt = %scan(&outfile, -1, '.');

	%if &infile_lspt NE &outfile_lspt %then %do;
	  %put UERROR:  File extensions of input file and output file do not match.;
	  %goto error_out;
    %end;
  %end;
%*---------------------------------------------------------------------------*;
%*  Updated as per CR05226330 to ensure input path/file and output path/file *;
%*  are not identical                                                        *;
%*---------------------------------------------------------------------------*;
 
  %if "&inlib"="&outlib" and &infile=&outfile %then %do;
    %put UERROR:  Input and output paths and files are identical.;
    %goto error_out;
  %end;

%*---------------------------------------------------------------------------*;
%*  Ensure that if output location is in SPREE and the file extension        *;
%*  exceeds 4 charecters then the file extension is removed from the         *;
%*  output file name                                                         *;
%*---------------------------------------------------------------------------*;
  %if %length(&outlib) >=8 %then 
    %if (%substr(&outlib,1,8) = U:\SPREE) and (%length(%scan(&outfile,2,.)) > 4) %then
      %let outfile = %scan(&outfile,1,.);

%*---------------------------------------------------------------------------*;
%*  Concatenate output path and input file (if necessary).                   *;
%*---------------------------------------------------------------------------*;

  %if %length(&outfile)=0 %then %do;
    %let putfile_out = "&outlib";
  %end;
  %else %do;
    %let putfile_out = "&outlib\&outfile";
  %end;


%*===========================================================================*;
%*  Copy file(s) to output destination                                       *;
%*===========================================================================*;

  x %quote(copy &putfile_in  &putfile_out /y && exit);
  
%*===========================================================================*;
%*  Write lines to log to provide status of copy                             *;
%*===========================================================================*;
  %if &sysrc ne 0 %then %do;
    %put UERROR: UT_PUTFILE was unable to copy file to destination.;
  %end;
  %else %do;
    %put UT_PUTFILE successfully copied file to destination: &outlib\&outfile;
  %end;

  %if (%substr(&outlib,1,8) = U:\SPREE) %then %do;
  
    %response:

    %let user=;
  
    %window response color=red columns=50 rows=20
	  #2 @11 "Copying file &outfile to SPREE Location:" color=white
	  #4 @11 "&outlib" color=white
	  #8 @11 'Please Wait for the Pop-Up window from Documentum...' color=white
	  #12 @15 '1. Press Y when finished entering Attributes in SPREE' color=white
	  #14 @15 '2. Press N to keep waiting ' color=white	  
	  #16 @2  'Enter Options: (Y/N): ' color=white user 1 required=yes color=white a=rev_video
	  #18 @11  'Press ENTER to continue.' color=white;
    %display response bell blank;
   
    %if %upcase(&user) ne Y %then 
	  %goto response;
	
  %end;    
%end;

*============================================================================*;
* CR05226330: Added logic to copy dataset in SDD environment                 *;
*============================================================================*;
%if (%index(%upcase(&SYSSCP),SUN)) %then %do;
    %if %length(&infile) LE 9 %then %do;
        %put UERROR: Incorrect input file;
        %goto error_out;
    %end;

    %else %if (%index(%upcase(&infile),.SAS)) and (%index(%upcase(&infile),DAT)) %then %do; 
        %let indat_name = %trim(%left(%substr(&infile, 1, %eval(%length(&infile)-9))));

%*---------------------------------------------------------------------------*;
%*  Ensure input path and input file exists                                  *;
%*---------------------------------------------------------------------------*;
        %if %sysfunc(exist(&&INLIB..&indat_name)) = 0 %then %do;
           %put UERROR:  INLIB\INFILE does not exist. One or both the parameter values are incorrect;
           %goto error_out;
        %end;

        %if %length(&outlib) NE 0 %then %do;
            %if %length(%sysfunc(pathname(&OUTLIB))) EQ 0 %then
            %do;
               %put UERROR:  Output directory does not exist;
               %goto error_out; 
            %end; 
        %end;
        %else %do;
             %put UERROR:  Output directory does not exist;
            %goto error_out;
        %end; 

        %if %length(&outfile)=0 %then %do;
           %put NOTE:  No output file specified. INFILE parameter (Input file name) assigned to OUTFILE parameter (Output file name);
           %let outfile=&infile;
        %end;

        %let outdat_name = %trim(%left(%substr(&outfile, 1, %eval(%length(&outfile)-9))));
       
        %*---------------------------------------------------------------------------*;
        %*  Ensure input path/file and output path/file are not identical            *;
        %*---------------------------------------------------------------------------*;
        %if "&INLIB"="&OUTLIB" and &infile=&outfile %then %do;
           %put UERROR:  Input and output paths and files are identical;
           %goto error_out;
        %end;

        %*---------------------------------------------------------------------------*;
        %*  Copy the dataset from source to destination                              *;
        %*---------------------------------------------------------------------------*;
        data &outlib..&outdat_name;
           set &inlib..&indat_name;
        run;

        %if %sysfunc(exist(&&OUTLIB..&outdat_name)) = 0 %then %do;
           %put UERROR: UT_PUTFILE was unable to copy file to destination;
           %goto error_out;
        %end;

        %put UT_PUTFILE successfully copied file to destination: &outlib\&outfile;
    %end;

    %else %do; 
        %put UWARNING: Object was not copied to destination. In SDD, only SAS datasets can be copied using the BUM;
    %end;

%end;
%*===========================================================================*;
%*  All errors found in error checking skips to here                         *;
%*===========================================================================*;
	
%error_out:
%put Macro ut_putfile ending;

%if &debug=1 %then %do;
  options nosymbolgen nomlogic nomprint;
%end;

%mend ut_putfile;