%macro AHGcheckdic(dic,dsn,var);
  data _null_;
    set &dsn;
    length text $200;
    text='grep -i "^\n*'||trim(&var) ||"""%sysfunc(upcase(&dic))NCODE.dat "||';';
    put text;
  run;
%mend;

/*
  bnf_actions.dat  
  Bnfncode.dat    
  
  costart.dat   
 
  icd_actions.dat  
  Icdncode.dat    

  who_art_actions.dat    
  Whoncode.dat     

*/
