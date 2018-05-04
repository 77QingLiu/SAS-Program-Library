%macro AHGassigntask(taskbugs,taskorbug=,to=,user=,studyname=,datetime=,Reason=,rpt=1,bugids=);
   %if %lowcase(&taskorbug)=task %then
     %do;
       %do i=1 %to %AHGcount(&taskbugs,dlm=@);
       %AHGQCDocen(%scan(&taskbugs,&i,@),reason=&to,user=&user,users=&users,studyname=&studyname,
datetime=&datetime,status=9,bugids=TASK);
       %end;
     %end;

   %if %lowcase(&taskorbug)=bug %then
     %do;
       %do i=1 %to %AHGcount(&taskbugs,dlm=@);
       %AHGQCDocen(assignment,reason=&to,user=&user,users=&users,studyname=&studyname,
datetime=&datetime,status=8,bugids=%scan(&taskbugs,&i,@));
       %end;
     %end;
   
%mend;


