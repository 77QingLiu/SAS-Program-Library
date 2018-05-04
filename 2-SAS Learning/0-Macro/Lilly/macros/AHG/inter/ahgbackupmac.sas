%macro AHGbackupmac;
    %let backupdir=&autodir;
    x "mkdir ""&backupdir\backup\backup&sysdate""";
    x "copy ""&autodir\macros\*.sas""  ""&backupdir\backup\backup&sysdate\"" ");
    
    %let backupdir=j:sasmac;
    x "mkdir &backupdir\backup\backup&sysdate";
    x "copy ""&autodir\macros\*.sas"" &backupdir\backup\backup&sysdate\");
    
    %let backupdir=&autodir;
    x "mkdir ""&backupdir\backup\backupbin&sysdate""";
    x "copy ""&kanbox\bin\*""  ""&backupdir\backup\backupbin&sysdate\"" ");
    
    %let backupdir=j:sasmac;
    x "mkdir &backupdir\backup\backupbin&sysdate";
    x "copy ""&kanbox\bin\*"" &backupdir\backup\backupbin&sysdate\");
%mend;


