%macro AHGfullfmt(var,type=/*1 num ;0 char*/);
	if &type =1 then 
	do;
	&var=left(&var);
	&var=compress(&var,'$');
	if not index(&var,'.') 	 then &var=trim(&var)||'.0';
	if index(&var,'. ') then &var=trim(&var)||'0';
	end;
	if &type in (0,2) then 
	do;
	&var=left(&var);
	&var=compress(&var,'$');
	if not index(&var,'.') then &var=trim(&var)||'.';
	&var='$'||scan(&var,1,'.')||'.';
	end;
%mend;
