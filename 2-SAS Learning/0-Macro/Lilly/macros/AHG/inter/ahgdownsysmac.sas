%macro AHGdownsysMac;
%AHGzipdown(folder=macros,mask=%str(*.sas),rtemp=&rtemp,rdir=/Volumes/app/cdars/prod/saseng/pds1_0,ldir=&localtemp);
%mend;
