/*--------------------------------------------------------------------------------------------------*
* Step 1: Read bookmarks and links txt file and update page info accordingly
*--------------------------------------------------------------------------------------------------*/
%let study   =229797;
%let path  =\\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\04_Automatic_aCRF\reference materials\aCRF\Combined with ALS\&study.;
%let ALS   =\\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\04_Automatic_aCRF\reference materials\ALS\&study.;
%let program =\\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\04_Automatic_aCRF\program;

options cmplib=width.functions;

filename RaveBook "&path\RaveCRF_Bookmark.txt";
filename RaveLink "&path\RaveCRF_Links.txt";
filename BlkBook "&path\BlankCRF_Bookmark.txt";
libname width "\\Cn-sha-hfp001.ap.pxl.int\vol5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\04_Automatic_aCRF\output";
libname out "\\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\04_Automatic_aCRF\reference materials\aCRF\Combined with ALS\define";
%include "&program\GetField.sas";
%GetField(      path     =&path,
                ALS      =&ALS,
                RaveBook =RaveCRF_Bookmark,
                RaveLink =RaveCRF_Links,
                BlkBook  =BlankCRF_Bookmark,
                RaveCRF  =RaveCRF,
                NOLOCK   =N
                );

/*--------------------------------------------------------------------------------------------------*
* Step 3: We need to output ASL field as PDF comments(FDF) and import comments into blankCRF,
          then we will need to adjust some special form manually to adjust some positions of fields
*--------------------------------------------------------------------------------------------------*/
data fdf_adjust2;
    set fdf_adjust;
    by form page x1 x2 descending y1 descending y2;
    length comment background style page_ coordinate $200;
    comment    = strip(put(order,best. -l))||': '||strip(PreText);
    background = "0.25 0.666656 0.333328";
    style      = 'font: italic bold Arial 10.0pt; text-align:left; color:#0000FF';
    page_      = put(page-1,best. -l);
    coordinate = catx(' ',put(x1,best. -l),put(y1+5,best. -l),put(x2+GetWidth(strip(comment) , 'Arial','Bold Italic','10'),best. -l),put(y2,best. -l));
run;
%include "&program\make_fdf.sas";
%make_fdf(data       = fdf_adjust2,
          output     = &path\fdf_adjust.fdf,
          page       = page_,
          background = background,
          comment    = comment,
          style      = style,
          coordinate  = coordinate);



%include "&program\read_fdf.sas";
%read_fdf(file=&path\&study..fdf, out=fdf);
data define_1a; /* Field */
    set fdf;
    where background = "0.25 0.666656 0.333328";
    comment = comment;
    num     = input(prxchange('s/(^\d[\d|\.]*)[^\d|\.].+/$1/io',-1,strip(comment)),best.);
    page_   = input(page,best.)+1;
run;
proc sort nodupkey;by _all_;run;

data define_1b; /* Annotation */
    set fdf;
    where prxmatch('/^\d/o',strip(comment)) 
          and not prxmatch('/AnnotatedSDTM/io',comment)
          and background ne "0.25 0.666656 0.333328";
    comment = comment;
    length comment_ $500;
    num     = prxchange('s/(^\d[\d|\.]*)[^\d|\.].+/$1/io',-1,strip(comment));
    comment_= prxchange('s/(^\d[\d|\.]*)([^\d|\.].+)/$2/io',-1,strip(comment));
    comment_= prxchange('s/ *(=) */ $1 /io',-1,comment_);
    num_int = int(input(num,best.));
    num_dec = ifn(prxmatch('/\d+\.\d+/o',num),input(prxchange('s/\d+\.(\d+)/$1/o',-1,num),best.),0);

    x1      = input(scan(coordinate,1,' '),best.);
    x2      = input(scan(coordinate,3,' '),best.);
    page_   = input(page,best.)+1;
    num_    = input(catx('.',put(num_int,best. -l),put(num_dec,z2. -l)),best.);
    drop num;
    rename num_=num;
run;
proc sort;by page_ num;run;

