/*--------------------------------------------------------------------------------------------------*
*                                           Read reviewed DCM 
*--------------------------------------------------------------------------------------------------*/
%macro ReadDefine(file=,out=,addvar=);
%let define=C:\Users\LiuC5\Documents\Mine\aCRF\define;
proc import datafile="&define\&file..xlsx" out=&out. dbms=excel replace;
            sheet   = 'Draft aCRF Definition';
run;
data &out.;
    set &out.;
    array test(*) _Char_;
    do i = 1 to dim(test);
      test(i) = compress(test(i),,'kw');
    end;
    where upcase(Select_Flag)='Y';
    source_ = "&file";
    formOID_lag = lag(formOID);
    if formOID ne formOID_lag then order=.;
    order+1;
    rename source_ = source;
    keep PAREXEL_REMINDER source_ Selection_reason Comments Annotation FieldOID Field FormOID Form_Name order &addvar;
run;
%mend;
%ReadDefine(file=aCRF Definition draft_BS(2544-3490),out=define_a);
%ReadDefine(file=aCRF Definition draft_BS_CL(3491-4569),out=define_b);
%ReadDefine(file=aCRF Definition draft_CL(1473-2543),out=define_c);
%ReadDefine(file=aCRF Definition draft_JY(1-1472),out=define_d);

%macro ReadDefine2(sheet=,out=);
%let define=C:\Users\LiuC5\Documents\Mine\aCRF\define;
proc import datafile="&define\&file..xlsx" out=&out. dbms=excel replace;
            sheet   = 'Draft aCRF Definition';
run;
data &out.;
    set &out.;
    array test(*) _Char_;
    do i = 1 to dim(test);
      test(i) = compress(test(i),,'kw');
    end;
%mend;


*------------------- Set ALL --------------------;
data define_reviewed;
    length PAREXEL_REMINDER source $500;
    set define_a define_b define_c define_d(in=d);
    if d then flag=0; else flag=1;
run;
proc sort data=define_reviewed; by FieldOID FormOID Annotation flag descending Comments;run;
proc sort data=define_reviewed nodupkey; by FieldOID FormOID Annotation;run;
proc sort data=define_reviewed out=dup nouniquekey; by FieldOID FormOID;run;
proc sort data=define_reviewed;by formOID order;run;
data define_reviewed;
    set define_reviewed;
    by formOID order;
    if first.formOID then order_=.;
    order_ +1;
    drop order;
    rename order_ = order;
run;

/*--------------------------------------------------------------------------------------------------*
*                                           Read DCM annotation
*--------------------------------------------------------------------------------------------------*/
libname global "\\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\02_Project Reference\global";
libname Oncology "\\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\02_Project Reference\Oncology";

data define_dcm;
    set global.global_field Oncology.oncology_field;
    rename TopicValue = annotation form=Form_Name PreText=Field;    
    order = int(num);
    keep TopicValue Form FormOID PreText FieldOID order;
run;
proc sort nodupkey;by formOID FieldOID annotation;run;
proc sort;by formOID order;run;
data define_dcm;
    set define_dcm;
    by formOID order;
    if first.formOID then order_=.;
    order_ +1;
    drop order;
    rename order_ = order;
run;

/*--------------------------------------------------------------------------------------------------*
*                                           Join DCM and Reviewed aCRF
*--------------------------------------------------------------------------------------------------*/
libname define "\\Cn-sha-hfp002.ap.pxl.int\vol3\Users\LiuC5";

data define_ALL_1;
    set define_dcm(in=a) define_reviewed(in=b);
    if a then source="DCM";
    else source = "Reviewed";
run;
proc sort;by formOID FieldOID annotation descending source;run;
proc sort nodupkey;by formOID FieldOID annotation ;run;

proc sql;
    create table define_ALL_2 as 
    select *, formOID as order_1,
            case when count(distinct Annotation)=1 then 'Y' else 'N' end as unique, mean(order) as order_2,
             fieldOID as order_3, source as order_4
    from define_ALL_1
    group by formOID,FieldOID
    order by order_1, order_2, order_3, order_4;
quit;

data define_ALL_3;
    set define_ALL_2;
    by order_1 order_2 order_3 order_4;
    if unique='Y' then order_a +1;
    if first.order_3 and unique = 'N' then order_b +1;
    Select_Flag = "";
run;

/* Add Note */
data define_ALL_4;
    set define_ALL_3;
    length note $1000;
    if find(Annotation,'note','i') then do;
        NOTE       = prxchange('s/.+(NOTE:[^|]+)$/$1/io',-1,strip(Annotation));        
        Annotation = prxchange('s/\| NOTE:[^|]+$//io',-1,strip(Annotation));
    end; 
run;
proc sql;
    create table define_ALL_5 as 
    select a.*, coalescec(a.NOTE_,b.Comment,c.Comment) as NOTE length=500
    from define_ALL_4(rename=NOTE=NOTE_) as a 
        left join global.global_note as b on a.formOID=b.formOID
        left join Oncology.oncology_note as c on a.formOID=c.formOID;
quit;

