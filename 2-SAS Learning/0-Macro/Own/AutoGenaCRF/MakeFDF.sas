/*--------------------------------------------------------------------------------------------------*
* Macro to make FDF file from previously stored comments SAS dataset
*--------------------------------------------------------------------------------------------------*/
%macro MakeFDF(data=,output=,page=,background=,comment=,style=,coordinate=);
filename fdf "&output";

*------------------- Step 1: Create FDF code --------------------;
data &data;
    set &data;
    &comment = prxchange("s/\(/\(/o",-1,&comment);
    &comment = prxchange("s/\)/\)/o",-1,&comment);
run;

proc sql;
    select * from &data;
quit;
%put &sqlobs;
%macro append;
    %global total_obj;
    %let i =1 ;
    %let total_obj =;
    %do %while(&i<=&sqlobs);
        %let total_obj = &total_obj %eval(&i+1) 0 R;
        %let i = %eval(&i+1);
    %end;
%mend;
%append;

data coding;
    set &data end=last;
    length code $30000;
    /* Begin code */
    if _n_ = 1 then do;
        code = '%FDF-1.2'; output;
        code = '1 0 obj'; output;
        code = "<</FDF<</Annots[&total_obj]>>/Type/Catalog>>";output;
        code = "endobj";output;
    end;
    /* loop through number of annotations to be created */
    code = strip(put(_n_+1,best.))||" 0 obj";output;
    code = "<</BS <</W 0>>"||
           "/C["||strip(&background)||"]"||
           "/Contents("||strip(&comment)||")"||
           "/DS("||strip(&style)||")"||
           "/F 4"||
           "/Page "||strip(&page)||
           "/Rect["||strip(&coordinate)||"]"||
           "/Subj(VOID)/Subtype/FreeText/Type/Annot>>";
           output;
    code = 'endobj';output;
    /* End code */
    if last then do;
        code = "trailer"; output;
        code = "<</Root 1 0 R>>"; output;
        code = '%%EOF'; output;
    end;
    keep code;
run;

*------------------- Step 2: Output FDF file --------------------;
data _null_ ;
    set coding (where=(code ne ''));
    FILE fdf LRECL=30000;
    PUT code;
run ;
%mend;