%macro AHGapplyLS(str,ls );
  %local mid left right all;
  %let mid=%index(%bquote(&str),%str(     ));
  %If &mid=0 %then %bquote(&str);
  %else 
  %do;
  %let left=%substr(%bquote(&str),1,%eval(&mid-1));
  %let right=%left(%substr(%bquote(&str),&mid));
  %let all=&left%sysfunc(repeat(%str( ),%eval(&ls-%length(&left)-%length(&right))))&right;
&all 
  %end;
%mend;