proc sql;
    create table als_update1 as 
    select a.*, b.form as form_
    from define_1a as a 
        left join BlkBook_4 as b 
            on a.page_ = b.page
    order by page_;
quit;

data als_update2;
    set als_update1;
    by page_;
    length form $400;
    retain form;
    if ^missing(form_) then form = form_;
run;

proc sql;
    create table als_update3 as 
    select a.*, b.FieldOID,b.PreText,b.formOID,b.DataDictionaryName
    from als_update2 as a left join fdf_adjust2 as b 
    on a.form=b.form and a.num=b.order
    order by page_, num;
quit;

proc sql;
    create table define_2 as 
    select a.*, b.FieldOID,b.PreText,b.form, b.formOID, b.DataDictionaryName, c.CodedData, c.ordinal
    from define_1b as a 
        left join als_update3 as b
            on a.page_=b.page_ and a.num_int=b.num
        left join DataDictionary as c 
            on b.DataDictionaryName=c.DataDictionaryName and put(a.num_dec,best. -l)=c.ordinal
    order by a.page_ ,b.FieldOID, a.num_dec, a.x1 ,a.x2
;
quit;

/* proc sql;
    create table define_3a as 
    select *
    from define_2(where=(num_dec>0))
    group by formOID, FieldOID, num_dec
    having count(*)>1
    order by page_ ,FieldOID, num_dec, x1 ,x2;

    create table define_3b as 
    select * from define_2
    except all corr
    select * from define_3a
    order by page_ ,FieldOID, num_dec, x1 ,x2;
quit; */


data define_3a;
    length TopicValue_ $400;
    set define_2;
    where ^missing(CodedData);
    by page_  FieldOID  num_dec  x1  x2;
    retain TopicValue_;
    if first.num_dec then TopicValue_ ='';
    TopicValue_ = catx(' | ',TopicValue_,comment_);
    if last.num_dec then do;
        TopicValue_ = catx(' ','{'||strip(CodedData)||'}',TopicValue_);
        output;
    end;
run;

data define_3b;
    length TopicValue_ $400;
    set define_2;
    where missing(CodedData);
    by page_  FieldOID  num_dec  x1  x2;
    retain TopicValue_;
    if first.num_dec then TopicValue_ ='';
    TopicValue_ = catx(' | ',TopicValue_,comment_);
    if last.num_dec then do;
        TopicValue_ = catx(' ',TopicValue_);
        output;
    end;
run;

data define_4;
    length TopicValue $400;
    set define_3a(in=a) define_3b(in=b);
    by page_  FieldOID  num_dec  x1  x2;
    retain TopicValue;
    if first.FieldOID then TopicValue ='';
    TopicValue = catx(' || '||byte(13)||byte(10),TopicValue,TopicValue_);
    if last.FieldOID then output;
run;

data _null_;
    set define_2;
    if missing(FieldOID) then put "WARNING: Missing fieldOID in form:" form "in page:" page_;
    if num_dec ne 0 and missing(CodedData) then put "WARNING: Missing CodedData in Form:" FormOID "Field:" FieldOID;
run; 

data out.define_&study.;
    retain source TopicValue form formOID PreText fieldOID DataDictionaryName num;
    set define_4;
    if ^missing(formOID);
    keep TopicValue source fieldOID PreText form formOID DataDictionaryName num;
run;

/* Set All */
data define_all;
    length source TopicValue form formOID PreText fieldOID DataDictionaryName $2000;
    set out.define_:;
    if prxmatch('/^((\d|[A-Z])+_(\d|[A-Z])+_(\d|[A-Z])+)/o',strip(formOID)) 
        then DCM = prxchange('s/^((\d|[A-Z])+_(\d|[A-Z])+_(\d|[A-Z])+)_\w+/$1/io',-1,formOID);
    formOID_ = coalescec(DCM,formOID);
    where formOID not in ('PR_ONC_002YN','PR_ONC_004YN');    
run;

