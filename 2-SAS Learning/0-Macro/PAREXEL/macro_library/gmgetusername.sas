/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.1.3 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Dmitry Kolosov $LastChangedBy: kolosod $
  Creation Date:         30MAY2013 $LastChangedDate: 2015-02-20 06:10:28 -0500 (Fri, 20 Feb 2015) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmgetusername.sas $

  Files Created:         N/A


  Program Purpose:       Macro returns user name specified in ~/.forward file. In case a user name cannot
                         be obtained from that file, value of sysUserId is returned.

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:
                         N/A

  Macro Returnvalue:

      Description:       Character string without quotes.

  Macro Dependencies:    gmExecuteUnixCmd (<called>)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion
-----------------------------------------------------------------------------*/

%macro gmGetUserName();
    %put NOTE:[PXL] %sysFunc(tranwrd(%qScan($HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmgetusername.sas $, -1,:$), 7070/svnrepo, %str()))%str(,) r%qScan($Rev: 348 $,2);
    %* Step 1 - Extract First and Last name (or any other number of names);
    %* Step 2 - substitute every dot with a space;
    %local gun_userName;
    %let gun_userName = %sysFunc(propCase(
        %left(%gmExecuteUnixCmd(cmds = cat ~/.forward | sed 's/[[:digit:]]*@.*//' | sed 's/\./ /g'
                                ,splitCharIn=#
                                ,splitCharOut=%str( )
                               )
             )
                     ,%str( -))
            );
    %* Check if the user name was obtained from .forward file;
    %if "&gun_userName." = "" or %index(&gun_userName.,Cat: Cannot Open) %then %do;
       %put NOTE:[PXL] Cannot get a user name from .forward file. Please ask IT to update it.;
       %let gun_userName = &sysUserId.;
    %end;
    &gun_userName.
%mend gmGetUserName;
