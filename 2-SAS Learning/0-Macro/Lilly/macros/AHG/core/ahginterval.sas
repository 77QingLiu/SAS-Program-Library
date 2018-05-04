%macro AHGinterval(fromID,toid,pre=ahuigetimePoint,url=From &fromID To &toid );
%if %AHGblank(&fromid) %then %let fromID=0;
data _null_;
%IF %AHGblank(&toid) %then  diff=time()-input("&&ahuigetimepoint&fromID",time8.);
%ELSE diff=input("&&ahuigetimepoint&toID",time8.)-input("&&ahuigetimepoint&fromID",time8.);
;
put "######ahuige Interval:&url ########## time used :" diff time8.;
run;


%mend;
