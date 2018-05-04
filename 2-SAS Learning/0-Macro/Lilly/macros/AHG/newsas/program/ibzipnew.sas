/*%let ibSheet=\\mango\sddext.grp\SDDEXT056\ib_transfers.xlsx;*/
%let ibSheet=\\mango\sddext.grp\SDDEXT056\ib_transfers_spec.xlsx;
%let awesnap=\\mango\sddext.grp\SDDEXT056\qa\ly2835219\i3y_mc_jpbm\dmc_blinded5;

PROC IMPORT OUT=ibsheet DATAFILE= "&ibsheet" 
            DBMS=excel REPLACE;
     GETNAMES=YES;
RUN;

proc sort data=ibsheet;
  by SDD_location prefix;
run;

PROC transpose data=ibsheet out=ib;
  var AWE_Path;
  by SDD_location Prefix;
run;

PROC sql noprint;
  select distinct substr(prefix,10,3) into :TPO
  FROM ib
  ;
  quit;


%let zippath=%sysfunc(PRXCHANGE(s/(\\\\[^\\]+\\[^\\]+\\[^\\]+)(.*)/\1/,1,&awesnap))\TRASH;;


data all;
  KEEP   cmd	Prefix	SDD_location;
  set ib;
  format alltype $100. cmd $1000.;
  array allcol col:;  
  cmd='"c:\Program Files\7-Zip\7z.exe" a -tzip '||"&zippath\"||strip(prefix)||".zip " ; 
  do over allcol;
    if  not missing(allcol) then
    do;
    alltype='';
    if allcol=:'data' then alltype='sas7bdat '||alltype;
    else if allcol=:'programs_stat' or allcol=:'replica_programs' then alltype='sas '||alltype;
    else if index(allcol,'system_files') then alltype='log lst ';
    else if index(allcol,'tfl_output') then alltype='rtf gif sas7bdat';
    else if index(allcol,'custom') then alltype='sas7bdat xls*';
    else alltype='*';
    do j=1 to 15;
    if   not missing(scan(alltype,j,' ')) then cmd=trim(cmd)||" &awesnap\"||trim(allcol)||"\*."||scan(alltype,j,' ');
    end;
    end;
  end;
  cmd='/* zip to '||TRIM(SDD_location)||"    */  x ' "||trim(translate(cmd,'\','/'))||"';";;
RUN;

data _null_;
  file "&zippath\IB&sysuserid..sas";
  set all;
  put cmd;
  put ' ';
run;
/*option noxwait ;x  "start &zippath" ;*/
dm "FILEOPEN  ""&zippath\IB&sysuserid..sas""  ";

