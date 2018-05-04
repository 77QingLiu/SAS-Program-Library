%macro AHGsavegsun81pw;
%local luser lpass;
%let remote=gsun81;
%window &remote columns=62 rows=16 icolumn=18 irow=18
    #1 'Press ENTER after completing each field (or press F3 to exit)'
       color=blue
    #2 ' '
    #3 'Userid: ' luser 20 required=yes color=green
    #4 'Password: '   lpass 18 display=no required=yes
     #10 "Your userid and password are stored in the encrypted"
       color=blue
    #11 "sasuser.&remote data set."
       color=blue
    ;
  %display &remote bell delete;


  data  sasuser.gsun81(pw=hcEE3B32);
  	userid=put("&luser",$20.);
	password=put("&lpass",$20.);
  run;
%mend;