/* Remove ORRESU */
data define_ALL_6;
    set define_ALL_5;
    if find(Annotation,'ORRESU','i') and prxmatch('/ORRES[^U]/io',Annotation) then do;;
        Annotation = prxchange('s/, ?[A-Z]{2}ORRESU//io',-1,Annotation);
    end;

    if find(Annotation,'FATESTCD') and not prxmatch('/FATEST ?= ?[A-z]+/o',Annotation) and not prxmatch('/FATEST[^C]/o',Annotation) and not find(Annotation,'FASTAT') then do;
        Annotation = catx(' | ','FATEST',strip(Annotation));
    end;
run;

/* Output */
data define.define_all;
    set define_ALL_6;
    Annotation = prxchange('s/\|\|/||'||byte(13)||byte(10)||'/io',-1,compress(Annotation,,'kw'));
    if source = 'DCM' then Selection_reason = 'follow DCM';
run;
proc sort;by order_1 order_2 order_3 order_4;run;


*------------------- Read reviewed annotation --------------------;
proc import datafile="C:\Users\LiuC5\Documents\Mine\aCRF\define\aCRF Definition draft.xlsx" out=define_e dbms=excel replace;
            sheet   = 'Draft aCRF Definition';
run;
data define_e;
    set define_e;
    array test(*) _Char_;
    do i = 1 to dim(test);
      test(i) = compress(test(i),,'kw');
    end;
run;

data define_e;
    set define_e;
    where upcase(Select_Flag) = "Y" or Unique_Flag='Y';
    keep formOID fieldOID Annotation;
run;
proc sort nodupkey;by formOID fieldOID Annotation;run;
proc sort nodupkey;by formOID fieldOID;run;

proc sort data=define_ALL_6;by formOID fieldOID;run;

data define_ALL_7;
    merge define_ALL_6(in=a) define_e(in=b rename=Annotation=Annotation_);
    by formOID fieldOID;
    if a and not b then NotInOld='Y';
    Annotation = coalescec(Annotation_,Annotation);
run;
proc sort nodupkey;by formOID fieldOID Annotation;run;

data define.define_all;
    set define_ALL_7;
    Annotation = prxchange('s/\|\|/||'||byte(13)||byte(10)||'/io',-1,compress(Annotation,,'kw'));
    if source = 'DCM' then Selection_reason = 'follow DCM';
    format _all_;
run;
proc sort;by order_1 order_2 order_3 order_4;run;


/*--------------------------------------------------------------------------------------------------*
*                                           Output
*--------------------------------------------------------------------------------------------------*/
filename excel "\\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\04_Automatic_aCRF\definition library\aCRF Definition draft.xlsx";
ods excel file=excel style=seaside
          options(
                 autofilter              ='all'
                 frozen_headers          ='on'
                 sheet_interval          ='proc'
                 sheet_name              ='Draft aCRF definition'
                 tab_color               ='red'
                 autofit_height          = 'yes'
                 sheet_interval          = 'PROC');
    proc report data=define.define_all nowd style(column)={vjust=center} split="#" out=a;
        column order_1 order_2 order_3 order_4 Select_Flag Selection_reason PAREXEL_REMINDER source annotation Comments fieldOID Field formOID Form_name note order_a order_b unique NotInOld;
        define  order_1                  /order ORDER=internal noprint;
        define  order_2                  /order ORDER=internal noprint;
        define  order_3                  /order ORDER=internal noprint;
        define  order_4                  /order ORDER=internal noprint;
   
        define  Select_Flag            /display 'Select#Flag' style(column)={cellwidth=0.3in just=center width=1000% tagattr='wrap:yes'};
        define  Selection_reason       /display 'Selection#reason' style(column)={cellwidth=0.5in just=center width=1000% tagattr='wrap:yes'};     
        define  PAREXEL_REMINDER       /display 'PAREXEL#REMINDER' style(column)={cellwidth=0.5in just=center width=1000% tagattr='wrap:yes'};                  
        define  formOID                /display 'FormOID' style(column)={cellwidth=0.8in just=center  width=1000% tagattr='wrap:yes'};
        define  fieldOID                /display 'FieldOID' style(column)={cellwidth=1in just=center  width=1000% tagattr='wrap:yes'};
        define  source                  /display 'Source' style(column)={cellwidth=0.5in just=center};
        define  form_name                    /display 'Form Name' style(column)={cellwidth=1.5in just=center  width=1000% tagattr='wrap:yes'};
        define  annotation              /display 'Annotation' style(column)={cellwidth=0.00025in just=left width=1000% tagattr='wrap:yes'};
        define  Comments            /display 'Comments' style(column)={cellwidth=0.3in just=center width=1000% tagattr='wrap:yes'};        
        define  Field                  /display 'Field' style(column)={cellwidth=2.5in just=left width=1000% tagattr='wrap:yes'};
        define  note                  /display 'Note' style(column)={cellwidth=2.5in just=left width=1000% tagattr='wrap:yes'};        
        define  order_a              /display noprint;
        define  order_b              /display noprint;
        define  unique                /display 'Unique#Flag';
        define NotInOld               /display "Not in Old";
    run;
    ods excel close;




            define  color /computed noprint;
        compute color;
            if unique='Y' and mod(order_a,2) = 0 then call define(_row_,'style','style=[backgroundcolor=#00b0f0]');
            else if unique='Y' then call define(_row_,'style','style=[backgroundcolor=#da9694]');

            if unique='N' and mod(order_b,2) = 0 then call define(_row_,'style','style=[backgroundcolor=#e26b0a]');
            else if unique='N' then call define(_row_,'style','style=[backgroundcolor=#00b050]');            
        endcomp;