/*Macro to calculate original SSQ value*/
%macro AHGSSQgrp(
       dsn,/*dataset name*/
       Value, /*Value*/
       factor,/*factor name*/
       outVar, /*Variable name to save SSQ value*/
       print=0, /*print Mac value or not, 1 = yes*/
       glb=0
       );
  %if &glb=1 %then %global &outvar;;
  %local AreaB AreaC;
  %AHGArea_grp(&dsn,&value,&factor,AreaB);
  %AHGArea_grand(&dsn,&value,AreaC);
  %let &OutVar=%sysevalf(&AreaB-&AreaC);
  %if &print=1 %then %AHGpm(outvar);
%mend;
