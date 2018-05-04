
%let StudyID      = 231794;
%let GeneralPath  = \\Cn-sha-hfp001.ap.pxl.int\vol5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\02_Project Reference;
%let PorojectPath = &GeneralPath.\&StudyID;
%let ALS          = &PorojectPath\&StudyID;
%let program      = \\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\04_Automatic_aCRF\program;
libname  width "\\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\04_Automatic_aCRF\output";
libname  out "&PorojectPath";


%macro AutoGenaCRF;
options cmplib=width.functions noquotelenmax;

/*--------------------------------------------------------------------------------------------------*
*       Step 1: Get Field Position In Blank CRF.
*--------------------------------------------------------------------------------------------------*/
%include "&program/GetField.sas";
%GetField(      PorojectPath     =&PorojectPath,
                ALS      =&ALS,
                DictBook =DictionaryCRF_Bookmark,
                DictLink =DictionaryCRF_Links,
                BlkBook  =BlankCRF_Bookmark,
                NOLOCK   =N
                );
%if %symexist(ck1) or %symexist(ck2) or %symexist(ck3) or %symexist(ck4) or %symexist(ck7) or %symexist(ck8)  %then %GOTO EXIT ;

/*--------------------------------------------------------------------------------------------------*
*       Step 2: Update possible wrong field position
*--------------------------------------------------------------------------------------------------*/
%include "&program/ReadFDF.sas";
%ReadFDF(file=&PorojectPath/fdf_adjust.fdf, out=fdf);
data fdf_adjust3; /* Field */
    set fdf;
    where background = "0.25 0.666656 0.333328";
    comment = comment;
    order   = input(scan(comment,1,':'),best.);
    page_   = input(page,best.)+1;
    drop page;
    rename page_ = page;
    keep comment x1 y1 x2 y2 order page_;
run;
proc sort nodupkey;by _all_;run;

proc sql;
    create table fdf_adjust4 as 
    select a.*, b.form as form_
    from fdf_adjust3 as a 
        left join BlkBook_4 as b 
            on a.page = b.page
    order by page;
quit;

data fdf_adjust5;
    set fdf_adjust4;
    by page;
    length form $400;
    retain form;
    if ^missing(form_) then form = form_;
run;

proc sort data = fdf_adjust2;by form order;run;
proc sort data = fdf_adjust5;by form order;run;

data fdf_adjust6;
    length form $400;
    merge fdf_adjust2(in=a keep=form order FieldOID PreText formOID DataDictionaryName ControlType DefaultValue UnitDictionaryName FixedUnit label_flag) 
          fdf_adjust5(in=b);
    by form order;
    if a and not b then do;
        n9 +1;
        call symputx("check9_"||cats(n9),strip(form),'g');
        call symputx("ck9",cats(n9),'g'); 
    end;        
    if b and not a then do;
        n10 +1;
        call symputx("check10_"||cats(n10),strip(form),'g');
        call symputx("ck10",cats(n10),'g'); 
    end;        
    x1 = 522;
    if prxmatch('/^((\d|[A-Z])+_(\d|[A-Z])+_(\d|[A-Z])+)/o',strip(formOID))  /* Remove DCM form suffix for repeated DCM like VS_GL_900 VS_GL_900_1*/
    then DCM = prxchange('s/^((\d|[A-Z])+_(\d|[A-Z])+_(\d|[A-Z])+)_\w+/$1/io',-1,formOID);
    formOID_old  = formOID;
    formOID      = coalescec(DCM,formOID);
    SubDCM       = prxchange('s/^((\d|[A-Z])+_(\d|[A-Z])+_\d+[A|B|C|D|E]?)_\w*$/$1/o',-1,strip(formOID));
    DCMYN        = prxmatch('/^(\d|[A-Z])+_(\d|[A-Z])+_\d+[A|B|C|D|E]?YN$/o',strip(formOID));
    DefaultValue = prxchange('s/^\d+$//o',-1,strip(DefaultValue));
run; 
proc sort;by fieldOID DCM page;run;

%if %symexist(ck9) or %symexist(ck10) %then %GOTO EXIT ;

