%macro downme(tableID );
 
%do;
%local out2 out1;
%let out2=Q:\lillyce\prd\ly275585\f3z_cr_ioqi\final\replica_programs_nonsdd\replication_output;
%let out1=Q:\lillyce\prd\ly275585\f3z_cr_ioqi\final\programs_nonsdd\tfl_output;

x "copy &out2\qc_&tableID..txt &localtemp\ /y;";
x "copy &out1\&tableID..rtf &localtemp\ /y;";
%end;

 
%do;
%AHGrtftotxt(&localtemp\&tableID..rtf,, &localtemp\&tableID..raw.txt  );

data &tableid;
  infile "&localtemp\&tableID..raw.txt " truncover;
  file "&localtemp\&tableID..txt ";
  format line $200.;
  input line 1-200;

  line=compress(line,byte(160));
  put line;
run;

x " &localtemp\qc_&tableID..txt";
x "  &localtemp\&tableID..txt  ";
%end;
%mend;








