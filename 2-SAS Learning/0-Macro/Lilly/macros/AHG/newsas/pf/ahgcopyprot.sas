%macro ahgcopyprot(from,to,remove=,debug=0);
%local header shfile;
%let from=%AHGremoveslash(&from);
%let to=%AHGremoveslash(&to);
%let header=%str(ori=&from; dmc2=&to;);
%AHGrpipe(rm -f &userhome/temp/header.sh,q);
%AHGrpipe(rm -f &userhome/temp/copyprot,q);
%AHGrpipe(echo "&header" >&userhome/temp/header.sh,q);
%AHGrpipe(cat &userhome/temp/header.sh ~liu04/copyprot >&userhome/temp/copyprot,q);
%AHGrpipe(chmod +x &userhome/temp/copyprot,q);
%AHGrpipe(%if &debug %then cat; &userhome/temp/copyprot,q);
%AHGrpipe(rm -f &userhome/temp/header.sh,q);
%AHGrpipe(rm -f &userhome/temp/copyprot,q);
%local i folder ext;
%if not %AHGblank(&remove)  and not &debug %then 
%do i=1 %to %AHGcount(&remove);
	%let folder=%ahgscan2(&remove,&i,1,dlm=%str( ),dlm2=.);
	%let ext=%ahgscan2(&remove,&i,2,dlm=%str( ),dlm2=.);
	%AHGpm(folder ext);
	%AHGrpipe( rm -f &to/&folder/%str(*).&ext,q);
	%AHGrpipe(  rm -f &to/&folder/RCS/%str(*).&ext%str(,v),q);
%end;
%put  ############################ copy protocol is done.;
%mend;

