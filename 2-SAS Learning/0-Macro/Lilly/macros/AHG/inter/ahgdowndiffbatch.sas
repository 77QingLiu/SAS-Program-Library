%macro AHGdowndiffbatch;

%AHGrdowntmp(rpath=&userhome/temp,filename=&prot..old.sas,open=1);
%AHGrdowntmp(rpath=&userhome/temp,filename=&prot..new.sas,open=1);
%symdel batchcompare /NOWARN;
%mend;
