%macro QCactions_awe(tableid,drive=:,QCpgm=,actions= noexecute downqc downRTF open2output nosnap nosnapSDD );
  %if %AHGblank(&QCpgm) %then %let QCpgm=qc_&tableID..sas;
/*  %if %AHGindex(&actions,execute) %then */
/*  %do;*/
/*  %if %sysfunc(fileexist(%mysdd(&projectpath\replica_programs\&qcpgm))) %then %inc "%mysdd(&projectpath\replica_programs\&qcpgm)";;*/
/*  %if %sysfunc(fileexist(%mysdd(&projectpath\replica_programs_nonsdd\&qcpgm))) %then  %inc "%mysdd(&projectpath\replica_programs_nonsdd\&qcpgm)";;*/
/*  %end;*/

  %if &sysscp=WIN %then
    %do;
    %local filedt oldrtfdt newrtfdt ;
    %if %AHGindex(&actions,downRTF) %then
      %do;
      %if %sysfunc(fileexist(%mysdd(&tfl_output\&tableID..rtf))) %then  %AHGfiledt(%mysdd(&tfl_output\&tableID..rtf),into=oldrtfdt,dtfmt=yymmdd10.,tmfmt=time5.);
      x "del %mysdd(&tfl_output\&tableID..rtf) /y";
      x "del %mysdd(&replication_output\&tableID..txt) /y";

      %AHGtoLocal(%sdddc(&tfl_output\&tableID..rtf,pre=&drive),to=%mysdd(&tfl_output),open=0);
      %AHGrtftotxt(%mysdd(&tfl_output)\&tableID..rtf,,%mysdd(&replication_output\&tableID..txt) );
      %if %sysfunc(fileexist(%mysdd(&tfl_output\&tableID..rtf))) %then  %AHGfiledt(%mysdd(&tfl_output\&tableID..rtf),into=newrtfdt,dtfmt=yymmdd10.,tmfmt=time5.);
      %if &oldrtfdt=&newrtfdt %then %AHGshow(%str(&tableID..rtf date is not changed as  &oldrtfdt ));
      %end;

     
    %if %AHGindex(&actions,downqc) %then
      %do;
      x "del %mysdd(&replication_output\qc_&tableID..txt) /y";
      x "copy %sdddc(&replication_output\qc_&tableID..txt,pre=&drive) %mysdd(&replication_output\qc_&tableID..txt)";
      %end;      

    %if %AHGindex(&actions,open2output) %then
      %do;
      x "%mysdd(&replication_output\&tableID..txt) ";
      x "%mysdd(&replication_output\qc_&tableID..txt)";
      %end;

    %if %AHGindex(&actions,snap) %then 
      %DO;
      %AHGsnap(&tfl_output\&tableID..rtf,%mysdd(&replication_output),into=filedt);
      x "copy %mysdd(&replication_output\qc_&tableID..txt) %mysdd(&replication_output\&tableID..rtf.&filedt.qc.txt)";
      x "copy %mysdd(&replication_output\&tableID..txt) %mysdd(&replication_output\&tableID..rtf.&filedt..txt)";

      %end;
    %if %AHGindex(&actions,snapSDD) %then 
      %do;
      %AHGsnap(&tfl_output\&tableID..rtf, %sdddc(&replication_output,pre=&drive),into=filedt);
      x "copy %mysdd(&replication_output\qc_&tableID..txt) %sdddc(&replication_output\&tableID..rtf.&filedt.qc.txt,pre=&drive)";
      x "copy %mysdd(&replication_output\&tableID..txt) %sdddc(&replication_output\&tableID..rtf.&filedt.txt,pre=&drive)";

      %end;
    %end;



%mend;
