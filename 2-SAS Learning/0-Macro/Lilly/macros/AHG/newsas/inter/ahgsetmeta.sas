%macro AHGsetmeta(entry=,metafile=Mac.meta,dir=&root3/tools);
    %local q metaName thename thevalue;
	%let thename=%scan(&entry,1,^);
	%let thevalue=%scan(&entry,2,^);
	%let metaName=&dir/&metafile;
	%AHGrpipe(grep -i   ^&thename\^   &metaName,q);
/*	%AHGrpipe(grep -i  """^&thename\^"""  &metaName,q);*/
	%AHGpm(&q);	
%mend;


