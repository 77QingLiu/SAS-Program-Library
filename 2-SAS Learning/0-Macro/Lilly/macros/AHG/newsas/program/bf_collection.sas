data ahuige(keep=GirlNo bf_count);
  do GirlNo=1 to 100000;
    twelve='000000000000';
    do bf_count=1 to 100;
      substr(twelve,ceil(ranuni(2016)*12),1)='1';      
      if twelve='111111111111' then leave;
    end;
    output;
  end;
run;

proc freq data=ahuige ;
  table bf_count;
  ods output OneWayFreqs=freq;
run;

proc plot data=freq;
  plot CumPercent*bf_count;  
run;
 
