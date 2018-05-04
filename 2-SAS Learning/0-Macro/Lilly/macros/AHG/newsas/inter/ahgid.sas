%macro AHGid(id=loopid,z=2,add=1,pre=id_);
   %global &id;
   %local tempID;
   %let tempid=%eval(&&&id+&add);
   %let &id=%sysfunc(putn(&tempID,z&z..));
   &pre&&&id
%mend;
