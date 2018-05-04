%macro mu_create_dated_dir(type=) ;
/*****************************************************************************************
******************************** PAREXEL International ***********************************
******************************************************************************************

Sponsor name: Generic
Study name: Generic, applicable to all
PAREXEL number: Generic

Program name: mu_create_dated_dir.sas
Program location: generic/macros/

Requirements/Purpose: UTILITY MACRO: Creates a dated sub-directory for specific data folders.
                      Ths macro accepts the "TYPE" of directory based on a macro parameter,
                      the actual path of the generated parent folder is retrieved from an
                      associated global macro variable, typical set in PXL_SETUP.SAS

                      The path of the folders in is macro variables starting PATH_

                      The typical values of TYPE are:
                       CODING   - global macro variable = PATH_CODING
                       DOWNLOAD - global macro variable = PATH_DOWNLOAD
                        EDATA    - global macro variable = PATH_EDATA
                        EXPORT   - global macro variable = PATH_EXPORT
                        LISTINGS - global macro variable = PATH_LISTINGS
                        METRICS  - global macro variable = PATH_METRICS
                        SCRF     - global macro variable = PATH_SCRF
                        VIEWS    - global macro variable = PATH_VIEWS
                     As long as a corresponding PATH_XYZ macro variable exists and value of TYPE
                      can be supplied.

References: None

Assumptions: Associated GLOBAL macro variables have been assigned (starting PATH_)

Input  : TYPE : Suffix to a macro variable that must exist called PATH_[type]

Output : Creates a dated folder on UNIX and a corresponding symbolic link called CURRENT that
         points to it.

Programs called: mu_fileexist.sas

******************************************************************************************
Version: 1

Release Date: 27-Feb-2012

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

  %local localopt;
  
  %let localopt=%sysfunc(getoption(mprint)) 
                %sysfunc(getoption(symbolgen)) 
                %sysfunc(getoption(mlogic));
  
  %global nomprint nosymbolgen nomlogic utiloptions;
  
  options &utiloptions;

  %global create_dated_dir ;

  %if ^%util_mvar_test(_mvar=path_&type) %then %do ;
    %put %str(ERR)OR: The PATH macro variable for %upcase(&type) has not been set ;
    %put %str(ERR)OR: Please create a global macro variable called PATH_%upcase(&type) ;
    %goto mexit ;
  %end ;

  %if %str(%upcase(&create_dated_dir)) = %str(N) %then %do ;
    %put ALERT_I: The request to create a dated directory for &type has been ignored ;
    %put %str(        ) per the setting of the macro variable CREATE_DATED_DIR ;
    %put %str(        ) which is set to N.  Set it to any value NOT N to progress. ;
    %goto mexit ;
  %end ;

  %let _path             = path ;
  %let _pathname         = %cmpres(&&&_path._&type) ;
  %let _pathname_current = %cmpres(&&&_path._&type./current) ;

  ** This is the typical dated target directory, however it could   ** ;
  ** be reassigned below.                                           ** ;
  %let _pathname_dated   = %cmpres(&&&_path._&type./&rundate) ;
  %let _rundate = &rundate ;

  ** The path for the DATED directory is conditional.               ** ;
  ** If the code is run from a DEVELOPMENT folder then by default   ** ;
  ** the dated directory is set to "draft" UNLESS the value of      ** ;
  ** create_dated_dir is set to F (meaning FORCE).                  ** ;
  %if &devel >= 1 %then %do ;
    %put ALERT_I: &sysmacroname invoked from an area that has been determined to be ;

    %if %str(%upcase(&create_dated_dir)) ne %str(F) %then %do ;
      %put %str(        ) a DEVELOPMENT library.  A dated sub-directory will NOT be ;
      %put %str(        ) created, instead the path will be set to "draft". ;
      %put %str(        ) If a DATED subdirectory is REQUIRED then please re-run but ;
      %put %str(        ) with the value of the macro variable CREATE_DATED_DIR set ;
      %put %str(        ) to value F. ;

      %let _rundate = draft ;
      %let _pathname_dated   = %cmpres(&&&_path._&type./&_rundate) ;
    %end ;
    %else %do ;
      %put %str(        ) a DEVELOPMENT library.  However the over-ride flag has ;
      %put %str(        ) been set and a dated sub-directory called &rundate ;
      %put %str(        ) will be created. ;
    %end ;
  %end ;

  %let create_dir = %str() ;
  %mu_words(string=&_pathname,root=_path,numw=_nump,delim=/) ;

  ** Make sure the parent directory exists.  If not, create it.... ** ;
  %if &_nump >= 2 %then %do ;
    %local _k ;
    %do _k = 1 %to &_nump ;
      %let create_dir = %trim(&create_dir)/&&_path&_k ;

      %if ^%mu_fileexist(&create_dir,alert=n) >=1 %then %do ;
        %put NOTE: Folder &create_dir does not exist, creating: ;
        %sysexec mkdir &create_dir ;
        %if ^%mu_fileexist(&create_dir,alert=n) >=1 %then %do ;
          %put %str(- failed) ;
        %end ;
        %else %do ;
          %put %str(- success) ;
        %end ;
      %end ;
    %end ;
  %end ;

  %if %mu_fileexist(&_pathname,alert=n) <= 0 %then %do ;
    %put ALERT_I: The parent directory &_pathname does not exist, creating ;
    %let _create_parent = 1 ;
  %end ;
  %else %do ;
    %let _create_parent = 0 ;
  %end ;

  %if %mu_fileexist(&_pathname_dated,alert=n) >=1 %then %do ;
    %put ALERT_I: The dated directory &_pathname_dated already exists, update ;
    %let _create_dated = 0 ;
  %end ;
  %else %do ;
    %put ALERT_I: The dated directory &_pathname_dated does not exist, creating ;
    %let _create_dated = 1 ;
  %end ;

  %if %mu_fileexist(&_pathname_current,alert=n) <= 0 %then %do ;
    %put ALERT_I: The CURRENT symbolic-link &_pathname_current does not exist, creating ;
  %end ;

  ** It is prudent to delete the existing SYM LINK, then re-create it later ** ;
  data _null_;
    command1 = 'cd ' || "&_pathname" ;
    command2 = 'rm ' || "&_pathname_current" ;
    rc1 = system(command1) ;
    rc2 = system(command2) ;
  run ;

  %if %eval(&_create_parent) = 1 %then %do ;
    ** Create the parent if it does not already exist.                        ** ;
    data _null_;
      command1 = 'umask 0003' ;
      command2 = 'mkdir ' || "&_pathname" ;
      rc1 = system(command1) ;
      rc2 = system(command2) ;
    run ;
  %end ;

  %if %eval(&_create_dated) = 1 %then %do ;
    ** Create the dated directory if it does not already exist.               ** ;
    data _null_;
      command1 = 'umask 0003' ;
      command2 = 'mkdir ' || "&_pathname_dated" ;
      rc1 = system(command1) ;
      rc2 = system(command2) ;
    run ;
  %end ;

  ** Create the symbolic link.                                                ** ;
  data _null_;
    command1 = 'cd ' || "&_pathname" ;
    command2 = 'umask 0003' ;
    command3 = 'ln -s ' || "&_rundate current" ;
    rc1 = system(command1) ;
    rc2 = system(command2) ;
    rc3 = system(command3) ;
  run ;

  %mexit:
  options &localopt ;
%mend mu_create_dated_dir ;
