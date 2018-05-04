/*soh***************************************************************************                                                        
Eli Lilly and Company - Global Statistical Sciences                                                                                     
CODE NAME           : chn_ut_bundle.sas                                                                                             
CODE TYPE           : Macro                                                                                                  
PROJECT NAME        : N/A                                                                                                                  
DESCRIPTION         : Combine TFL Outputs into one document                                 
SOFTWARE/VERSION#   : SAS v9.2
INFRASTRUCTURE      : Windows 
LIMITED-USE MODULES : N/A                                                                                                                                                                                  
INPUT               : RTF/TXT/DOC/DOCX                                                                   
OUTPUT              : SAS data set with the analysis results                                                            
VALIDATION LEVEL    : Peer Review                                                                                                                 
--------------------------------------------------------------------------------                                                        
PARAMETERS:                                                                                                                             
Name        Type      Default   Description and Valid Values
---------- --------- --------- -------------------------------------------------
inpath      required            Files input path                   
outpathname required            Destination file path and name
filetype    required            Input file type, it is limited word file, 
                                such as "DOC","DOCX","RTF","TXT"
order       optional   filename The order of combining TFLs, default by file names
subset      optional     1      Choose outputs which meet criteria to combine togather. 
                                For example, if subset=%str(filename=:"chn_")
                                all outputs with "chn_" as prefix will be selected to combine togather 
--------------------------------------------------------------------------------
Usage Notes: N/A
--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:
%chn_ut_bundle(inpath=D:\output,outpathname=D:\outfile\allfiles.doc,filetype=doc,subset=%str(filename=:"chn_"));
This macro will choose all files under "D:\output" with "chn_" prefix. Then combine
them as  allfiles.doc and save it under "D:\outfile"
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:                                                                                                               
                                                                                                                                        
     Author &                                                                                                                           
Ver# Peer Reviewer             Code History Description                                                                                       
---- ------------------------  -------------------------------------------------                                             
1.0  Ella Cheng & Thomas Guo     Original Version
**eoh**************************************************************************/
%macro chn_ut_bundle (inpath=,outpathname=,filetype=,order=filename,subset =1);
options noxwait noxsync;
/*Crab all file names*/
filename dirlist pipe "dir ""&inpath"" /b ";
data dirlist1 ;
  infile dirlist length=reclen ;
  input filename $varying1024. reclen ;
  if upcase(scan(filename,2,'.')) in (%upcase("&filetype")) and &subset ;
  path="&inpath";
  filename=strip(path)||'\'||strip(filename);
  length order $400.;
  order=&order;
run;

/*Sort file names by order*/
proc sql;
  create table dirlist2 as select distinct filename, order from dirlist1 order by order;
quit;
proc sql noprint;
  select count(*) into:n from dirlist2;
  select filename into:file1-:file%cmpres(&n)
  from dirlist2 order by order;
quit;

/*Combine files by order*/
%let rc=%sysfunc(system(start winword));
data _null_;
x=sleep(5);
run;
filename word DDE 'Winword|System';
data _null_;
file word;
  put '[FileOpen .Name = "' "&file1" '"]';
  %do i=2 %to &n;
  put '[EndOfDocument]';
  put '[InsertBreak .Type = 2]';
  put '[InsertFile .Name ="' "&&file&i." '" ]';
  %end;
  put '[FileSaveAs .Name ="' "&outpathname" '"]';
  put '[FileSave]';
  put '[FileCloseAll]';
  put '[FileExit]';
run;
%mend;


