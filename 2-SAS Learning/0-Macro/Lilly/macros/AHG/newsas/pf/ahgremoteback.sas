%macro AHGremoteback;
    filename rlink "&Preadonly\tcpunix.scr";
	%local userid password;
    %AHGgetgsun81pw(userid,password);
    %if %AHGblank(&userid) or %AHGblank(&password) %then 
	%do;
  %AHGsavegsun81pw;;
	%AHGgetgsun81pw(userid,password);
	%end;
	%local host sascmd script;
  %let host=gsun81  ;
	%let sascmd=sas9;
	%let script=tcpunix;

 	  option comamid=tcp;
 	  signon &host;
    %rcon;
%mend;
