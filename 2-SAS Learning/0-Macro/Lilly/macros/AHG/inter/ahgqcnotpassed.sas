%macro AHGQCnotpassed( obj,version=,comment=,folder=);
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname);   
%AHGqcdocen(
&obj
,folder=&folder
,user=&user,users=&users,studyname=&prot,version=&version, 
status=2,reason=&comment);
%mend;
