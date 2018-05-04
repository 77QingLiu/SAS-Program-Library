%let ahgrdminc=0;
%macro AHGrdm(length,seed=0,inc=ahgrdminc);
%let &inc=%eval(&&&inc+1);
_&&&inc
%mend;


%macro AHGgettempname(tempname,start=,useit=0);
%let &tempname=&tempname._%AHGrdm;
%mend;


option xsync nomprint nomfile noxwait;
%AHGclearlog;
%AHGkill;
x 'del c:\temp\mfile1.sas';
x 'del z:\downloads\newsas\program\oricode.sas';
x 'del z:\downloads\newsas\program\oricode.sas.indent.sas' ;
x 'del c:\temp\mfile1.sas.indent.sas';
filename mprint clear;
filename mprint "c:\temp\mfile1.sas";
/*filename mprint 'c:\temp\mfile1.sas' new;*/
option mprint mfile;
%macro themacrotoreplace;
%summary1(sashelp.class,Height,out=stat_Height,by=Name,trt=Sex,orie=vert);

option nomfile nomprint;
filename mprint clear;

/*x 'del c:\temp\mfile1.sas';*/

/*%AHGopenfile(c:\temp\mfile1.sas.indent.sas);*/
%mend;
%themacrotoreplace; 

