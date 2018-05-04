%macro AHGdownbin;
%AHGzipdown(rdir=%str(/home/liu04),folder=bin,mask=%str(*),rtemp=&rtemp,ldir=c:\studies);
%mend;
