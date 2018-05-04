
%let study=231794;
%let program = \\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\04_Automatic_aCRF\program;
%let path=\\Cn-sha-hfp001.ap.pxl.int\vol5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\02_Project Reference\231794;
libname  width "\\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\04_Automatic_aCRF\output";


/*--------------------------------------------------------------------------------------------------*
*       Step 1: Get Field Position In Blank CRF.
*--------------------------------------------------------------------------------------------------*/
options cmplib=width.functions;
%include "&program\GetField.sas";
%GetField(      path     =&path,
                ALS      =&path\231794,
                RaveBook =RaveCRF_Bookmark,
                RaveLink =RaveCRF_Links,
                BlkBook  =BlankCRF_Bookmark,
                NOLOCK   =N
                );


data fdf_adjust2;
    set fdf_adjust;
    by form page x1 x2 descending y1 descending y2;
    length comment background style page_ coordinate $200;
    comment    = strip(put(order,best. -l))||': '||strip(PreText);
    background = "0.25 0.666656 0.333328";
    style      = 'font: italic bold Arial 6.0pt; text-align:left; color:#0000FF';
    page_      = put(page-1,best. -l);
    coordinate = catx(' ',put(x1,best. -l),put(y2-6,best. -l),put(x1+85,best. -l),put(y2,best. -l));
run;

/*--------------------------------------------------------------------------------------------------*
*       Step 2: Update possible wrong field position
*--------------------------------------------------------------------------------------------------*/
%include "&program\MakeFDF.sas";
%MakeFDF(data       = fdf_adjust2,
          output     = &path\fdf_adjust.fdf,
          page       = page_,
          background = background,
          comment    = comment,
          style      = style,
          coordinate  = coordinate);

%include "&program\ReadFDF.sas";
%ReadFDF(file=&path\fdf_adjust.fdf, out=fdf_update1);
data fdf_update2;
    set fdf_update1;
    where background="0.25 0.666656 0.333328";
    order = input(scan(comment,1,':'),best.);
run;

proc sql;
    create table fdf_update3 as 
    select a.*, b.form as form_
    from fdf_update2 as a 
        left join (select distinct form, page_ from fdf_adjust2) as b 
            on a.page = b.page_
    order by page,order;
quit;
data fdf_update3;
    set fdf_update3;
    by page order;
    length form $200;
    retain form;
    if ^missing(form_) then form = form_;
run;

proc sort data=fdf_update3;by form order;run;
proc sort data=fdf_adjust2;by form order;run;

data fdf_update4;
    merge fdf_adjust2(drop=x2 y1 y2 background style coordinate page page_ in=a)
          fdf_update3(keep=form page order x2 y1 y2 rename=page=page_old in=b);
    by form order;
    if a and not b then put "WARNING: Field (" comment "exist in adjust" form "but not in update";
    if b and not a then put "WARNING: Field (" comment "exist in update" form "but not in adjust";
    page = input(page_old,best.);
run;

/* Add check info */
proc sql;
    create table fdf_field1 as 
    select *, case when count(distinct ISlog) >1 and ISlog='FALSE' then 'Y'
                   else 'N' end as logFlag
    from fdf_update4 
    group by FormOID
    order by FormOID,page,order;
quit;

proc sql;
    create table Datadictionary_2 as 
    select a.*, count(CodedData) as dic_count, input(ordinal,best.) as ordinal_
    from DataDictionaryEntries(where=(input(ordinal,best.) <=40)) as a 
        left join (select distinct DataDictionaryName ,
                            case when prxmatch('/\d/o',CodedData) and prxmatch('/\d/o',UserDataString) then 'Y'
                                 when prxmatch('/[A-z]/o',CodedData) and prxmatch('/[A-z]/o',UserDataString) then 'Y'
                                 when upcase(CodedData) = upcase(UserDataString) then 'Y'
                                 else '' end as flag
                    from DataDictionaryEntries 
                    where calculated flag='Y') as b 
            on a.DataDictionaryName=b.DataDictionaryName
    where missing(b.DataDictionaryName) and ^missing(a.DataDictionaryName)
    group by a.DataDictionaryName
    order by DataDictionaryName, ordinal_;
