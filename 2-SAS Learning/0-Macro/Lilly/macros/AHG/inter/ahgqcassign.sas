%macro AHGQCassign( bugid,touser,duedate=);
    %local i;
    %do i=1 %to %AHGcount(&bugid);
    %AHGqcdocen(
    _
    ,user=&touser,users=&users,studyname=&prot,duedate=&duedate, 
    status=9,bugids=&bugid);
    %end;
%mend;
