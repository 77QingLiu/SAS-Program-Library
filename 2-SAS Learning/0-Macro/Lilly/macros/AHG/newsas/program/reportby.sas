
/* Create a new dataset with only variables needed and ordered*/
%AHGordvar(myadam.adsl,subjid age bmi sex,out=NewADSL,keepall=0);

option nobyline MPRINT PS=25;
title1 "Project xxx ";
title2 "Adverse Event ";
Title3 "Gender=#byval1";
footnote1 "Data source: Adam.adsl";

/* Just print Whatever in the Dataset by SEX*/
%AHGreportby(report,SEX,SORT=1);

/* ...adjust columns' length by order numbers*/
%AHGreportby(report,SEX,WHICH=1,WHICHLENGTH=10,SORT=1);

,
/* ...also show SEX as a column*/
%AHGreportby(report,sex,sort=1,WHICH=1,WHICHLENGTH=10,SHOWBY=1);


/* ...and show the BY variable SEX only once in each group */
%AHGreportby(report,sex,sort=1,showby=1,GROUPBY=1);

/*  */
%AHGreportby(report,sex,WHICH=1,WHICHLENGTH=10,sort=1,showby=1,groupby=1);

