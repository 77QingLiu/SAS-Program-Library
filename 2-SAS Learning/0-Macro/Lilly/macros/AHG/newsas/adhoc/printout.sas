%macro printout;
%if not %symexist(tableid) %then %let tableid=tableid;
%if &sysscp=WIN %then
%do;
proc printto print="%mysdd(&out2nd\qc_&tableid..txt)" NEW;
run;
%end;
%else
%do;
proc printto print="&out2nd/qc_&tableid..txt" NEW;
run;
%end;

%mend;
