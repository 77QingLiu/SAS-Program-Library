%macro AHGinitdiffbatch;
%global batchcompare strold strnew;
%let batchcompare=1;%let strold=;%let strnew=;
%AHGrpipe(%str(test -e ~/temp/&prot..old.sas %nrstr(&&) rm -f ~/temp/&prot..old.sas),q);
%AHGrpipe(%str(test -e ~/temp/&prot..new.sas %nrstr(&&) rm -f ~/temp/&prot..new.sas),q);
%mend;
