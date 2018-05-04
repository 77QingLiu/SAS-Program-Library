****************************************************************************************************************
** Program Name : call0adsreq.sas                                                                                                                 **
** SAS Version : 9.2                                                                                                                                                 **
** Author : Xiaofeng Shi                                                                                                                                          **
** Date : 28-APR-2012                                                                                                                                            **
**                                                                                                                                                                                    **
** Description : ADS Requirements Creation                                                                                                 **
** Macros called :                                                                                                                                                     **
** Programs called :                                                                                                                                                **
** Input  Datasets :                                                                                                                                                    **
** Output Datasets  :                                                                                                                                                **
** Notes :                                                                                                                                                                     **
** Revision History :                                                                                                                                                **
** --------------------------------------------------------------------------------------------------------------------------------------**
** Date :                                                                                                                                                                       **
** Programmer :                                                                                                                                                        **
** Modification :                                                                                                                                                         **
****************************************************************************************************************;

** Step 1: Define the programming environment **;

/*BUM library*/
%let bumprd = %str(D:\SAStemp\ads1\bums\macro_library\);
/*LUM library*/
%let lumprd = %str(D:\SAStemp\ads1\bums\macro_library\);
/*Metadata of ADS standard*/
%let ads_std = %str(D:\SAStemp\ads1\ads_metadata\);
/*Output location for Study ADS Requirements metadata*/
%let subset = %str(D:\SAStemp\ads1\study_meta\);
/*Output location for converted Excel file*/
%let ads_stdy = %str(D:\SAStemp\ads1\ads_req_output\);
/*Output location for final Study ADS metadata*/
%let meta_final = %str(D:\SAStemp\ads1\ads_req_output2\);
/*Output name for final Study ADS requirement*/
%let htmlfile = JADN_ADS_%sysfunc(compress(%sysfunc(date(),date9.),:)).html;

options sasautos=("&lumprd" "&bumprd");
options mprint nomlogic nosymbolgen nonotes;

libname STANDARD "&ads_std" access=readonly;
libname SUBSET "&subset";
libname EXCELF "&ads_stdy";
libname FINALRES "&meta_final";

** Step 2: Select the appropriate version of ADS standard, Initial Study ADS Metadata **;
%mdmake(inlib=STANDARD, outlib=SUBSET, inselect=SDYTRTPK, contents=no);

** Step 3: Convert the SAS meta datasets for all study-specific ADS into one excel spreadsheet **;
%md2excel(mdlib=SUBSET, excel_file=&ads_stdy.\sdytrtpk.xls, verbose  = 0);

proc datasets library=SUBSET;
   copy out=EXCELF;
   select descriptions(memtype=catalog) columns columns_param tables values;
run;
quit;

** Step 4: Convert the Excel file to the meta datasets for all study-specific ADS **;
/*****************************/
/*Modify the Excel file according to the study requirements*/
/*****************************/
%excel2md(mdlib=EXCELF, excel_file=&ads_stdy..\sdytrtpk.xls);

proc datasets library=SUBSET;
   copy out=EXCELF;
   select descriptions(memtype=catalog);
run;
quit;

/*****************************/
/*Modify the Descriptions catalog manually according to the study requirements*/
/*****************************/

** Step 5: Rerun %mdmake to remove unreferenced codelists and catalog **;
%mdmake(inlib=EXCELF, outlib=FINALRES, inselect=SDYTRTPK, contents=no);

** Step 6: Print out the Study ADS requirement **;
%mdprint(mdlib=FINALRES,
                      Title=ADS Requirement Study I4V-JE-JADN,
                       html=yes,
                       htmlfile=&meta_final.&htmlfile,
                       maxvaluesobs=10,
                       mult_html=no);

** Step 7: Clean **;
proc datasets lib = work kill nolist nodetails;
run; quit;

libname _all_ clear;
