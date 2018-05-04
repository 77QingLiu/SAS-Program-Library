%macro GetField(PorojectPath   =,
                ALS            =,
                DictBook =,
                DictLink =,
                BlkBook        =,
                NOLOCK         =
                );
    *------------------- Define related file path --------------------;
    filename DictBook "&PorojectPath/&DictBook..txt";
    filename DictLink "&PorojectPath/&DictLink..txt";
    filename BlkBook "&PorojectPath/&BlkBook..txt";
    proc datasets memtype=data lib=work kill nolist;run;quit;

    *------------------- Read ALS --------------------;
    %macro import(out=,key=,keep=);
        proc import datafile="&ALS..xlsx" out=&out. dbms=xlsx replace;
                    sheet   = "&out.";
        run;
        %if &out = Forms %then %str(proc sort nodupkey;by OID;run;);
        data &out.;
            set &out.(&keep);
            array test(*) _Char_;
            do i = 1 to dim(test);
              test(i) = compress(test(i),,'kw');
            end;
            %if &out = Fields %then %do; /* Change logline which not following general rule */
            if formOID='CM_ONC_001' and fieldOID = "CMPRIOR_ADD" then IsLog='TRUE';
            if formOID='CM_ONC_003' and fieldOID = "CMSUBSE_ADD" then IsLog='TRUE';
            %end;
        %if &out = DataDictionaryEntries %then %do;
            ordinal_ = input(ordinal,best.);
            length = lengthn(UserDataString);
            drop ordinal;
        %end;
        run;        
    %mend;    
    /* Forms */
    %import(out=Forms,keep=);

    /* Fields */
    %import(out=Fields,keep=);

    /* DataDictionary */
    %import(out=DataDictionaryEntries,keep=%str(keep=DataDictionaryName codeddata ordinal UserDataString));

    proc sort data=DataDictionaryEntries;by DataDictionaryName descending length;run;
    data DataDictionaryEntries_2;
        set DataDictionaryEntries;
        where ordinal_ <=40;
        by DataDictionaryName descending length;
        if first.DataDictionaryName;
    run;

    proc sort data=DataDictionaryEntries;by DataDictionaryName ordinal_;run;
    data DataDictionaryEntries;
        set DataDictionaryEntries;
        by DataDictionaryName ordinal_;
        if first.DataDictionaryName then n=.;
        n+1;
        ordinal = put(n,best. -l);
        keep DataDictionaryName codeddata UserDataString ordinal;
    run;

    data DataDictionaryEntries_1;
        set DataDictionaryEntries;
        where input(ordinal,best.) > 40;
    run;

    *------------------- Define internal macros --------------------;
    %macro update_form(in_data=, out_data=, check=); /* Macro to update form names as there are discrepancies between ALS and CRF Bookmarks */
        %let n1 = &check;
        %let n2 = %eval(&check+1);
        proc sql;
            create table check_forms as 
            select distinct DraftFormName as form length=200, OID as formOID, input(ordinal_,best.) as ordinal
            from forms(where=(^missing(DraftFormName) and DraftFormActive='TRUE') rename=ordinal=ordinal_)
            order by ordinal;
        quit;
        %put &sqlobs;

        data _null_;
            set &in_data nobs=n;
            if _n_ = 1 then call symputx('InObs',cats(n));
        run;

        %if &sqlobs=&InObs %then %do;
            proc sort data=&in_data;by page;run;
            data &out_data;
                set &in_data;
                set check_forms(keep=form formOID ordinal);
            run;
            proc sort data=&out_data;by descending page form;run;
        %end;
        %else %do;
            proc sort data=&in_data;by form;run;
            proc sort data=check_forms;by form;run;
            data check_&check;
                merge &in_data(in=a) check_forms(in=b);
                by form;
                if a and not b then do;
                    n&n1. +1;
                    call symputx("check&n1._"||cats(n&n1.),strip(form),'g');
                    call symputx("ck&n1",cats(n&n1.),'g');  
                end;          
                if not a and b then do;
                    n&n2. +1;
                    call symputx("check&n2._"||cats(n&n2),strip(form),'g');
                    call symputx("ck&n2",cats(n&n2.),'g');  
                end;    
            run;
        %end;
    %mend;

    *------------------- Read bookmarks and update form names --------------------;
    data RaveBook_1;
        infile DictBook;
        input;
        length text $500;
        if ^missing(compress(_infile_,,'kw')) and _n_ >1;
        text =strip(_infile_);
        form =compress(prxchange('s/(.+)\x9+\d+$/$1/io',-1,strip(text)),,'kw');
        page =input(compress(prxchange('s/.+\x9+(\d+)$/$1/io',-1,strip(text)),,'kw'),best.);
        keep form page;
    run;
    proc sort nodupkey;by descending page form;run;/* Remove duplicate bookmarks */

    data Raveform_;
        set RaveBook_1;
        where not prxmatch('/^Annotations$/io',strip(form)) and ^missing(form);
    run;
    proc sort;by page form;run;
    %update_form(in_data=Raveform_, out_data=Raveform, check=1);
    %if %symexist(ck1) or %symexist(ck2) %then %RETURN ;

    proc sql;
        create table RaveBook_2 as 
        select coalescec(b.form,a.form) as form length=200, a.page, b.formOID, b.ordinal
        from RaveBook_1 as a left join Raveform as b 
        on a.page =b.page
        order by page desc, form;
    quit;

    data RaveBook_3;  /* Add record for long-break forms */
        set RaveBook_2;
        by descending page form;
        retain page_;
        if prxmatch('/^Annotations$/io',strip(form)) then page_ = page;
        if not prxmatch('/^Annotations$/io',strip(form)) then Output;
        if not prxmatch('/^Annotations$/io',strip(form)) and page_ - page>1 then do;
            do i = 1 to page_-page-1;
                page=page+1;
                Output;
            end;
        end;
        keep page form;
    run;

    *------------------- Read links --------------------;
    data RaveLink;
        infile DictLink dlm=',';
        input page i$ s$ o1 o2 n x1 x2 y2 y1;
        length text $500;
        text=strip(_infile_);
        keep page x1 x2 y2 y1;
    run;

    *------------------- Join bookmark and links together --------------------;
    proc sql;
        create table rave as 
        select a.*,b.x1,b.x2,b.y1,b.y2
        from RaveBook_3 as a inner join RaveLink as b 
        on a.page=b.page
        order by page,y2,y1;
    quit;

    data BlkBook_1;
        infile BlkBook;
        input;
        length text $500;
        if ^missing(compress(_infile_,,'kw')) and _n_ >1;
        text=strip(_infile_);
        form =compress(prxchange('s/(.+)\x9+\d+$/$1/io',-1,strip(text)),,'kw');
        page =input(compress(prxchange('s/.+\x9+(\d+)$/$1/io',-1,strip(text)),,'kw'),best.);
        keep form page;
    run;
    proc sort nodupkey;by descending page form;run;/* Remove duplicate bookmarks */
    %update_form(in_data=BlkBook_1, out_data=BlkBook_2, check=3);
    %if %symexist(ck3) or %symexist(ck4) %then %RETURN ;

    data BlkBook_3;
        set BlkBook_2;
        by descending page form;
        page_next_ = lag(page);
    run;
    proc sql;
        create table BlkBook_4 as 
        select a.*, coalesce(a.page_next_,b.page_max) as page_next
        from BlkBook_3 as a , (select max(page) as page_max from RaveBook_1) as b
        order by page;
    quit;

    *------------------- Update page in rave dataset --------------------;
    proc sql;
        create table rave_update as 
        select a.*,b.page as page_blk,b.page_next
        from rave as a left join BlkBook_4 as b 
        on a.form=b.form
        order by form ,page, x1, x2,  y1 desc, y2 desc;
    quit;

    data coordinate(rename=page_new=page);
        set rave_update;
        by form page x1 x2 descending y1 descending y2;
        retain page_diff;
        if first.form then do;
            page_diff = page_blk-page;
            order     = .;
        end;
        order+1;
        if missing(page_next) then page_next = page_blk;
        if page+page_diff< page_next  then page_new = page+page_diff;
        else page_new = page_next-1;
        drop page;
    run;
    proc sort;by form order page x1 x2 descending y1 descending y2 ;run;

    *------------------- Join ALS Fields and Forms with coordinate dataset above --------------------;
    %macro joinALS(_NOLOCK=&NOLOCK);
    *------------------- Tidy up --------------------;
    proc sql;
        create table als_1 as 
        select b.DraftFormName as form length=200 label='', input(b.Ordinal,best.) as form_seq, a.FieldOID, a.AnalyteName,
                prxchange('s/^\d+$//o',-1,strip(a.DefaultValue)) as DefaultValue length=200, 
                case when ^missing(c.DataDictionaryName) then 'Y' else '' end as flag
                ,input(a.Ordinal,best.) as field_seq,a.VariableOID, a.DataFormat, a.ControlType, a.PreText, a.IsLog, a.formoid, a.DataDictionaryName, a.UnitDictionaryName, a.FixedUnit
        from Fields(where=(/* ^missing(PreText) and */ DraftFieldActive ='TRUE' and PreText ne 'EXNOW' /* and PreText ne 'DUMMY' */
            %if &_NOLOCK = Y %then and pretext ne "NOLOCK";   /*  and VariableOID ne 'NOLOCK' */)) as a 
        inner join forms(where=(DraftFormActive='TRUE')) as b 
            on a.formoid=b.oid
        left join (select distinct DataDictionaryName from DataDictionaryEntries_1) as c 
            on a.DataDictionaryName=c.DataDictionaryName
        order by form, IsLog ,field_seq;
    quit;

    *------------------- Check dismatch between RAVE and Blank CRF --------------------;
    data _null_; /* Check form dismatch */
        set als_1;
        by form;
        where flag='Y';
        if first.form then do;
            n5 +1;
            call symputx("check5_"||cats(n5),strip(form),'g');
            call symputx("ck5",cats(n5),'g'); 
        end;
    run;

    /* Check field possible dismatch */
    proc sql;
        create table check6 as 
        select distinct form
        from als_1 
        group by FormOID
        having count(distinct ISlog) >1
        order by Form;
    quit;
    data check6;
        set check6 end=last;
        call symputx("check6_"||cats(_n_),strip(form),'g');
        if last then call symputx("ck6",cats(_n_),'g');
    run;         

    /* Output ALS */
    data als;
        set als_1 end=last nobs=nobs;
        by form IsLog field_seq;
        if not last then set als_1(firstobs=2 keep=form VariableOID PreText  rename=(VariableOID=VariableOID_next PreText=PreText_next form=form_next));
        if first.form then order=.;
        if ^missing(VariableOID) then order+1;
        if form =form_next and missing(VariableOID_next) then label_flag='Y';
        if ^missing(VariableOID) then output;
    run;
    proc sort;by form order;run;

    *------------------- Join field with postion dataset --------------------;
    data fdf_adjust check7 check8;
        retain form formOID Form_seq PreText fieldOID Field_seq page order x1 x2 y1 y2 DataFormat ControlType DataDictionaryName UnitDictionaryName IsLog;
        merge als(in=a) coordinate(in=b);
        by form order;
        if a and not b then do;
            output check7;
            n7 +1;
            call symputx("check7_"||cats(n7),strip(form),'g');
            call symputx("ck7",cats(n7),'g');             
        end;
        if b and not a then do;
            output check8;
            n8 +1;
            call symputx("check8_"||cats(n8),strip(form),'g');
            call symputx("ck8",cats(n8),'g');             
        end;
        if b then output fdf_adjust;
        keep form formOID Form_seq PreText fieldOID Field_seq page order x1 x2 y1 y2 DataFormat ControlType AnalyteName DefaultValue DataDictionaryName UnitDictionaryName IsLog label_flag  FixedUnit;
    run;
    proc sort;by form page form x1 x2 descending y1 descending y2;run;
    %mend;
    %joinALS(_NOLOCK=&NOLOCK);
    %if %symexist(ck7) or %symexist(ck8) %then %do;
        %if %symexist(ck7) %then %symdel ck7;
        %if %symexist(ck8) %then %symdel ck8;
        %if &NOLOCK=Y %then %let NOLOCK=N;
        %if &NOLOCK=N %then %let NOLOCK=Y;
        %joinALS(_NOLOCK=&NOLOCK);
    %end;

    %if %symexist(ck7) or %symexist(ck8) %then %RETURN ;

    data fdf_adjust2;
        set fdf_adjust;
        by form page x1 x2 descending y1 descending y2;
        length comment background style page_ $200;
        comment    = strip(put(order,best. -l))||': '||strip(PreText);
        background = "0.25 0.666656 0.333328";
        style      = 'font: italic bold Arial 6.0pt; text-align:left; color:#0000FF';
        page_      = put(page-1,best. -l);
    run;
    data fdf_adjust2;
        set fdf_adjust2;
        by form page x1 x2 descending y1 descending y2;
        width = GetWidth(strip(comment) , 'Arial','Bold Italic','10');        
    run;
    
    data fdf_adjust2;
        set fdf_adjust2;
        by form page x1 x2 descending y1 descending y2;
        length coordinate $200;
        coordinate = catx(' ',put(x1,best. -l),put(y2-6,best. -l),put(x1+85,best. -l),put(y2,best. -l));
    run;

    %include "&program/MakeFDF.sas";
    %MakeFDF(data       = fdf_adjust2,
            output     = &PorojectPath/fdf_adjust.fdf,
            page       = page_,
            background = background,
            comment    = comment,
            style      = style,
            coordinate  = coordinate);

%mend GetField;