
data provided_macros2 ;
     length filename filen $1000 macName $33 ;
     infile sasautos("*.sas") filename= filen lrecl= 1000 dlm= ' (/)% ; ' ;
     input @ ;
     pos = find(_infile_, '%macro ', 'i' ) ;
     if pos ;
     input @(pos+6) macName ;
     filename= filen ;
run ;

