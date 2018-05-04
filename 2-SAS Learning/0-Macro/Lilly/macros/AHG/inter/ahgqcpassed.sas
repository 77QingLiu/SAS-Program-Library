%macro AHGQCpassed( obj,version=,comment=,folder=folder);
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname);   
%AHGqcdocen(
&obj
,folder=&folder
,user=&user,users=&users,studyname=&prot,version=&version, 
status=1,reason=&comment,bugids=NOBUG);
%mend;
