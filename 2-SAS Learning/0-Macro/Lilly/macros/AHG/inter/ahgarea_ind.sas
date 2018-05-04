%macro AHGarea_ind(indset,vname,vout,glb=0);
/*in open code glb=1 makes %p m(vout) possible */
%if &glb=1 %then %do;%global &vout;%end;
   data _null_;
   set &indset(keep=&vname rename=(&vname=vname)) end=end;
   sum+vname*vname;
   if end then 
      do;
      call symput("&vout",sum);
      end;
   run;
%mend;
