%macro  shell_Freq_hori_By;
%AHGdatasort(data =&dsn, out =dsn&out , by = &byvar &trtvar);

%AHGfreqCore(dsn&out,&var ,by=&byvar &trtvar ,out=&out,print=1,keep= cell,tran=&trtvar,tranby= &byvar value);

%AHGalltocharNew(&out,rename=&sysmacroname);

%AHGrelabel(&out,labels=&Headers);

%AHGrenamekeep(&out,out=,pos=,names=,keepall=0);

%AHGfillzero(&out,vars=col3 col4,fillwith=0 (0.0  ) );

%AHGtrimdsnEx(&out );


proc printto file="&outfile";
run;
%AHGreportby(&out,0,which=,whichlength=,option=nowd NOCENTER,labelopt=%str(option label;));
%mend;