quit;

data Datadictionary_3;
    set Datadictionary_2;
    by DataDictionaryName ordinal_;
    length Diction $500;
    retain Diction;
    if first.DataDictionaryName then Diction='';
    Diction = catx(byte(13),Diction,CodedData);
    if last.DataDictionaryName then output;
    keep DataDictionaryName Diction dic_count;
run;

proc sql;
    create table fdf_field2 as 
    select a.*, b.Diction, b.dic_count
    from fdf_field1 as a left join Datadictionary_3 as b 
    on a.DataDictionaryName=b.DataDictionaryName
    order by FormOID,page,order;
quit;

data fdf_field2;
    set fdf_field2;
    form = compress(form,,'kw');    
    if missing(dic_count) then dic_count=0;
    if ControlType = 'CheckBox' then value='Checked';
    else if ControlType = 'DateTime' then value='Time';
    else if ControlType in ('Dynamic SearchList','Text','LongText') then value='Entered';
    else if ControlType in ('DropDownList','RadioButton','RadioButton (Vertical)') then value='Coded';

    if find(DataFormat,'$') then type='Char';
    else if prxmatch('/^\d|\.$/io',strip(DataFormat)) then type='Num';
    else if ^missing(DataFormat) then type='Date';
    else type='Char';  
    comment_1    =catx('; ',FieldOID,value,type, AnalyteName );
run;

data fdf_field2;
    set fdf_field2;
    width_form = GetWidth(strip(form) , 'Times','Bold Normal','10');
run;

data fdf_field2;
    set fdf_field2;
    width_formOID = GetWidth(strip(FormOID) , 'Arial','Bold Italic','10');
run;

data fdf_field2;
    set fdf_field2;
    width_comment = GetWidth(strip(comment_1) , 'Arial','Bold Italic','10');
run;

data fdf_field3;
    set fdf_field2(drop=comment);
    by FormOID page order;
    length background style page_ coordinate value type $200 comment $1000;
    form = compress(form,,'kw');    
    if missing(dic_count) then dic_count=0;
    if ControlType = 'CheckBox' then value='Checked';
    else if ControlType = 'DateTime' then value='Time';
    else if ControlType in ('Dynamic SearchList','Text','LongText') then value='Entered';
    else if ControlType in ('DropDownList','RadioButton','RadioButton (Vertical)') then value='Coded';

    if find(DataFormat,'$') then type='Char';
    else if prxmatch('/^\d|\.$/io',strip(DataFormat)) then type='Num';
    else if ^missing(DataFormat) then type='Date';
    else type='Char';

    comment_1    =catx('; ',FieldOID,value,type, AnalyteName );

    if first.page then do;
        comment    = FormOID;
        background = "1.0 0.75 0.0";
        style      = "font: italic bold Arial 10.0pt; text-align:center; color:#0000FF";
        page_      = put(page,best. -l);
        coordinate = catx(' ',put(125+width_form,best. -l)
                             ,put(664,best. -l)
                             ,put(125+width_form+width_formOID+20,best. -l)
                             ,put(674,best. -l));
        output;
    end;
    if ^missing(FieldOID) then do;
        comment    = catx(byte(13),comment_1,Diction);
        if logFlag='N' then background = "1.0 0.75 0.0";
        else background = "1.0 0.0 0.0";
        style      = "font: italic bold Arial 8.0pt; text-align:left; color:#0000FF";
        page_      = put(page,best. -l);
        coordinate = catx(' ',put(x1,best. -l)
                             ,put(y2-8-10*dic_count,best. -l)
                             ,put(x1+width_comment*0.8,best. -l)
                             ,put(y2,best. -l));
        output;
    end;        
run;


%MakeFDF(data       = fdf_field3,
          output     = &path\fdf_field.fdf,
          page       = page_,
          background = background,
          comment    = comment,
          style      = style,
          coordinate  = coordinate);