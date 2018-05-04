%macro tortf;;
%if &sysscp=WIN %then
%do;
proc printto print="%mysdd(&replication_output&slash.qc_&rtf..txt)" NEW;
run;
%end;
%else
%do;
proc printto print="&replication_output&slash.qc_&rtf..txt" NEW;
run;
%end;

%mend;
