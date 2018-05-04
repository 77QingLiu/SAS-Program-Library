*m207d14;

proc pmenu catalog=orion.menus;
   menu exit;
      item 'Exit' menu=x;

	    	menu x;

            item 'OK'     selection=y; 
	       	item 'Cancel' selection=z; 

            selection y 'end';
            selection z 'command focus';

quit;

%let msg=Press ENTER to continue.;

%window dsn columns=80 rows=20 menu=orion.menus.exit

 #3 @ 6 'Data Set: '  dsn 41 attr=underline required=yes
 #5 @16  msg protect=yes;

%window var columns=80 rows=20 menu=orion.menus.exit

 #3 @ 6 'Data Set: '  dsn 41 attr=underline protect=yes 
 #5 @ 6 'Variables: ' var 41 attr=underline
 #7 @17  msg protect=yes;

%window opt columns=80 rows=20 menu=orion.menus.exit

 # 3 @ 6 'Data Set:                 ' dsn 41 attr=underline protect=yes
 # 5 @ 6 'Variables:                ' var 41 attr=underline protect=yes 
 # 7 @ 6 '# of obs:                 ' obs  2 attr=underline
 # 9 @ 6 'Suppress Obs #s (Y or N): ' sup  1 attr=underline
 #10 @ 6 'Double Space    (Y or N): ' dbl  1 attr=underline
 #11 @ 6 'Column Labels   (Y or N): ' lab  1 attr=underline
 #14 @17  msg protect=yes;

%display dsn;
%display var;
%display opt;