/*--------------------------------------------------------------------------------------------------*
*       Step 3: Join aCRF definition library with CRF Field
*--------------------------------------------------------------------------------------------------*/
%macro readlib(sheet=,out=);
proc import datafile="C:\Users\LiuC5\Documents\Mine\aCRF\define\aCRF Definition Final.xlsx" out=&out dbms=xlsx replace;
            sheet   = "&sheet";
run;

data &out;
    set &out;
    array test(*) _Char_;
    do i = 1 to dim(test);
      test(i) = compress(test(i),,'kw');
    end;
run;
%mend;
/* Annotation */

proc import datafile="C:\Users\LiuC5\Documents\Mine\aCRF\define\aCRF Definition Final.xlsx" out=define dbms=xlsx replace;
            sheet   = "Draft aCRF definition";
run;

data define;
    set define;
    array test(*) _Char_;
    do i = 1 to dim(test);
      test(i) = compress(test(i),,'kw');
    end;
run;

data define;
    set define;
    annotation = prxchange('s#\/#,#io',-1,annotation);
run;
proc sort;by formOID FieldOID annotation;run;
proc sort nodupkey;by formOID FieldOID;run;

/* Data define */
%readlib(sheet=DATADEF,out=DATADEF);
proc sql;
    create table DATADEF_FMT as 
    select "DATADEF" as FMTNAME, Domain as START, DSLabel as LABEL, 'C' as TYPE,'' as HLO 
    from DATADEF
    where ^missing(Domain);
quit;
proc format library=work cntlin=DATADEF_FMT;run;

/* Not submitted form */
%readlib(sheet=Not Submitted Form,out=NotSub_);
proc sql;
    create table NotSub as 
    select distinct a.formOID,a.form, a.page
    from fdf_adjust2 as a inner join NotSub_ as b 
    on a.formOID=b.formOID
    order by formOID;
quit;
*------------------- Join definition with updated FDF --------------------;
proc sql;
    create table fdf_adjust7 as 
    select c.*, case when ^missing(b.FieldOID) then 'Y' else 'N' end as deleteFlag
    from (select distinct formOID_old,formOID from fdf_adjust6 group by formOID having page=min(page) ) as a 
         inner join fdf_adjust6 as b on a.formOID_old=b.formOID_old
         right join fdf_adjust6 as c on b.formOID=c.formOID and b.fieldOID=c.FieldOID
    order by formOID,page, FieldOID;
    create table fdf_adjust8 as 
    select a.*,case when ^missing(b.formOID) then 'Y' else 'N' end as firstDCM
    from fdf_adjust7 as a left join (select distinct formOID_old,formOID from fdf_adjust6 group by formOID having page=min(page) ) as b on a.formOID_old=b.formOID_old;    
quit;


proc sql;
    create table aCRF_1a as 
    select  a.Annotation length=1000, b.*
    from define(where=(^missing(Annotation))) as a 
            right join fdf_adjust8 as b 
                on a.formOID=b.DCM and a.fieldOID=b.fieldOID
    group by a.formOID, a.FieldOID
    order by page, y1 desc, y2 desc;

    create table aCRF_1 as 
    select  *, count(distinct page) as page_count
    from aCRF_1a
    group by formOID, FieldOID
    order by page, y1 desc, y2 desc;
quit;

data aCRF_1;  /* Add ORRESU */
    set aCRF_1;
    if prxmatch('/ORRES[^U]/o',annotation) and not find(annotation,'orresu','i')
        and (^missing(UnitDictionaryName) or ^missing(FixedUnit)) then do;
            DOMAIN_ORRES = prxchange('s/.+([A-Z][A-Z])ORRES.+/$1/o',-1,Annotation);
            Annotation = prxchange('s/ORRES/ORRES, '||strip(DOMAIN_ORRES)||'ORRESU/',-1,Annotation);
    end;
run;

/* Delete repeated field in repeated DCM form */
/* Add MISSING contents for field without annotation */
proc sort data=aCRF_1;by formOID ;run;

data aCRF_1;
    merge aCRF_1(in=a) NotSub(in=b);
    by formOID;
    if deleteFlag = 'Y' and firstDCM ne 'Y' then delete;
    if missing(Annotation) and ^missing(DCM) and not b then Annotation = "MISSING";
    if a;
