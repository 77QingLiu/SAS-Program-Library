%macro AHGQCcomment(obj,version=,comment=,folder=);
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname);   
    %AHGpm(obj);
    %put qcdocen(&obj
,folder=&folder
,user=&user,users=&users,studyname=&prot,version=&version, 
status=3,reason=&comment);

%AHGqcdocen(%bquote(&obj),folder=&folder,user=&user,users=&users,studyname=&prot,version=&version,status=3,reason=&comment);
%mend;