data define_form;
    length source $1000;
    set out.form_:;
    if prxmatch('/^((\d|[A-Z])+_(\d|[A-Z])+_(\d|[A-Z])+)/o',strip(formOID)) 
        then DCM = prxchange('s/^((\d|[A-Z])+_(\d|[A-Z])+_(\d|[A-Z])+)_\w+/$1/io',-1,formOID);
    formOID_ = coalescec(DCM,formOID); 
    PAREXEL_REMINDER ="";
    Selection_reason ="";
    Select_Flag      ="";
run;
proc sort nodupkey;by formOID_ source comment;run;

data define_form1;
    set define_form;
    by formOID_ source comment;
    length comment_all $500;
    retain comment_all;
    if first.source then comment_all = "";
    comment_all = catx('|'||byte(13)||byte(10),comment_all,comment);
    if last.source then output;
run;

proc sort data=define_form1 out=define_form1 nodupkey;
    by formOID_ comment_all ;
run;
proc sql;
    create table define_form2 as 
    select *,count(*) as count
    from define_form1 
    group by formOID_
    order by formOID_, comment_all;
quit;
data define_form2;
    set define_form2;
    by formOID_ comment_all;
    if count>1 then do;
        if first.formOID_ then count_flag +1;
    end;
    order1 = formOID_;
    order2 = comment_all;
run;


data define_notsub;
    length source form formOID $400;
    set out.notsub_:;   
    PAREXEL_REMINDER ="";
    Selection_reason ="";
    Select_Flag      ="";    
    where formOID not in ('CM_ONC_001','DM_ONC_001','FA_ONC_002','PE_GL_900','SV_VAC_001','TB','TR_ONC_006');  
    order1 = formOID;     
run;
proc sort data=define_notsub out=define_notsub1 nodupkey;
    by formOID;
run;


proc sql;
    create table draft_1 as 
    select *,count(distinct source) as field_count
    from define_all
    group by formOID_, FieldOID;

    create table draft_2 as 
    select *, count(distinct PreText) as PreText_count, 
              count(distinct TopicValue) as TopicValue_count, 
              min(num) as num_min
    from draft_1
    group by formOID_, fieldOID
    order by formOID_, FieldOID;

    create table draft_3 as 
    select *, count(distinct source) as source_count
    from draft_2
    group by formOID_
    order by formOID_, FieldOID;

    create table draft_4 as 
    select *, count(distinct source) as anno_count
    from draft_3
    group by formOID_, FieldOID, PreText, TopicValue
    order by formOID_, fieldOID;
quit;

proc sort nodupkey;by formOID_ fieldOID PreText TopicValue;run;

data draft_5;
    set draft_4;
    by formOID_ FieldOID;
    order1 = source_count;
    order2 = formOID_;
    order3 = num_min;
    order4 = fieldOID;
    order5_= anno_count;
    order5 = input(source,best.);
    order6 = formOID;
    PreText = compress(PreText,,'kw');
run;
proc sort;by descending order1 order2 order3 order4 descending order5_ order5 order6;run;


data draft_6;
    set draft_5;
    by descending order1 order2 order3 order4 descending order5_ order5 order6;
    if TopicValue_count>1 then do;
        if first.order4 then FieldOID_N1+1;
    end;
    if TopicValue_count=1 then do;
        if first.order4 then FieldOID_N2+1;
    end;
    if first.order4 then FieldOID_N3 +1;
run;


/* Import reviewed library */
proc import datafile="C:\Users\chase\Documents\Test\aCRF Definition draft_JY.xlsx" out=define_jy dbms=excel replace;
            sheet   = 'Draft aCRF Definition';
run;
data define_jy;
    set define_jy;
    array test(*) _Char_;
    do i = 1 to dim(test);
      test(i) = compress(test(i),,'kw');
    end;
run;

proc import datafile="C:\Users\chase\Documents\Test\aCRF Definition draft_BS.xlsx" out=define_bs dbms=excel replace;
            sheet   = 'Draft aCRF Definition';
run;
data define_bs;
    set define_bs;
    array test(*) _Char_;
    do i = 1 to dim(test);
      test(i) = compress(test(i),,'kw');
    end;
run;