run;

*------------------- Join definition with other info --------------------;
/* Get next field position */
proc sort data=aCRF_1;by page descending y1 descending y2;
data aCRF_2;
    set aCRF_1 end=last;
    by page descending y1 descending y2;
    if not last then set aCRF_1(firstobs=2 keep=y2 page rename=(y2=y2_next page=page_next));
    if page ne page_next then y2_next = 0;
run;
proc sql;
    create table aCRF_3 as 
    select a.*, b.UserDataString, c.entry_count
    from aCRF_2 as a 
        left join DataDictionaryEntries_2 as b 
            on a.DataDictionaryName=b.DataDictionaryName
        left join (select distinct DataDictionaryName, count(*) as entry_count from DataDictionaryEntries(where=(^missing(DataDictionaryName))) group by DataDictionaryName) as c 
            on a.DataDictionaryName=c.DataDictionaryName
    order by page, y1 desc, y2 desc;
quit;

/*--------------------------------------------------------------------------------------------------*
*       Step 4: Adjust annotation position in Blank CRF
*--------------------------------------------------------------------------------------------------*/
*------------------- Adjust comments rectangular size and position --------------------;
%let kepvar = annotation annotation_row annotation_col value order form formOID fieldOID PreText ControlType DataDictionaryName 
         UnitDictionaryName DefaultValue UserDataString x1 y2 y2_next y_diff page page_count entry_count j i column row deleteFlag firstDCM;

data aCRF_4 aCRF_4_note;
    retain &kepvar;
    set aCRF_3;
    by page descending y1 descending y2;
    Annotation = prxchange('s/\|\|/\$/io',-1,Annotation);    
    y_diff     = y2-y2_next-(ifn(label_flag='Y',1,0)*12);
    row        = count(Annotation,'$')+1;    
    do j = -1 to - row by -1;
        Annotation_row = strip(scan(Annotation,j,'$'));
        value          = ifc(prxmatch('/^{(.+)}.+/o',strip(Annotation_row)),prxchange('s/^{(.+)}.+/$1/io',-1,strip(Annotation_row)),'');
        column         = count(Annotation_row,'|')+1;
        do i = -1 to - column by -1;
            Annotation_col = strip(scan(prxchange('s/^{.+}(.+)/$1/o',-1,strip(Annotation_row)),i,'|'));
            if  prxmatch('/^NOTE:/io',strip(Annotation_col)) then output aCRF_4_note;
            else output aCRF_4;
        end;
    end;
    keep &kepvar; 
run;

data aCRF_4;
    set aCRF_4;
    where ^missing(y2) and ^missing(annotation_col);
     /* Calculate the width of comments rectangular box */
     width  = GetWidth(strip(Annotation_col) , 'Arial','Bold Italic','10');
     /* Calculate the height of comments rectangular box */
     height = 10;    
run;    
data aCRF_4;
    set aCRF_4;
    DefaultWidth   = GetWidth(strip(DefaultValue) , 'Times','Normal','10');  
run; 
data aCRF_4;
    set aCRF_4;
    UserDataWidth   = GetWidth(strip(UserDataString) , 'Times','Normal','10');
run; 
data aCRF_4;
    set aCRF_4;
    PreTextWidth   = GetWidth(strip(PreText) , 'Times','Normal','10');
    if PreTextWidth> 255 then PreTextWidth=255;
run; 

proc sql;
    create table aCRF_5 as 
    select a.*, input(b.ordinal,best.) as value_ord, b.UserDataString as value_crf
    from aCRF_4 as a 
        left join DataDictionaryEntries(where=(^missing(CodedData))) as b
            on a.DataDictionaryName=b.DataDictionaryName and a.value=b.CodedData
    order by page, y2 desc, j desc, i desc;
quit; 
data aCRF_5;
    set aCRF_5;
    value_width    = GetWidth(strip(value_crf) , 'Times','Normal','10');
run; 

