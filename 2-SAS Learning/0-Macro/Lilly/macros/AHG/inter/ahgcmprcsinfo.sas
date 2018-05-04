%macro AHGcmpRCSinfo(data1=,data2=);
%if not (%length(&data1) and %length(&data2)) %then 
%do;
proc sql noprint;
    select memname into :alldatarcs separated by ' '
    from sashelp.vmember
    where libname='ANALYSIS' and substr(memname,1,7)='DATARCS'
    order by memname descending 
    ;
quit;   
%AHGpm(alldatarcs);
%let data1=%scan(&alldatarcs,1);
%let data2=%scan(&alldatarcs,2);
%end;


%if (%length(&data1) and %length(&data2)) %then 
%do;
proc sql;
        select &data2..filename as now,&data2..ver as verNow, &data1..ver as VerOld, 
                    case 
                    when &data2..ver eq &data1..ver then '**No change**'
                    else ''
                    end  as flag
                    ,
                    case 
                    when &data2..filename ne &data1..filename then &data1..filename
                    else ''
                    end as old
                   
        from analysis.&data1 full join analysis.&data2
            on  &data1..filename=&data2..filename
; quit;
%end;
%else %put There are less than two RCS information datasets;
%mend;


