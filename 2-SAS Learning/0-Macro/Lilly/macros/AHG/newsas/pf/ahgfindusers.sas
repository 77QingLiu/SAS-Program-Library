%macro AHGfindusers(netdir,outusers=users);
    %AHGpipe(dir /ad &netdir,dsn=netusers);
   
    data netusers;
        set netusers;
        if index(upcase(line),'<DIR>') then folder=scan(substr(line,index(upcase(line),'<DIR>')),2);
        if index(upcase(line),'<DIR>') and not missing(folder) and not (folder='all');
    run;

    proc sql noprint;
        select folder into :&outusers separated by ' '
        from netusers
        ;quit;
%mend;        
