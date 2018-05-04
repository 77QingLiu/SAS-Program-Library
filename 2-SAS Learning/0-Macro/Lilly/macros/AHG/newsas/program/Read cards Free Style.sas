data lines;
  format line dir subdir cmd $200.;
  infile datalines truncover;
  input line 1-200;
  retain dir subdir '';
  if index(line,'Directory: G') then dir=tranwrd(scan(line,2,' '),'G:','D:');
  if index(line,'d----') then 
  do;
  subdir=trim(dir)||'\'||scan(line,4,' ');
  cmd='%AHGmkdir('||trim(subdir)||');';
  output;
  end;
  keep cmd;
  call execute(cmd);
/* ls D:\lillyce\qa -recurse -attributes directory */
  
  cards;
Windows PowerShell
Copyright (C) 2012 Microsoft Corporation. All rights reserved.

PS C:\WINDOWS\system32\WindowsPowerShell\v1.0> ls G:\lillyce\prd\ly275585\f3z_c
_ioqi\final -recurse -attributes directory


    Directory: G:\lillyce\prd\ly275585\f3z_cr_ioqi\final


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
d----         2012/8/31     19:44            programs_stat
d----          2014/9/2     20:59            replica_programs_nonsdd
d----         2012/8/31     19:45            programs_nonsdd
d----         2012/8/31     19:44            programs_dm
d----         2012/8/31     19:44            programs_dsep
d----         2012/8/31     19:46            data


    Directory: G:\lillyce\prd\ly275585\f3z_cr_ioqi\final\programs_stat


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
d----         2012/8/31     19:44            tfl_output
d----         2012/8/31     19:44            system_files


    Directory: G:\lillyce\prd\ly275585\f3z_cr_ioqi\final\replica_programs_nonsdd


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
d----          2014/9/2     21:00            replication_output
d----          2014/9/2     21:00            system_files
d----          2014/9/2     21:00            validator_component_modules


    Directory: G:\lillyce\prd\ly275585\f3z_cr_ioqi\final\programs_nonsdd


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
d----         2012/8/31     19:45            tfl_output
d----         2012/8/31     19:45            system_files
d----          2014/9/2     21:05            author_component_modules
d----          2014/9/2     21:05            adam


    Directory: G:\lillyce\prd\ly275585\f3z_cr_ioqi\final\data


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
d----         2012/8/31     19:46            shared


    Directory: G:\lillyce\prd\ly275585\f3z_cr_ioqi\final\data\shared


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
d----         2012/8/31     19:47            custom
d----         2012/8/31     19:47            arc_reporting_metadata
d----         2012/8/31     19:47            pk_regsub
d----         2012/8/31     19:47            eds
d----         2012/8/31     19:47            ads
d----         2012/8/31     19:47            pgx
d----         2012/8/31     19:47            results
d----         2012/8/31     19:47            pk_standards
d----         2012/8/31     19:46            dacs
d----         2012/8/31     19:47            ads_requirements
d----         2012/8/31     19:47            sdtm
d----         2012/8/31     19:46            ext_eds_raw
d----         2012/8/31     19:47            pk_statsdata
d----         2012/8/31     19:46            pk_bioanalytical
d----         2012/8/31     19:47            peds


    Directory: G:\lillyce\prd\ly275585\f3z_cr_ioqi\final\data\shared\pgx


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
d----         2012/8/31     19:47            modified
d----         2012/8/31     19:47            final


PS C:\WINDOWS\system32\WindowsPowerShell\v1.0>
;
run;

%AHGprintToLog(_last_,n=20);