/* Add Domain flag  */
%let DM = 'SUBJID','RFSTDTC','RFENDTC','RFXSTDTC','RFXENDTC','RFICDTC','RFPENDTC','DTHDTC','DTHFL','SITEID','INVID','INVNAM',
          'BRTHDTC','AGE','AGETXT','AGEU','SEX','RACE','ETHNIC','SPECIES','STRAIN','SBSTRAIN','ARMCD','ARM','ACTARMCD','ACTARM',
          'SETCD','COUNTRY','DMDTC','DMDY','AGEU = YEARS';
data aCRF_5_1 check11;
    set aCRF_5;
    by page descending y2 descending j descending i ;
    id = prxparse('/([A-Z]{4,})/o');
    if prxmatch(id,Annotation_col) then Anno = prxposn(id,1,Annotation_col);

    if Annotation_col in (&DM) then Domain ='DM';
    else if Annotation_col = "MISSING" then domain = "MI";
    else if compress(strip(Annotation_col),,'kw')='[NOT SUBMITTED]' then Domain="";
    else if prxmatch('/^NOTE:/o',strip(Annotation_col)) then Domain="";
    else if prxmatch('/SUPP\w\w/o',Annotation_col) and find(Annotation_col,'IDVAR') then Domain = prxchange('s/.+SUPP(\w\w).+/$1/o',-1,Annotation_col);
    else if prxmatch('/RELREC/o',Annotation_col) then Domain = "";
    else if lengthn(anno) >1 then Domain = substr(strip(Anno),1,2);
    output;

    if missing(domain) and not prxmatch('/(^NOTE:)|(RELREC)/o',strip(Annotation_col)) 
        and compress(strip(Annotation_col),,'kw') ne '[NOT SUBMITTED]'  then do;
        n11 +1;
        call symputx("check11_"||cats(n11),"{"||strip(annotation)||"} in "||strip(formOID),'g');
        call symputx("ck11",cats(n11),'g');
        output check11;
    end; 
run;
proc sql;
    create table aCRF_5_2 as 
    select a.*,
           coalescec(a.Domain_,b.Domain_field) as Domain length=2
    from aCRF_5_1(rename=(Domain=Domain_)) as a 
            left join (select distinct Domain as Domain_field,formOID,fieldOID from aCRF_5_1(where=(^missing(Domain))) group by formOID,fieldOID having count(distinct Domain) =1) as b 
                on a.formOID=b.formOID and a.fieldOID=b.fieldOID;
quit;

/* Delete no necessary annotation */
proc sql;
    create table delete_1 as 
    select distinct formOID, domain, count(*) as count
    from aCRF_5_1(where=(^missing(domain) and domain not in ('DM','CO','SE','SV','MI'))) 
    group by formOID,domain;

    create table delete_2 as 
    select distinct formOID ,domain
    from aCRF_5_1(where=(^missing(domain) and domain not in ('DM','CO','SE','SV','MI'))) 
    where prxmatch('/[A-Z][A-Z](TERM|TRT|TEST|TESTCD|OBJ)/o',annotation_col);

    create table delete_3 as 
    select a.*, c.count
    from aCRF_5_1(where=(^missing(domain) and domain not in ('DM','CO','SE','SV','MI'))) as a
        left join delete_2 as b 
            on a.formOID=b.formOID and a.domain=b.domain
        left join delete_1 as c 
            on a.formOID=c.formOID and a.domain=c.domain
    where missing(b.formOID) and c.count <3
    order by page, y2 desc, j desc, i desc;

    create table aCRF_5_3 as 
    select * from aCRF_5_2
    except all corr
    select * from delete_3
    order by page, y2 desc, j desc, i desc;
quit;

data aCRF_5_4;
    set aCRF_5_3(in=a) delete_3(in=b drop=count) aCRF_4_note(in=c);
    by page descending y2 descending j descending i ;
    retain flag1 flag2;
    if first.y2 then do;delete_row=.; flag1=.;end;
    if first.j  then do;delete_col=.; flag2=.; end;
    if b or c then do; flag1=j;flag2=i; delete_col+1; end;
    if a and j< flag1 then do; j+1; row=row-1;end;
    if a and i< flag2 then do; i+delete_col; column=column -delete_col;end;
    if a and not (^missing(value) and missing(value_ord)) then output;
run;

