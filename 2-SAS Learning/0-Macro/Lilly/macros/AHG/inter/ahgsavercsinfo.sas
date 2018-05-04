%macro AHGSaveRCSinfo(folder=data);
%AHGdatenow(datenow,dlm=_);
%AHGrpipe(%str(cd &root3/&folder; showrcs>~/temp/extract_&prot._&datenow..txt),q);
%AHGrdowntmp(rpath=~/temp,filename=extract_&prot._&datenow..txt);
data analysis.&folder.RCS&datenow;
    infile "&localtemp\extract_&prot._&datenow..txt" firstobs=5 truncover;
    input filename $ 1-52  inrcs $53-60 ver $61-70 chkoutby $ 71-87 source $88-95 lastArthur :$8.;
run;
%mend;
