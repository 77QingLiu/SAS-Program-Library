/*sas views of QC data */
%macro AHGqcviewcreator(lib=qclib);

  %macro rawnetview;

    %local user;
    %do i=1 %to %AHGcount(&users);
        %let user=%scan(&users,&i);
        data &lib..view&user/view=&lib..view&user;
          %if &lib=netall %then          set &user..qcdoc;;
          %if &lib=qclib %then          set qclib.qcdoc&user;;

        run;
    %end;

  %mend;

  %rawnetview;


  %macro views;
    %local user;
    %do i=1 %to %AHGcount(&users);
        %let user=%scan(&users,&i);

           &lib..view&user(drop=dateframe) 

    %end;
  %mend;


  data &lib..allqcdoc/view=&lib..allqcdoc;
    length bugid $40;
    format
    filename	$30.
    status	12.
    reason	$500.
    user	$20.
    ;
    set %views;
  /*  set &lib..viewhui(drop=dateframe) &lib..viewyzj(drop=dateframe);*/
   
    if datetime<&dateframe1 then dateframe=0;
    if &dateframe1<=datetime<&dateframe2 then dateframe=1;
    if &dateframe2<=datetime<&dateframe3 then dateframe=2;
    if &dateframe3<=datetime<&dateframe4 then dateframe=3;
    if &dateframe4<=datetime<&dateframe5 then dateframe=4;
    if &dateframe5<=datetime<&dateframe6 then dateframe=5;
    if &dateframe6<=datetime<&dateframe7 then dateframe=6;
    where reason ne "First entry for QC library";
  run;


  data _null_;
    datetime=input('20NOV2008:00:00:00',datetime18.);
    call symput('newQCdatetime',datetime);
  run;

  proc sql; 
    create view &lib..nodup as
    select distinct * 
    from &lib..allqcdoc
    where not missing(filename)
    group by dateframe, fileid, sortid ,datetime
    ;  
    create view &lib..bugs as
    select * 
    from &lib..nodup
    where status  in (0 2 3)
    ;  
    create view &lib..solutions as
    select nodup.bugid, COALESCEC(nodup.filename,bugs.filename),bugs.reason as ori_reason,bugs.datetime as ori_dt, bugs.version as ori_ver
               ,nodup.reason as action,nodup.version as fixed_ver ,nodup.datetime as fixed_dt
    from &lib..nodup left join &lib..bugs
    on nodup.bugid =bugs.bugid
    where nodup.status=1
    ; quit;

    data &lib..assignments/view= &lib..assignments;
        set &lib..nodup ;
        rename user=Owner;
        rename version=duedate;
        where status  in (9);
    run;

proc sql;
    create view &lib..owners as
    select bugid,owner, duedate
    from &lib..assignments
    group by bugid
    having datetime=max(datetime)
    ;  
/*    having datetime=max(datetime)*/
    ;  
quit;



  proc sql;

/*    create view &lib..task as*/
/*    select bugid,user*/
/*    from &lib..allqcdoc*/
/*    where datetime>=&newQCdatetime and status=9*/
/*    group by filename*/
/*    having datetime=max(datetime)*/
/*    ;*/

/*    create view &lib.._01numNotpassed as*/
/*    select distinct * */
/*    from &lib..bugs*/
/*    where status=2 and bugid not in (select bugid from &lib..solutions)*/
/*    ;*/

    create view &lib.._01Critical_Issue as
    select distinct bugs.bugid,filename as Object,reason as Issue,version,owners.owner, datetime,duedate
    from &lib..bugs
                              left join &lib..owners
                              on bugs.bugid =owners.bugid
    where status=2 and bugs.bugid not in (select bugid from &lib..solutions)

    ;

    create view &lib.._02Non_Critical_issue as
    select distinct bugs.bugid,filename as Object,reason as Issue,version,owners.owner , datetime,duedate
    from &lib..bugs
                              left join &lib..owners
                              on bugs.bugid =owners.bugid
    where status=3 and bugs.bugid not in (select bugid from &lib..solutions)
    ;

    create view &lib.._00Assignment as
    select distinct bugs.bugid,filename as Object,reason as Description,version,owners.owner , duedate
    from &lib..bugs
                              left join &lib..owners
                              on bugs.bugid =owners.bugid
    where status=0 and bugs.bugid not in (select bugid from &lib..solutions)

    ;


quit;



%mend;