data aCRF_6; 
    set aCRF_5_4;
    by page descending y2 descending j descending i ;
    retain x1_last;
    if first.y2 then call missing(of x1_last);
    *------------------- Calculate rectangular box position --------------------;
    if ControlType in ('CheckBox','DateTime','Dynamic SearchList','Text','LongText') then do;
            /* Calculate the x-axis position of comments retangular box */
            if DefaultWidth > 150 then DefaultWidth = 150;
            if (i =-1 and column=1 and width <=151 and DefaultWidth=0) then do;
                x2_        = x1 -(151/2-width/2) - ifn(missing(UnitDictionaryName),0,30);
                x1_        = x1 -(151/2+width/2)- ifn(missing(UnitDictionaryName),0,30);
            end;
            else if i =-1 then do;
                x2_        = x1 - ifn(DefaultWidth ne 0,DefaultWidth+2,0)- ifn(missing(UnitDictionaryName),0,30);
                x1_        = x1 - width - ifn(DefaultWidth ne 0,DefaultWidth+2,0)- ifn(missing(UnitDictionaryName),0,30);
            end;
            else do;
                x2_        = x1_last - 5;
                x1_        = x1_last - width -5;
            end;
            x1_last = x1_;
            /* Calculate the y-axis position of comments retangular box */
            if y2_next ne 0 and y_diff>20 then y2_ = y2- (y2-y2_next )/3;
            else y2_ = y2-1;
            y1_ = y2_-height;
            output;
    end;

    else if ControlType in ('DropDownList','RadioButton','RadioButton (Vertical)') then do;
        if missing(value) then do;
            /* Calculate the x-axis position of comments retangular box */
            if UserDataWidth > 150 then UserDataWidth = 150;

            if i =-1 then do;
                x2_        = x1 - UserDataWidth -20;
                x1_        = x1 - width - UserDataWidth -20;
            end;
            else do;
                x2_        = x1_last - 5;
                x1_        = x1_last - width -5;
            end;
            x1_last = x1_;
            /* Calculate the y-axis position of comments retangular box */
            if y2_next ne 0 and y_diff>20 then y2_ = y2- (y2-y2_next )/3;
            else if y2_next = 0 and page_count = 1 then y2_ = y2- 17*(entry_count*2/5);
            else if y2_next = 0 and page_count > 1 then y2_ = (y2 +100)/2;
            else y2_ = y2;
            y1_ = y2_-height;
            output;
        end;     
        else if ^missing(value) then do;
            /* Calculate the x-axis position of comments retangular box */
            if i =-1 then do;
                x2_        = x1 - value_width -20;
                x1_        = x1 - width - value_width -20;
            end;
            else do;
                x2_        = x1_last - 5;
                x1_        = x1_last - width -5;
            end;
            x1_last = x1_;
            /* Calculate the y-axis position of comments retangular box */
            if value_ord=1 then reduce=2;else reduce=0;

            y2_ = y2- (value_ord-1)*17 -reduce;
            y1_ = y2_- 10;  
            output;
        end; 
    end; 
run;

proc sql;
    create table translation_1 as 
    select form, formOID, fieldOID, x2_, y1_, y2_
    from aCRF_6(where=(missing(value))) as a
    group by formOID, fieldOID
    having x2_=max(x2_);

    create table translation_2 as 
    select a.*, a.x2_ - b.x1_ as diff1
    from translation_1 as a 
        left join aCRF_6(where=(^missing(value))) as b 
            on a.formOID=b.formOID and a.fieldOID=b.fieldOID
    where a.x2_>b.x1_>. and not (a.y1_ >b.y2_ >. or .<a.y2_ <b.y1_)
    group by a.formOID, b.fieldOID
    having diff1=max(diff1);

    create table translation_3 as 
    select * , 95+PreTextWidth- x1_ as diff2
    from aCRF_6(where=(ControlType in ('CheckBox','DateTime','Dynamic SearchList','Text','LongText')))
    where calculated diff2>0
    group by formOID, fieldOID
    having diff2=max(diff2);

    create table aCRF_6_1 as 
    select a.*, 
            case when missing(a.value) and ^missing(b.diff1) then a._x1 - b.diff1-4 
                 when ^missing(c.diff2) then a._x1 + c.diff2
            else a._x1 end as x1_,
            case when missing(a.value) and ^missing(b.diff1) then a._x2 - b.diff1-4 
                 when ^missing(c.diff2) then a._x2 + c.diff2
            else a._x2 end as x2_
    from aCRF_6(rename=(x1_ = _x1 x2_ =_x2) keep=Annotation_col form formOID PreText fieldOID page order Annotation_col x2_ x1_ y2_ y1_ y2 height Domain Anno value deleteFlag firstDCM) as a
        left join translation_2 as b 
            on a.formOID=b.formOID and a.fieldOID=b.fieldOID
        left join translation_3 as c 
            on a.formOID=c.formOID and a.fieldOID=c.fieldOID
            ;
