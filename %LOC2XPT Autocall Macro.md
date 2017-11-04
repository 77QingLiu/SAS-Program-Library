# %LOC2XPT Autocall Macro                            

​	Identifies whether the data set you are reading in has any extended data set features and creates a V8 transport file or a V5 transport file accordingly. 

| Name         | Description                              |
| ------------ | :--------------------------------------- |
| Type:        | Autocall macro                           |
| Restriction: | Autocall macros are included in a library supplied by SAS. This library might not be installed at your site or might be a site-specific version. If you cannot access this macro or if you want to find out if it is a site-specific version, see your on-site SAS support personnel. |
| Example:     | ```%xpt2loc(libref=work, memlist=Thisisalongdatasetname, filespec='c:\trans.v9xpt' )``` |

[Syntax ](http://127.0.0.1:51733/help/movefile.hlp/p13q0v60f08mj3n1ebm8salcpkmh.htm#n1e4h9blb7y1n2n1sj41d6hsugv3)
* [Required Argument](http://127.0.0.1:51733/help/movefile.hlp/p13q0v60f08mj3n1ebm8salcpkmh.htm#n173399cjaplrfn1sekdgzmlv1ox)

* [Optional Arguments](http://127.0.0.1:51733/help/movefile.hlp/p13q0v60f08mj3n1ebm8salcpkmh.htm#n0igva1gmyqp3bn1ick66988q91b)

[Details ](http://127.0.0.1:51733/help/movefile.hlp/p13q0v60f08mj3n1ebm8salcpkmh.htm#p1jpbwbxgkrmeen1kflwl5c79nym)

[Examples](http://127.0.0.1:51733/help/movefile.hlp/p13q0v60f08mj3n1ebm8salcpkmh.htm#p156chlm5hm5m4n1oni7y02i92im)

* [Example 1: Creates and Compares the Data Set before and after the Transport Operation](http://127.0.0.1:51733/help/movefile.hlp/p13q0v60f08mj3n1ebm8salcpkmh.htm#p0jk8xiep4ptx2n18nrd9suk3w7w)

* [Example 2: Converts Domains into a V5 Transport File Using the %LOC2XPT Macro](http://127.0.0.1:51733/help/movefile.hlp/p13q0v60f08mj3n1ebm8salcpkmh.htm#n0dzm6lyxf5auqn1s91sx6u9z6p7)

------

## Syntax                                   

```sas
%LOC2XPT (FILESPEC=filespec ,<LIBREF=libref>, <MEMLIST=memlist>, <FORMAT=format>)  
```

### Required Argument                                              

#### FILESPEC=filespec

​	indicates either a fileref  that is not quoted or a quoted file specification that consists of the pathname and extension of the [transport file]() that you are creating. This argument has no default value.    

> **Example**	 'c:\trans.xpt'

### Optional Arguments                                              

#### LIBREF=libref                                                    

	indicates the libref  where  the members reside.     
> **Default**:  The default is WORK. If the LIBREF= option is omitted,

#### MEMLIST=memlist                                                    

​	 indicates the list of members in the library that are to be converted. > **Default**: All members are converted by default.         

#### FORMAT=V5 | V8 | AUTO

	indicates the format of the transport file. 

> **V5**: specifies a Version 5 transport file. If you specify V5 and your [data set]() contains long variable names, long labels, or character variables more than 200 bytes,                                    an error is generated.

> **V8**: specifies a Version 8 transport file.

> **AUTO**: is determined by the data. If you specify AUTO and your data set contains no long variable names, long labels, or character variables more than 200 bytes, a V5 transport file is written.  You receive an error if  you use V5 when any of these attributes are present.   

## Details                                   

​	The %LOC2XPT (from local session to export) macro can identify whether the data set you are reading in has any extended data set features and creates either a V5 or V8 formatted file. For example, if the data set has long variable names, a V8 transport file is created. Otherwise, a V5 transport file is created. You can specify the type of transport file that you want to create using the FORMAT= parameter.                                        

------

## Examples

### Example 1: Creates and Compares the Data Set before and after the Transport Operation                                        

This sample creates and compares the data set before and after the transport operation.

Toggle options off. 

```sas
options nosource2 nosource; 
```

Build a format whose name is greater than 8 characters.                                               

```sas
proc format;
   value testfmtnamethatislongerthaneight 
   100='numeric has been formatted'; 
run;
```

Build a data set that has a data set name greater than 8 characters, has a variable name, and has a character label that is greater than 40.                                              

```sas
libname test 'c:\temp';
data test.Thisisalongdatasetname;
   varnamegreaterthan8=100;
   label varnamegreaterthan8=
   'jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
 jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj';
```

Assign permanent format.

```sas
format varnamegreaterthan8 
   testfmtnamethatislongerthaneight.;
run;
```

Use the %LOC2XPT macro to create a V9 transport file. The LIBREF= points to a directory containing         data sets specified by MEMLIST= . FILESPEC= specifies the pathname and the extension of the transport file that you are creating. Name and extension can be anything, but we are using trans.v9xpt in our example. Our naming convention reminds us that the file contains a data set with SAS 9 features.                                              

```sas
%loc2xpt(libref=test,
           memlist=Thisisalongdatasetname,
           filespec='c:\trans.v9xpt' )
```

Use %XPT2LOC to convert  the V9 transport file to a SAS data set. The %XPT2LOC macro takes                        as an input file the trans.v9xpt file that we created using %LOC2XPT. LIBREF= points to target folder where data sets are stored. FILESPEC=specifies the pathname and the extension of the existing transport                        file.                                              

```sas
%xpt2loc(libref=work, 
           memlist=Thisisalongdatasetname, 
           filespec='c:\trans.v9xpt' )
```

Compare data sets before and after the transport operations. Note that data set features are                        retained in the PROC COMPARE output.                                              

```sas
ods listing; 
title 'Compare before and after data set attributes';
proc compare base=test.Thisisalongdatasetname 
   compare=work.Thisisalongdatasetname;
run;

```

Restore option settings.

```sas
options source2 source;
```

### Example 2: Converts Domains into a V5 Transport File Using the %LOC2XPT Macro                                        

This sample first creates a data set that has one observation for each domain in the  SDTM library. It then uses this data set and creates a macro variable for each domain. It then converts each SDTM domain                     into a V5 transport file by using the %LOC2XPT macro.                                        

Assign a libref for the library where the SDTM domains are stored.                                              

```sas
libname sdtm 'C:\Public\sdtm';
```

Create data to use for this example.                                              

```sas
proc copy in=sashelp out=sdtm;
select class retail;
run;
```

Create a data set with one observation for each domain in the SDTM library.                                              

```sas
proc sql;
   create table sdtmDomains as
      select libname
            ,memname
      from dictionary.tables
         where libname eq 'SDTM'
      order by memname;
quit;
```

Create one macro variable for each SDTM domain.                                               

```sas
data _null_;
   set sdtmDomains end=eof;
   call symput('domain_' || strip(put(_n_,2.))
              ,strip(lowcase(memname))
              );
   if eof then 
      call symput('domainCnt',strip(put(_n_,2.)));
run;
```

Define a macro to convert each SDTM domain into a V5 transport file.                                                

```sas
%macro XPTsUsingLoc2XptFilerefFilespec;
   %do idx=1 %to &domainCnt;
```

 Create the file named XPTFILE with the pathname and filename extension XPT. Use the %LOC2XPT macro with a fileref as the FILESPEC= value to convert each SDTM domain into a V5 transport file.                                              

```sas
filename xptfile "C:\Public\sdtm\&&domain_&idx...xpt";
      %loc2xpt(libref=sdtm
              ,memlist=&&domain_&idx
              ,filespec=xptfile
              );
   %end;
%mend XPTsUsingLoc2XptFilerefFilespec;
%XPTsUsingLoc2XptFilerefFilespec;
```

Copyright © SAS Institute Inc. All rights reserved.