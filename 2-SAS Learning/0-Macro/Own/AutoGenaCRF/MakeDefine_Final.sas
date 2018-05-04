proc import datafile="C:\Users\LiuC5\Documents\Mine\aCRF\define\aCRF Definition draft.xlsx" out=define dbms=excel replace;
            sheet   = 'Draft aCRF Definition';
run;
data define;
    length FormOID $50;
    set define;
    array clear(*) _Char_;
    do i = 1 to dim(clear);
      clear(i) = compress(clear(i),,'kw');
    end;
    order+1;
run;
proc sort nodupkey;by FormOID FieldOID;run;


libname global "\\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\02_Project Reference\global";
libname Oncology "\\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\02_Project Reference\Oncology";

data define_dcm;
    length FormOID $50;    
    set global.global_field Oncology.oncology_field;
    rename TopicValue = annotation form=Form_Name PreText=Field;    
    order = int(num);
    keep TopicValue Form FormOID PreText FieldOID order;
run;
proc sort nodupkey;by FormOID FieldOID;run;



data define_1;
    merge define(in=a) define_dcm(in=b keep=FormOID FieldOID);
    by FormOID FieldOID;
    if a and b then DCM = 'Y'; else DCM = 'N';
run;

proc sql;
    create table define_2 as 
    select a.*, b.note, a.order as order2, a.formOID as order1
    from define_1(drop=note) as a 
        left join (select distinct FormOID,note from define_1(where=(^missing(note)))) as b 
    on a.FormOID=b.FormOID;
quit;

libname define "\\Cn-sha-hfp002.ap.pxl.int\vol3\Users\LiuC5";

data define.define_final;
    set define_2;
    Annotation = prxchange('s/\|\|/||'||byte(13)||byte(10)||'/io',-1,compress(Annotation,,'kw'));
    keep formOID PAREXEL_REMINDER Annotation FieldOID Field form_name DCM Note order1 order2;
run;
/*--------------------------------------------------------------------------------------------------*
*                                           Output
*--------------------------------------------------------------------------------------------------*/
filename excel "\\CN-SHA-HFP001.ap.pxl.int\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\Janssen Standard Documents - SDTM\01_aCRF\04_Automatic_aCRF\definition library\aCRF Definition Final.xlsx";
ods excel file=excel style=seaside
          options(
                 autofilter              ='all'
                 frozen_headers          ='on'
                 sheet_interval          ='proc'
                 sheet_name              ='Draft aCRF definition'
                 tab_color               ='red'
                 autofit_height          = 'yes'
                 sheet_interval          = 'PROC');
    proc report data=define.define_final nowd style(column)={vjust=center} split="#" out=a;
        column order1 order2 PAREXEL_REMINDER annotation fieldOID Field formOID Form_name note DCM;
        define  order1                  /order ORDER=internal noprint;
        define  order2                  /order ORDER=internal noprint;
  
        define  PAREXEL_REMINDER       /display 'PAREXEL#REMINDER' style(column)={cellwidth=0.5in just=center width=1000% tagattr='wrap:yes'};
        define  formOID                /display 'FormOID' style(column)={cellwidth=0.8in just=center  width=1000% tagattr='wrap:yes'};
        define  fieldOID                /display 'FieldOID' style(column)={cellwidth=1in just=center  width=1000% tagattr='wrap:yes'};
        define  form_name                    /display 'Form Name' style(column)={cellwidth=1.5in just=center  width=1000% tagattr='wrap:yes'};
        define  annotation              /display 'Annotation' style(column)={cellwidth=0.00025in just=left width=1000% tagattr='wrap:yes'};
        define  Field                  /display 'Field' style(column)={cellwidth=2.5in just=left width=1000% tagattr='wrap:yes'};
        define  note                  /display 'Note' style(column)={cellwidth=2.5in just=left width=1000% tagattr='wrap:yes'};
        define  DCM            /display 'Is#DCM?' style(column)={cellwidth=0.3in just=center width=1000% tagattr='wrap:yes'};
    run;
ods excel close;