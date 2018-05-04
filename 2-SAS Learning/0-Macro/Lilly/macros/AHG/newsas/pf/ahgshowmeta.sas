%macro AHGshowmeta(entry=,metafile=Mac.meta,dir=&root3/tools);
    %local  metaName thename thevalue;
	%let thename=%scan(&entry,1,^);
	%let thevalue=%scan(&entry,2,^);
	%let metaName=&dir/&metafile;
	%AHGrpipe(grep -i   ^&thename\^   &metaName,rcrpipe);
	%put ###;
	%put &rcrpipe;
%mend;


