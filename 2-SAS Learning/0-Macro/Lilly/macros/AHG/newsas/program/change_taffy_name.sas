%macro change_taffy_outputname;

/*PROC IMPORT OUT=taffy */
/*DATAFILE= "&__snapshot.TFL_programming_tracker.xlsx"*/
/*            DBMS=excel REPLACE;*/
/*     SHEET="tracker";*/
/*     GETNAMES=yes;*/
/*RUN;*/


%local all rdm;
%let rdm=%AHGrdm();
%AHGfilesindir(%str(&__snapshot.programs_stat\tfl\),dlm=%str( ) ,mask='%.sas',into=all,case=0,print=1);    
data taffy_&rdm;
  format PROGRAM_NAME output_name $100.;
%local i on;
%do i=1 %to %AHGcount(%str(&all));
%if %substr(%scan(&all,&i,%str( )),1,2)=c_ or %substr(%scan(&all,&i,%str( )),1,2)=o_ %then
  %do;
  %let one=%scan(&all,&i,%str( ));
  program_name=scan("&one",1);
  %let one=%sysfunc(prxchange(s/(.+)_p\d{5}.*t\d{5}.*/\1/,1,&one));
  output_name=scan("&one",1);
  output;
  %end;
%end;
run;



%local myfile sddext;
%let sddext=%scan(&__snapshot,3,%str(\));
%AHGpm(sddext);
/*%let myfile=\\mango\sddext.grp\&SDDEXT\trash\TXT;*/
data taffy_&rdm;
  format program_name $1000.;
  set taffy_&rdm;
/*(obs=2)*/
;
  PROGRAM_NAME="&__snapshot.programs_stat\tfl\"||trim(tranwrd(PROGRAM_NAME,'.sas',''))||'.sas';
/*  file "&myfile";*/
/*  where validator='NA';*/
  format cmd CMDSTR $1000.;
  id=left(put(_n_,best.));
/*  cmd=x  powershell -command  " "" cp "||trim(program_name) ||" \\mango\sddext.grp\&sddext\trash\tmp"||id||'"';*/
/*||" ;cat \\mango\sddext.grp\&sddext\trash\tmp"||id||" | % { $_ -replace 'tfloutname=[^,]+','tflOutName="*/
/*  ||trim(output_name)||"' } >"||trim(program_name) ||";}; ""; "*/
/*||byte(13)*/
;

  cmd="X powershell -command  "" cp "||trim(program_name) ||" \\mango\sddext.grp\&sddext\trash\tmp"||id||";cat \\mango\sddext.grp\&sddext\trash\tmp"||id||  '|%{ $_ -replace ''tfloutname=[^,]+'',''tflOutName='
  ||trim(output_name)||''' } >'||trim(program_name) ||'; " ;';
  put cmd;
  Call execute(cmd);


  cmdSTR="    cp "||trim(program_name) ||" \\mango\sddext.grp\&sddext\trash\tmp"||id||" ; ";;
/*  put cmdSTR;*/
  cmdSTR="   ;cat \\mango\sddext.grp\&sddext\trash\tmp"||id||  "|%{ $_ -replace 'tfloutname=[^,]+','tflOutName="
  ||trim(output_name)||"' } >"||trim(program_name) ||';  ;';
/*  put cmdSTR;*/
/*    call execute(cmd);*/

run;


/* dm "FILEOPEN ""&myfile"" ";;*/

%mend;

%change_taffy_outputname;
