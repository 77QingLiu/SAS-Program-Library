%macro AHGprintF(F,v1,v2,suffix);
  %let P_&suffix=%sysevalf(1-%sysfunc(probf(%sysevalf(&F_col/(&err/&Ve)),&v_col,&Ve)));
  %AHGPm(F_&suffix P_&suffix);
%mend;
