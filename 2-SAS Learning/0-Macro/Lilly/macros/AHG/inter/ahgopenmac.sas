%macro AHGopenmac(mac,where);
%if %AHGblank(&where) %then %let where=sas;
%AHGopenfile(z:\downloads\newsas\core\&mac..sas,&where);
%AHGopenfile(z:\downloads\newsas\inter\&mac..sas,&where);
%AHGopenfile(z:\downloads\newsas\adhoc\&mac..sas,&where);
%AHGopenfile(z:\downloads\newsas\draft\&mac..sas,&where);

%AHGopenfile(d:\newsas\core\&mac..sas,&where);
%AHGopenfile(d:\newsas\inter\&mac..sas,&where);
%AHGopenfile(d:\newsas\adhoc\&mac..sas,&where);
%AHGopenfile(d:\newsas\draft\&mac..sas,&where);


%mend;
