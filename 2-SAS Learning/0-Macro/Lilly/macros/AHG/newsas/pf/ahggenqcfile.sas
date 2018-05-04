%macro AHGgenqcfile(style=Remote /*Local*/);
%if %upcase(&style)=REMOTE %then 
    %do;
    %AHGrpipe(%str(echo $(rptandver &root3)),mystring,print=1);
    
    data totandver ;
        format totver $200. ver $15.;
        do i=1 to %AHGcount(&mystring,dlm=@);
        totver=scan("&mystring",i,'@');
        tot=tranwrd(scan(totver,1,' '),'.rpt','.tot'); 
        ver='ver='||scan(totver,2,' '); 
        
        keep tot ver;
        output  ;
        end;
    run;    
    
    %AHGrpipe(%str(echo $(vadandver &root3)),mystring,print=1);
    
    data vadandver;
        format totver $200. ver $15.;
        do i=1 to %AHGcount(&mystring,dlm=@);
        totver=scan("&mystring",i,'@');
        tot=scan(totver,1,' ');
        ver='ver='||scan(totver,2,' '); 
        keep tot ver;
        output  ;
        end;
    run;    
    
    data totandver analysis.totandver;
        set   totandver vadandver;
    run;
    %end;
%else 
    %do;
    data totandver ;
        set   analysis.totandver;
    run;
    %end;    
    

    data alltable(where=(not index(file,'~') or file='~DATA_VAI'  )  );
        format file $50. tot $50.;
        infile "&projectpath\analysis\totnum.txt";
        input file tot;
    run; 

    proc sql print;
        create table alltable as 
        select  l.file,l.tot,r.ver as currVer
        from alltable as l left join totandver as r
            on  upcase(l.tot)=upcase(r.tot)
        ;
        create table qctemp as
        select *
        from
        (
        select  *
        from netall.allqcdoc 
        where status in (1,2,3)
        group by filename 
        having max(input(substr(version,3),5.))=input(substr(version,3),5.)
        )
        group by filename,version,bugid
        having status=min(status)
        ;
        create table lastqc as 
        select distinct  filename,version,case when max(status)> 1 then ':( ' when max(status)=1 then ':) ' end as stat
        from  qctemp
        group by filename

        ;
        create table qcstatus as 
        select  l.file,tot,currver, version as qcver,stat
        from alltable as l left join lastqc as r
            on  upcase(l.file)=upcase(r.filename) or upcase(l.tot)=upcase(r.filename)
        ;
    quit;

    data qcstatus;
        set qcstatus;
        format ordvar $50.;
        %AHGaddordvar(file,ordvar);
        if ordvar='' then ordvar=file;
    run;

    proc sort data=qcstatus; by ordvar file tot;
    run;


    data _null_;
        FORMAT currver qcver $15.;
        set  qcstatus ;
        by ordvar file tot;
        if currver ne 'ver='||qcver then warning='**';
        if qcver ne '' then qcver='qcver='||qcver;
        if missing(stat) then stat='???';
   
        file "&projectpath\analysis\qcstatus.txt";
        put file $30.  tot $50.  currver $15. qcver $15. warning $6. stat $4.;
    run;
%mend;
