%macro AHGarea_grand(indset,vname,vout,glb=0);
/*in open code glb=1 makes %p m(vout) possible */
%if &glb=1 %then %do;%global &vout;%end;
   data _null_;
   set &indset(keep=&vname) end=end;
      sum+&vname;
   if end then 
      do;
        out=sum**2/_n_;
        call symput("&vout",out);
      end;
   run;
%put &&&vout;
%mend;
