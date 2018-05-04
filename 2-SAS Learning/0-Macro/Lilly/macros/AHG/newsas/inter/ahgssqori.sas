/*Macro to calculate original SSQ value*/
%macro AHGSSQOri(
       dsn,/*dataset name*/
       Value, /*Value*/
       outVar, /*Variable name to save SSQ value*/
       print=0, /*print Mac value or not, 1 = yes*/
       glb=0
       );
  %if &glb=1 %then %global &outvar;;
  %local AreaA AreaC;

  %AHGarea_ind(&dsn,&value,AreaA);
  %AHGarea_grand(&dsn,&value,AreaC);
  %let &OutVar=%sysevalf(&AreaA-&AreaC);
  %if &print=1 %then %AHGpm(outvar);
%mend;