quit;

data aCRF_6_2;
    set aCRF_6_1;
    if prxmatch('/[A-Z][A-Z]TEST[^C][^D]/o',Annotation_col) and not find(Annotation_col,'=') then do;
        x1_ = x1_ - (x2_ - 88);
        x2_ = 88;
        y1_ = y2;
        y2_ = y2-height;
    end;
run;
*------------------- Add domain title and background color --------------------;
/* adjust backgroud color */
proc sql;
    create table DomainCount as 
    select distinct count(*) as DomainCount,formOID,Domain
    from aCRF_6(where=(^missing(domain) and domain ne "MI"))
    group by formOID,Domain
    order by formOID,DomainCount desc;
quit;
data DomainColor;
    set DomainCount;
    by formOID descending DomainCount;
    length color $200;
    if first.formOID then n=.;
    n+1;
    if n = 1 then color ="#0000FF";
    else if n = 2 then color = "#FF0000";
    else if n = 3 then color = "#40AB54";
    else if n = 4 then color = "#000000";
run;
/* Assign domain color */
proc sql;
    create table aCRF_7 as 
    select a.*, case when missing(a.domain) or a.domain="MI" then "#0000FF" else b.color_ end as color
    from aCRF_6_2 as a left join DomainColor(rename=color=color_) as b
    on a.formOID =b.formOID and a.Domain=b.Domain;
quit;

/* Add domain title in each form */
proc sql;
    create table DomainTitle1 as 
    select a.*, b.color, b.n,a.Domain||' = '||put(a.Domain,$DATADEF.) as Annotation_col length=200,
            90 as x1_,
            90+GetWidth(strip(calculated Annotation_col) , 'Arial','Bold Italic','10')*1.2 as x2_
    from (select distinct page,formOID,Domain from aCRF_6_2(where=(strip(Annotation_col) ne "[NOT SUBMITTED]" and ^missing(domain) and Annotation_col ne "MISSING"))) as a 
         left join DomainColor as b 
            on a.formOID=b.formOID and a.Domain=b.Domain
    order by formOID,page,n desc;
quit;

data DomainTitle2;
    set DomainTitle1;
    by formOID page descending n;
    retain y1_;
    if first.page then y1_ = 710;
    else y1_ = y1_ +18;
    y2_ = y1_+13;
run;

*------------------- Add refer to --------------------;
proc sort data=fdf_adjust6;by fieldOID DCM page;run;
data DCM_Repeat;
    set fdf_adjust6;
    by fieldOID DCM page;
    if not first.DCM then output DCM_Repeat;
run;

/* For repeated DCM forms */
proc sql;
    create table refer_a1 as 
    select a.*, b.refer_page, b.page_count
    from 
    (select distinct DCM, formOID, form, page from DCM_Repeat) as a 
    left join
    (select distinct DCM, form, count(distinct page) as page_count,
            case when calculated page_count = 1 then page else . end as refer_page
        from fdf_adjust8 where firstDCM='Y' group by formOID) as b 
    on a.DCM = b.DCM;
quit;
data refer_a2;
    set refer_a1;
    length Annotation_col $200;
    if page_count= 1 then Annotation_col = "For Annotations, Please refer CRF Page "||cats(refer_page-1);
    else Annotation_col = "For Annotations, Please refer CRF Page XX";
run;

