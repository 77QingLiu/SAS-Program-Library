%macro AHGdowndesc(offset=);

%AHGmetaquick(offset=&offset);
%goto backdoor;

/*%AHGrpipe( %str(test -e &userhome/temp/&prot.totandnum.rpt %nrstr(&&)),rcrpipe);*/
%AHGrpipe( %str(test -e ~/temp/&prot.totandnum.rpt || test -e ~/temp/&prot.dsnlist.rpt || test -e ~/temp/&prot.desc.txt || echo notready),rcrpipe,print=yes);

%if &rcrpipe eq notready %then %goto  backdoor;
%AHGrdown
            (
             filename=&prot.desc.txt,
             rpath=&userhome/temp,
	         locpath=&projectpath\analysis
); 
option xsync ;
x "copy &projectpath\analysis\&prot.desc.txt &projectpath\analysis\desc.txt";
%local mystring;
%AHGrpipe( %str(echo $(cat &userhome/temp/&prot.totandnum.rpt &userhome/temp/&prot.dsnlist.rpt )),rcrpipe);
%let mystring=&rcrpipe;
data totnum;
    format totnum $200. ordstr $50. star $4. desc $200.;
    do i=1 to %AHGcount(&mystring,dlm=@);
    totnum=scan("&mystring",i,'@');
    tot=scan(totnum,1,' '); 
    star=scan(totnum,3,' '); 
    tabnum=upcase(left(scan(totnum,2,' ')));
    desc=left(scan(totnum,2,'#'));
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
    output  ;
    end;
run;    
proc sort;
    by ordstr;
run;

data _null_;
    set totnum;
    file "&projectpath\analysis\totnum.txt";
    by ordstr;
    put tabnum $30.  tot $50. star $4.;
run;

%backdoor:;

%mend;
