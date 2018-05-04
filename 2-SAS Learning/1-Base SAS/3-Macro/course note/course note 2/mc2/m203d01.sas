*m203d01;

%let clear=title; footnote;     			*wrong;

%let clear=%str(title; footnote;);		*right!;

title 'All Students';
footnote 'Fall Semester';

proc print data=sashelp.class;
run;

options symbolgen;
&clear
