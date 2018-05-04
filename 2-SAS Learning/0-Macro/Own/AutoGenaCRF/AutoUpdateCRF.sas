
%macro AutoUpdateCRF;
%let program =\\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\04_Automatic_aCRF\program;
%let path =&path;

*------------------- Read Bookmarks --------------------;
%macro books(file=);
data books_&file.;
    infile "&path\&file._bookmark.txt";
    input;
    if prxmatch('/^\x09/o',strip(_infile_));
    length form $200;
    form = scan(_infile_,1,byte(9));
    page = input(scan(_infile_,2,byte(9)),best.);
    if _n_ ne 1;
run;
proc sort nodupkey;by page form;run;
%mend;
%books(file=old);
%books(file=new);

*------------------- Read ALS --------------------;
%macro import(file=);
data forms_&file.;
    infile "&path.\&file..csv" missover delimiter=',' dsd lrecl=32767 firstobs=2;
    informat OID $13.;
    informat ordinal  best32.;
    informat DraftFormName $67.;
    informat DraftFormActive $4.;
    format OID $13.;
    format ordinal  best12.;
    format DraftFormName $67.;
    format DraftFormActive $4.; 

    input OID$ ordinal DraftFormName $ DraftFormActive $;
    if DraftFormActive='TRUE';

    array test(*) _Char_;
    do i = 1 to dim(test);
      test(i) = compress(test(i),,'kw');
    end;
run;
proc sort;by ordinal;run;
%mend;
%import(file=new);
%import(file=old);

*------------------- Update form name in bookmarks --------------------;
data update_old;
    set books_old;
    set forms_old(keep=DraftFormName rename=DraftFormName=form);
run;
proc sort;by form page;run;

data update_new;
    set books_new;
    set forms_new(keep=DraftFormName rename=DraftFormName=form);
run;
proc sort;by form page;run;

data update_page1;
    merge update_new(in=a rename=page=page_new) update_old(in=b rename=page=page_old);
    by form;
    if b and not a then do;
        n1 +1;
        call symputx('check1_'||cats(n1),strip(form));
        call symputx('n1',cats(n1));
    end;
    if a and not b then do;
        n2 +1;
        call symputx('check2_'||cats(n2),strip(form));
        call symputx('n2',cats(n2));
    end;
run;

proc sort;by descending page_new;run;
data update_page2;
    set update_page1;
    by descending page_new;
    count_new = lag(page_new)-page_new;
run;
proc sort;by descending page_old;run;
data update_page3;
    set update_page2;
    by descending page_old;
    count_old = lag(page_old)-page_old;
    if ^missing(page_old) and ^missing(page_new);
    if missing(count_new) then count_new = 5;
    if missing(count_old) then count_old = 5;
    if count_old ne count_new then do;
        n3 +1;
        call symputx('check3_'||cats(n3),strip(form)||", Old:"||cats(count_old)||" New:"||cats(count_new));
        call symputx('n3',cats(n1));
    end;    
run;

data update_page4;  /* Add record for long-break forms */
    set update_page3;
    by descending page_old;
    output;
    do i = 1 to count_old-1;
        page_old=page_old +1;
        page_new=page_new +1;        
        output;
    end;
    keep page_old page_new form count_old count_new;
run;
proc sort;by page_old;run;

*------------------- Update page in FDF file --------------------;
%let page       = %str(s#.*\/Page (.*?)\/.*#$1#io); /* PDF page */

data fdf_1; 
    infile "&path.\old.fdf" recfm=n;
    input text_byte ib1. @@;
    length text_raw $30000;
    retain text_raw;
    if text_byte = 32 then text_byte=94; /* Replace spcae with other characters(^) to prevent being removed by CATX function */
    if text_byte not in (13,10) and text_byte>0 then text_raw=cats(text_raw,byte(text_byte)); /* 13('0D'X) is FDF file record separater */
    if text_byte = 13 then do;
        text_raw  = prxchange('s/\^/ /o',-1,text_raw); /* Replace previous special characters(^) with blank space */
        if prxmatch("#.*\/Page (.*?)\/.*#io",text_raw) then page_old  = input(strip(prxchange("&page",-1,text_raw)),best.)+1;
        order = _n_;
        output;
        call missing(text_raw);
    end;
run;

proc sql;
    create table fdf_2 as 
    select a.*, b.page_new
    from fdf_1 as a left join update_page4 as b
    on a.page_old = b.page_old
    order by order;
quit;

data fdf_3;
    set fdf_2;
    length text_raw1 text_raw2 $10000;
    if ^missing(page_old) and ^missing(page_new) then do;
        text_raw1 = prxchange('s#(.*\/Page )(.*?)(\/.*)#$1#io',-1,text_raw);
        text_raw2 = prxchange('s#(.*\/Page )(.*?)(\/.*)#$3#io',-1,text_raw);
        text_raw  = strip(text_raw1)||" "||cats(page_new-1)||strip(text_raw2);
    end;
run;

data _null_ ;
    set fdf_3 ;
    FILE "&path.\update.fdf" LRECL=30000;
    PUT text_raw;
run ;


%IF %symexist(n1) or %symexist(n2) or %symexist(n3) %THEN %DO;
    %PUT ============================================================;
    %PUT  ;
    %if %symexist(n1) %then %do;
        %do i = 1 %to &n1;
            %if &i=1 %then %put Form exists in Old CRF but not in New CRF:;
            %put %str(        ) &&check1_&i;
        %end;
    %end;

    %if %symexist(n2) %then %do;
        %do i = 1 %to &n2;
            %if &i=1 %then %put Form exists in New CRF but not in Old CRF:;
            %put %str(        ) &&check2_&i;
        %end;
    %end;

    %if %symexist(n3) %then %do;
        %do i = 1 %to &n3;
            %if &i=1 %then %put Page per form dismatch in New and Old CRF;
            %put %str(        ) &&check3_&i;
        %end;
    %end;    
    %PUT  ;
    %PUT ============================================================;

%END;
%mend;
