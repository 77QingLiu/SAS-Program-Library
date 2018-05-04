*m207d16;

%window err columns=80 rows=20 menu=orion.menus.exit

 	#3 @ 6 'Data Set ' c=red dsn p=yes c=red attr=rev_video 
	 ' does not exist.' c=red

 	#5 @ 6 'Enter Y to try again or N to stop: ' 
         try 1 attr=underline

 	#7 @16  msg protect=yes;

%display err;