/* For Timepoint forms */
proc sort data=BlkBook_2 out=refer_b1(keep=form formOID page);
    by descending page form;
run;
data refer_b2;  /* Add record for long-break forms */
    set refer_b1;
    by descending page form;
    page_ = lag(page);
    if missing(page_) then page_ = page+5;
    do i = 1 to page_-page;
        if i ne 1 then page=page+1;
        Output;
    end;
    keep page form formOID;
run;
proc sort;by page;run;

proc sql;
    create table refer_b3 as 
    select a.*
    from refer_b2 as a
        left join (select distinct formOID, form, page from fdf_adjust2) as b 
            on a.page=b.page
        left join (select distinct formOID, form from refer_a2) as c 
            on a.formOID=c.formOID
    where missing(b.page) and missing(c.formOID)
    order by formOID, page;
quit;
data refer_b4;
    set refer_b3;
    by formOID page;
    retain refer_page;
    if first.formOID then refer_page=page-1;
    length Annotation_col $200;
    Annotation_col = "For Annotations, Please refer CRF Page "||cats(refer_page-1);
run;

/*--------------------------------------------------------------------------------------------------*
*       Step 5: Output final annotation comments
*--------------------------------------------------------------------------------------------------*/
data aCRF_8;
    set aCRF_7(in=a) DomainTitle2(in=b) NotSub(in=c) refer_a2(in=d) refer_b4(in=e);
    length comment background style page_ coordinate $200;
    if a or c or d or e then font="10pt";if b then font="12pt";
    comment     = prxchange('s#/#\/#io',-1,strip(Annotation_col));
    background  = "0.75 1 1";
    style       = "font: italic bold Arial "||font||"; text-align:left; color:"||strip(color);
    page_       = put(page-1,best. -l);
    coordinate  = catx(' ',put(x1_,best. -l),put(y1_,best. -l),put(x2_,best. -l),put(y2_,best. -l));

    if c then do;
        color       = "#0000FF";
        comment     = "[NOT SUBMITTED]";
        coordinate  = "250 651.7 340 661.95";
        style       = "font: italic bold Arial "||font||"; text-align:left; color:"||strip(color);
    end;
    if d or e then do;
        color       = "#0000FF";
        coordinate  = "290 651.7 500 661.95";
        style       = "font: italic bold Arial "||font||"; text-align:left; color:"||strip(color);
    end;        
run;

%MakeFDF(data       = aCRF_8,
          output     = &PorojectPath/fdf_final.fdf,
          page       = page_,
          background = background,
          comment    = comment,
          style      = style,
          coordinate  = coordinate);
 
%EXIT:

%macro message(check=,message=);
    %if %symexist(ck&check) %then %do;
        %do i = 1 %to &&ck&check;
            %if &i=1 %then %put &message;
            %put %str(        ) %bquote(&&check&check._&i);
        %end;
    %end;
%mend;

%if %symexist(ck1) or %symexist(ck2) or %symexist(ck3)or %symexist(ck4)or %symexist(ck5) 
    or %symexist(ck6) or %symexist(ck7) or %symexist(ck8)  %then %do;

    %PUT ============================================================;
    %PUT  ;
     %message(check=1,message=Below Form Exist in RAVE Bookmarks but Not in ALS:);
     %message(check=2,message=Below Form Exist in ALS but Not in RAVE bookmarks:);
     %message(check=3,message=Below Form Exist in Blank bookmarks but Not in ALS:);
     %message(check=4,message=Below Form Exist in ALS but Not in Blank bookmarks:);
     %message(check=5,message=Check Box in Below Form has Value More Than 40:);
     %message(check=6,message=Possible Wrong Field Position in Below Form:);
     %message(check=7,message=Field in Below Form Exists in ALS but not in CRF:);
     %message(check=8,message=Field in Below Form Exists in CRF but not in ALS:);
     %message(check=9,message=Field in Below formOID Exist in Previous Form:but not in Update Form:);
     %message(check=10,message=Field in Below formOID Exist in Update Form:but not in Update Form:);
     %message(check=11,message=Below Annotation Missing Domain:);

    %PUT  ;
    %PUT ============================================================;

%END;

%mend;

%AutoGenaCRF;