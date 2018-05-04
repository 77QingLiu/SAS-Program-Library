libname in "G:\lillyce\qa\ly231514\h3e_gh_b015\intrm1\data\shared\ads\metadata";
%let out=G:\lillyce\qa\ly231514\h3e_gh_b015\intrm1\programs_stat\tfl_output;

%let outoption=nonumber nodate orientation=landscape nocenter ; 
%let reportoption=%nrstr(headline headline missing nowindows spacing=0  );


data metadata(keep=col1 col2);
	length col1 $15. col2 $200.;
	set in.arc_reporting_metadata(where=(index(lowcase(report_name_),"fig")=0));
	col1 = strip(propcase(report_name_));
	col2 = tranwrd(catx("_",title1_,title2_,title3_,title4_,title5_),"_H3E-GH-B015","");
	if col1="" then delete;
	output;
run;

ods listing close;
ods rtf file="&out.\B015_Draft_TOC_1_&sysdate..rtf" bodytitle;

title1 "Table of Content";
options &outoption.;
proc report data=metadata style=statistical ls=130 &reportoption.;
     column col1 col2;
  define  col1 / display ''  style(column)={cellwidth=7%};
  define col2 / flow '' style(column)={cellwidth=92%} ;
run;

ods rtf close;
ods listing;


%macro combine_rtf_watermark (path=,name=, if =);
options noxwait noxsync;
filename dirlist pipe "dir ""&path"" /b ";
data dirlist1 ;
  infile dirlist length=reclen ;
  input filename $varying1024. reclen ;
  if scan(filename,2,'.') in ('rtf') and &if ;
  path="&path";
  filename=strip(path)||'\'||strip(filename);
  order=input(compress(scan(scan(filename,-1,'/\'),1,'.'),,'dk'),best.);
run;

proc sql;
  create table dirlist2 as select distinct filename, order from dirlist1 order by order;
quit;
proc sql noprint;
  select count(*) into:n from dirlist2;
  select filename into:file1-:file%cmpres(&n)
  from dirlist2 order by order;
quit;
%let rc=%sysfunc(system(start winword));
data _null_;
x=sleep(5);
run;
filename word DDE 'Winword|System';
data _null_;
file word;
  put '[FileOpen .Name = "' "&file1" '"]';
  %do i=2 %to &n;
  put '[EndOfDocument]';
  put '[InsertBreak .Type = 2]';
  put '[InsertFile .Name ="' "&&file&i." '" ]';
  %end;
  put '[FileSaveAs .Name ="' "&name" '"]';
  put '[FileSave]';
  put '[FileCloseAll]';
  put '[FileExit]';
run;

%mend combine_rtf_watermark;

%let path = G:\lillyce\qa\ly231514\h3e_gh_b015\intrm1\programs_stat\tfl_output;

%macro bundle;
%let name=B015_Draft_Table_3_&sysdate..rtf;
%put &name;
%combine_rtf_watermark (path=G:\lillyce\qa\ly231514\h3e_gh_b015\intrm1\programs_stat\tfl_output,
name=&path.\&name, if =%str(filename=:'table'));

%let name=B015_Draft_Listing_4_&sysdate..rtf;
%put &name;
%combine_rtf_watermark (path=G:\lillyce\qa\ly231514\h3e_gh_b015\intrm1\programs_stat\tfl_output,
name=&path.\&name, if =%str(filename=:'list'));

/*%let name=B015_Draft_Figure_5_&sysdate..rtf;*/
/*%put &name;*/
/*%combine_rtf_watermark (path=G:\lillyce\qa\ly231514\h3e_gh_b015\intrm1\programs_stat\tfl_output,*/
/*name=&path.\&name, if =%str(filename=:'fig'));*/

%let name = B015_Draft_Table_Listing_&sysdate..rtf;
%combine_rtf_watermark (path=G:\lillyce\qa\ly231514\h3e_gh_b015\intrm1\programs_stat\tfl_output,
name=&path.\&name, if =%str(filename=:'B015_Draft_' and index(filename,"&sysdate")>0 ));
%mend;
%bundle;
