
	
	%macro AHGemptyDSN(dsn,out=empty%AHGbasename(&dsn));

    data &out;
      ahuige32984932184093284593='';
      output;
      set &dsn(where=(0));
      drop ahuige32984932184093284593;

    run;
    
	%mend;
  