proc sql;
    create table update as 
    select b.*, coalescec(a.Selection_reason,c.Selection_reason) as Selection_reason,
                coalescec(a.Select_Flag,c.Select_Flag) as Select_Flag,
                coalescec(a.PAREXEL_REMINDER,c.PAREXEL_REMINDER) as PAREXEL_REMINDER,
                coalescec(a.check_code,c.check_code) as check_code


    from draft_6 as b 
        left join define_jy as a 
            on compress(a.formOID,,'kw')=compress(b.formOID_,,'kw') 
            and compress(a.FieldOID,,'kw')=compress(b.fieldOID,,'kw') 
            and compress(a.Field,,'kw')=compress(b.PreText,,'kw') 
            and compress(a.Annotation,,'kw')=compress(b.TopicValue,,'kw')
        left join define_bs as c 
            on compress(c.formOID,,'kw')=compress(b.formOID_,,'kw') 
            and compress(c.FieldOID,,'kw')=compress(b.fieldOID,,'kw') 
            and compress(c.Field,,'kw')=compress(b.PreText,,'kw') 
            and compress(c.Annotation,,'kw')=compress(b.TopicValue,,'kw');
quit;


/* Output */
filename excel "\\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\04_Automatic_aCRF\reference materials\aCRF\Combined with ALS\define\aCRF Definition draft1.xlsx";
ods excel file=excel style=seaside
          options(
                 autofilter              ='all'
                 frozen_headers          ='on'
                 sheet_interval          ='proc'
                 sheet_name              ='Draft aCRF definition'
                 tab_color               ='red'
                 autofit_height          = 'yes'
                 sheet_interval          = 'PROC');
    proc report data=update nowd style(column)={vjust=center} split="#" out=a;
        column order1 order2 order3 order4 order5_ order5 order6 Select_Flag Selection_reason check_code PAREXEL_REMINDER source_count field_count anno_count source TopicValue fieldOID PreText formOID_ form PreText_count TopicValue_count FieldOID_N1 FieldOID_N2 FieldOID_N3 color;

        define  order1                  /descending order ORDER=internal noprint;
        define  order2                  /order ORDER=internal noprint;
        define  order3                  /order ORDER=internal noprint;
        define  order4                  /order ORDER=internal noprint;
        define  order5_                 /order descending ORDER=internal noprint;        
        define  order5                  /order ORDER=internal noprint;
        define  order6                  /order ORDER=internal noprint;

        define  Select_Flag            /display 'Select#Flag' style(column)={cellwidth=0.3in just=center width=1000% tagattr='wrap:yes'};
        define  Selection_reason       /display 'Selection#reason' style(column)={cellwidth=0.5in just=center width=1000% tagattr='wrap:yes'};     
        define  PAREXEL_REMINDER       /display 'PAREXEL#REMINDER' style(column)={cellwidth=0.5in just=center width=1000% tagattr='wrap:yes'};  
        define  check_code              /display 'Comments' style(column)={cellwidth=0.5in just=center width=1000% tagattr='wrap:yes'};                
        define  source_count            /display 'Form#count' style(column)={cellwidth=0.3in just=center};
        define  field_count             /display 'Field#count' style(column)={cellwidth=0.3in just=center};     
        define  anno_count              /display 'Anno#count' style(column)={cellwidth=0.3in just=center};                
        define  formOID_                /display 'FormOID' style(column)={cellwidth=0.8in just=center  width=1000% tagattr='wrap:yes'};
        define  fieldOID                /display 'FieldOID' style(column)={cellwidth=1in just=center  width=1000% tagattr='wrap:yes'};
        define  source                  /display 'Source' style(column)={cellwidth=0.5in just=center};
        define  form                    /display 'Form Name' style(column)={cellwidth=1.5in just=center  width=1000% tagattr='wrap:yes'};
        define  TopicValue              /display 'Annotation' style(column)={cellwidth=0.00025in just=left width=1000% tagattr='wrap:yes'};
        define  PreText                 /display 'Field' style(column)={cellwidth=2.5in just=left width=1000% tagattr='wrap:yes'};
        define  PreText_count           /display 'Field#Unique#Count' style(column)={cellwidth=0.5in just=center} ;
        define  TopicValue_count        /display 'Annotation#Unique#Count' style(column)={cellwidth=0.5in just=center};
        define  FieldOID_N1              /display noprint;
        define  FieldOID_N2              /display noprint;
        define  FieldOID_N3              /display noprint;
        define color /computed noprint;
        compute color;
            if TopicValue_count>1 and mod(FieldOID_N1,2) = 0 then call define(_row_,'style','style=[backgroundcolor=#00b0f0]');
            else if TopicValue_count>1 then call define(_row_,'style','style=[backgroundcolor=#e26b0a]');

            if TopicValue_count=1 and mod(FieldOID_N2,2) = 0 then call define(_row_,'style','style=[backgroundcolor=#00b050]');
            else if TopicValue_count=1 then call define(_row_,'style','style=[backgroundcolor=#da9694]');            

            if PreText_count > 1 and mod(FieldOID_N3,2) = 0 then call define(_row_,'style','style=[backgroundcolor=#ffcc00]');
            else if PreText_count > 1 and mod(FieldOID_N3,2) = 1 then call define(_row_,'style','style=[backgroundcolor=#d1e41c]');
        endcomp;
    run;

    ods excel options(SHEET_NAME='Form Level Annotation');
    proc report data=define_form2 nowd style(column)={vjust=center} split="#" out=a1;
        column order1 order2 Select_Flag Selection_reason PAREXEL_REMINDER source comment_all formOID_ Form count count_flag color;

        define  order1                  /order ORDER=internal noprint;
        define  order2                  /order ORDER=internal noprint;

        define  Select_Flag            /display 'Select#Flag' style(column)={cellwidth=0.3in just=center};
        define  Selection_reason       /display 'Selection#reason' style(column)={cellwidth=0.5in just=center};     
        define  PAREXEL_REMINDER       /display 'PAREXEL#REMINDER' style(column)={cellwidth=0.5in just=center};                
        define  formOID_                /display 'FormOID' style(column)={cellwidth=0.8in just=center  width=1000% tagattr='wrap:yes'};
        define  source                  /display 'Source' style(column)={cellwidth=0.5in just=center};
        define  form                    /display 'Form Name' style(column)={cellwidth=1.5in just=center  width=1000% tagattr='wrap:yes'};
        define  comment_all             /display 'Annotation' style(column)={cellwidth=0.00025in just=left width=1000% tagattr='wrap:yes'};
        define  count              /display noprint;
        define  count_flag              /display noprint;
        define color /computed noprint;
        compute color;
            if count>1 and mod(count_flag,2) = 0 then call define(_row_,'style','style=[backgroundcolor=#00b0f0]');
            else if count>1 then call define(_row_,'style','style=[backgroundcolor=#e26b0a]');
        endcomp;
    run;

    ods excel options(SHEET_NAME='Not Submitted Form');
    proc report data=define_notsub1 nowd style(column)={vjust=center} split="#" out=a2;
        column order1 Select_Flag Selection_reason PAREXEL_REMINDER source comment formOID Form;

        define  order1                  /order ORDER=internal noprint;

        define  Select_Flag            /display 'Select#Flag' style(column)={cellwidth=0.3in just=center};
        define  Selection_reason       /display 'Selection#reason' style(column)={cellwidth=0.5in just=center};     
        define  PAREXEL_REMINDER       /display 'PAREXEL#REMINDER' style(column)={cellwidth=0.5in just=center};                
        define  formOID                /display 'FormOID' style(column)={cellwidth=0.8in just=center  width=1000% tagattr='wrap:yes'};
        define  source                  /display 'Source' style(column)={cellwidth=0.5in just=center};
        define  form                    /display 'Form Name' style(column)={cellwidth=1.5in just=center  width=1000% tagattr='wrap:yes'};
        define  comment                 /display 'Annotation' style(column)={cellwidth=0.00025in just=left width=1000% tagattr='wrap:yes'};
    run;    

ods excel close;

