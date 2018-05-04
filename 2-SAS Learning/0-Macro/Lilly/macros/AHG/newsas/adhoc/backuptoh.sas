%macro backuptoh(file,h=h:);
%local dt hfile hdir;
%AHGfiledt(&file,into=dt,dtfmt=mmddyy10.);

%let hfile=&h\%sysfunc(PRXCHANGE(s/(\\\\+)?(:)?//,-1,&file));
%let hdir=%sysfunc(PRXCHANGE(s/(.*)\\.*/\1/,-1,&hfile));

%AHGmkdir(&hdir);
x "copy &file &hfile..&dt..txt /y";


 
%AHGpm(hdir hfile dt);


%mend;
