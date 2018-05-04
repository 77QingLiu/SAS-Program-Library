
 /* -------------------------------------------------------------------
                          PDS System Module
   -------------------------------------------------------------------
   $Source: /home/liu04/bin/macros/Metaquick.sas,v $
   $Revision: 1.1 $
   $Name:  $
   $Author: liu04 $
   $Locker:  $
   $State: Exp $
   $Purpose    :

   $Assumptions:

   $Inputs     :

   $Outputs    :

   $Called by  :
   $Calls to   :

   $Usage notes:

   $System archet: UNIX

   -------------------------------------------------------------------
                          Modification History
   -------------------------------------------------------------------
   $Log: Metaquick.sas,v $
   Revision 1.1  2011/03/15 05:37:08  liu04
   update




 -------------------------------------------------------------------
*/
%macro AHGMetaquick(offset=);
%AHGrpipe( %str(totanddesc &root3 > ~/temp/&prot.desc.txt %nrstr(&)),q );
%AHGrdown
            (
             filename=&prot.desc.txt,
             rpath=&userhome/temp,
	         locpath=&projectpath\analysis
);
option xsync ;
x "copy &projectpath\analysis\&prot.desc.txt &projectpath\analysis\desc.txt";

    data _null_ ;
        date=date();
        secToday=time();
        if mod((date-18490),7)=0 then  offsec=-259200;
        else  offsec=-86400;
        %if %length(&offset) %then offsec= (&offset)*(86400);;
        offsec=offsec-secToday;
        unixUStime=datetime()-43200+offsec;
        format date date9. unixUStime datetime20.;
        datepart=datepart(unixUStime);
        datestr=compress(put(datepart,yymmdd10.),'-')||'1200.00';
/*        timepart=timepart(unixUStime);*/
/*        timestr=put(timepart,time8.);*/
        put date= unixUStime= datestr= ;

/*        mmin=abs(mmin);*/
/*        hour=floor(mmin/60)-24;  */
/*        min=(mod(mmin,60));  */
/*        second=(min-floor(min))*60;  */
/*        put hour=min= second=;*/
        call symput('datestr',datestr);

    run;
%AHGrpipe( %str(ls > &userhome/temp/&prot..datestamp ; touch -t &datestr &userhome/temp/&prot..datestamp),rcrpipe);
/*%goto backdoor;*/

%AHGrpipe( %str(echo $(totandnumshort &root3) ),totnum,print=yes);

%local onlyname;
%macro lsone(folder,type);
%AHGrpipe( %str(cd &root3/; echo $(ls  &folder/%str(*).&type)),outstr );
%let onlyname=&onlyname &outstr ;
%mend;
%lsone(data,sas7bdat);
%lsone(data_vai,sas7bdat);
%lsone(data,dat);
%lsone(data_report,sas7bdat);
%lsone(analysis,sas);
%lsone(program,sas);
%lsone(program,sasdrvr);
%lsone(macros,sas);
%lsone(tools,meta);
%lsone(tools,pds);
%lsone(tools,txt);
%lsone(logs,lis);




%let mystring=&totnum;
data totnum;
    format totnum $200. ordstr $50. star $4. folder $20.;

    do i=1 to %AHGcount(&mystring,dlm=@);
    totnum=scan("&mystring",i,'@');
    tot=scan(totnum,1,' ');
    tabnum=upcase(left(scan(totnum,2,' ')));
    folder='~~tools';
    output  ;
    end;
run;

data otherfiles;
    format totnum $200. ordstr $50. star $4. ;
    do i=1 to %AHGcount(&onlyname, dlm=%str( ) );
    tot=scan("&onlyname",i ,' ' );
    folder=scan(tot,1,'/');
    tot=scan(tot,2,'/');
    if index(tot,'sas7bdat') then folder='~'||folder;
    else folder='~~'||folder;
    tabnum=folder;
    output;
    end;
run;

data allfiles;
    format tabnum $50. tot $50.;
    set totnum otherfiles;
    tabnum=substr(tabnum,1,1)||'.'||substr(tabnum,2) ;
    ordstr='';
    do j=1 to 10;
        item=scan(tabnum,j,'.');

        if '0'<scan(tabnum,j,'.') <'99' then item=put(input(scan(tabnum,j,'.'),best.),z2.) ;
        else  item=scan(tabnum,j,'.');
        ordstr=trim(ordstr)||'.'||item;
    end;
    substr(tabnum,2,1)='';
    tabnum=compress(tabnum);
run;

proc sort;
    by ordstr;
run;


/*
%AHGrpipe( %str(cd &root3/; echo $(find .  -type f -newer &userhome/temp/&prot..datestamp |
grep -v "/RCS/"|grep -v "\.log"|
grep -v "\.masterlog"|grep -v "\.deplog" |
grep -v "\.diff" |grep -v "\.pdf"|grep -v "\.lst" )),sign,print=yes);
*/
 %AHGrpipe(%str(cd &root3/; echo $(find .  -type f -newer &userhome/temp/&prot..datestamp |grep -v '/RCS/'|grep -v '\.log'|grep -v '\.masterlog'|grep -v '\.deplog' |grep -v '\.diff' |grep -v '\.pdf'|grep -v '\.lst' ))>&userhome/temp/sign.ahg ,lmacro,print=no,format=$32767.,dlm=%str( ));



;
endrsubmit;

%AHGrpipe( cat &userhome/temp/sign.ahg,sign);



data newfiles;
    format totnum $200. ordstr $50. star $4. desc $200.;
    do i=1 to %AHGcount(%bquote(&sign) );
    tot=scan("&sign",i ,' ' );
    if index(tot,',v') or index(tot,',/RCS/') or index(tot,',/table/') then continue;
    folder=scan(tot,2,'/');
    tot=scan(tot,3,'/');
    sign='##';
    if index("@data@data_vai@data_report@","@"||compress(folder)||"@") then folder='~'||folder;
    else folder='~~'||folder;
    output;
    end;
run;

proc sort; by tot;run;

data newrpt;
    set newfiles(keep=tot);
    if not index(tot,'.rpt') then delete;
    tot=tranwrd(tot,'.rpt','.tot');
    rptsign="!!";
    folder='~~tools';
run;

proc sort; by tot;run;

data allnewfiles;
    format sign $8.;
    merge newfiles newrpt;
    sign=trim(sign)||rptsign;
    by tot;
run;


proc sql;
    create table listfile as
    select upcase(L.tabnum) as tabnum,L.tot,R.sign
    from allfiles L left join allnewfiles R
        on  L.tot=R.tot and compress(L.folder,'~')=compress(R.folder,'~')
    group by L.folder ,L.ordstr,L.tot
    ; quit;

data _null_;
    set listfile;
    file "&projectpath\analysis\totnum.txt";
    put tabnum $30.  tot $50. sign $4.;
run;

x "copy  &projectpath\analysis\totnum.txt  &projectpath\analysis\totnumbackup.txt  ";

%backdoor:;
%mend;
;
