
%macro AHGdsntoxls(dsn,var=,out=,font=);
ods listing close;
ods tagsets.excelxp file="&out" 
/*style=sasweb*/
    options(sheet_name="&dsn");
proc report data=&dsn nowd
     style(header)={font_face="&font" font_size=12pt}
     style(report)={font_face="&font" font_size=12pt};
column &var ;
run;
ods tagsets.excelxp close;
ods listing;
%mend;
/*%AHGdsntoxls(allrtf,out=&xls,var=line, font=courier);*/
