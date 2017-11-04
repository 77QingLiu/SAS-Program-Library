
%macro page_optimize(lib=work  /* library where data exists */
                      ,InData  = /* Data set name */
                      ,group = /* Groups which you want it appear in same page */
                      ,min   = /* Minimum records a page can contain */
                      ,max   = /* Maximun records a page can contain*/
                      ,break =
                      ,debug = /* =N then delete all dataset */);

*------------------- First, read raw data and calculate number of row for each unique group --------------------;
    data _page_1;
        set &lib..&InData;
        retain _group1 _group2 byte;
        &group._lag = lag(&group);
        if _n_ = 1 then byte=1;
        if &group ne &group._lag or _n_ = 1 then do;
            if _n_ ne 1 then byte+1;
            row    = 0; 
            _group1= byte(int(byte/76)+48);
            _group2= byte(mod(byte,76)+47);
        end;
        row +1;
        drop byte;
    run;

    proc sql;
        create table _page_2 as 
        select *
        from _page_1
        group by _group1, _group2
        having row=max(row)
        order by _group1, _group2 , row;
    quit;
    %let _nobs = &sqlobs;

    %if &break ne %then %do;
    data _page_2;
        set _page_2;
        by _group1 _group2 row;
        &break._lag = lag(&break);   
        if _n_ = 1 then &break._lag=&break;
    run;
    %end;

*------------------- Second, Create a data set containing page assignment for each unique group --------------------;

    data _page_3_;/* Derive last record */
        set _page_2 end=last nobs=nobs;
        by _group1 _group2 row;
        if not last and nobs > 1 then set _page_2(%if &_nobs >1 %then firstobs=2 ; rename=row=row_last keep=row);
        else row_last=.;
    run;

    data _page_3;
        set _page_3_;
        by _group1 _group2 row;
        retain remain 0 page 0 ;
        %if &break ne %then %do;
        if &break._lag ne &break. then do;
            page+1;
            remain =0;
        end;
        %end;
        remain_1 = remain;
        remain_2 = row+remain;
        if ^missing(row_last) then remain_3 = remain_2 +row_last;

        /* For pages which have enough records and can't add another group in current page, add a page and output*/
        if &min. <= remain_2 <= &max. and &max. < remain_3 then do;
            remain = 0;
            used      = row;
            breaker   = 1;
            ps     = row;
            if remain_1   =0 %if &break ne %then or &break._lag ne &break; then page +1;
            output;
        end;

        /* For pages don't have enough records or can still add next group in current page, Don't add a page and retain as next page input */
        else if remain_2 < &min. or remain_3 <= &max. then do;
            remain+row;
            breaker = 1 ;
            if remain_1 =0 %if &break ne %then or &break._lag ne &break; then page +1;
            used    = row;
            output;
        end;

        /* For pages surpass max page containing , truncate group by max page criteria*/
        else if  &max. < remain_2 then do;
            ps =  &max. ;
            int = int(remain_2/ps);
            do i=1 to int(remain_2/ps)+1;
                if i <= int(remain_2/ps) then do;
                    if i = 1 then used = ps -remain_1;
                    else used=  &max. ;
                    remain= remain_2 - ps*i;
                    if (i=1 and remain_1 = 0 ) or (i>1) then page +1;
                    flag='Y';
                    output;
                end;
                else if i = int(remain_2/ps)+1 then do;
                    if  &min. <= remain <= &max.  then do;
                        used = remain;
                        page +1;
                        remain = 0;
                        breaker= 1;
                        output;
                    end;
                    else if remain < &min. then do;
                        used= remain;
                        page+1;
                        output;
                    end;
                end;
            end;
        end;
        keep _group1 _group2 row remain_2 page used breaker flag;
    run;

    data _page_4;
        set _page_3;
        length page_number page_break $200;
        by _group1 _group2 row;
        retain used_lag page_number page_break;
        if first._group2 then do;
            call missing(of used_lag page_number page_break);
            used_lag    = used;
            page_number = catx(';',page_number,catx(',','1',put(used_lag,best. -l)));
            page_break  = catx(';',page_break,put(page,best. -l));
        end;
        if not first._group2 then do;
            used_lag    = used_lag+used;
            page_number = catx(';',page_number,catx(',',put(used_lag-used+1,best. -l),put(used_lag,best. -l)));
            page_break  = catx(';',page_break,put(page,best. -l));
        end;
        if last._group2 then output;
        keep _group1 _group2 row page_number page_break;        
    run;
    proc sort; by _group1 _group2 row;run;

*------------------- Final, Merge page data set with source data, and assign page accordingly --------------------;
    data _page_5;
        merge _page_1(in=a)
              _page_4(in=b drop=row);
        by _group1 _group2;
        loop = count(page_number,';')+1;
        do i = 1 to loop;
            page_number_min= input(scan(scan(page_number,i,';'),1,','),best.);
            page_number_max= input(scan(scan(page_number,i,';'),2,','),best.);
            page_break_ = input(scan(page_break,i,';'),best.);
            if page_number_min<= row < = page_number_max then grpx_page = page_break_;
        end;
    run;


    proc sql;
        select strip(name) into :_kep_var separated by " "
        from dictionary.columns
        where libname="%upcase(&lib)" and memname="%upcase(&InData)" and not find(name,"grpx_page",'i');
    quit;
    proc sort data=_page_5 out=&lib..&InData(keep=&_kep_var grpx_page);
        by _group1 _group2 row;
    run;

    %if debug=N %then %do;
    proc sql;
        drop table _page_1,_page_2,_page_3,_page_3_,_page_4,_page_5;
    quit;
    %end;

%mend;