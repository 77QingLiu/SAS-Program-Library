


/********************************************************************************************************/
/* The macro has the parameters open_workbook= which allows you to specify a file to open which will    */
/* be enhanced or updated. The  Insert_workbook= option allows you to specify a workbook which has      */
/* sheets to be inserted along with  the insert_sheet= which specifies the sheets to insert separated   */
/* by commas. The insert_image= parameter allows you to specify an image to insert along with the       */          
/* sheet name and the position in the sheet it shoud be inserted. For example value passed              */
/* c:\graph.png#test!a1, would add this to the opened workbook specified with the open_workbook         */
/* and the sheet #test at positon A1. You can specify multiple images by separating by commas           */
/* The create_workbook = option will allow you to specify a new workbook to save the changes to,        */
/* otherwise it saves a copy of the workbook opened. The file_format= parameter allows you to specify   */
/* the file format.                                                                                     */
/*                                                                                                      */
/* %Excel_enhance(open_workbook=c:\test_files\temp2.xml,                                                */
/*                  insert_workbook=c:\test_files\temp1.xml,                                            */
/*                  insert_sheet=%str(sheet1,sheet2,sheet3),                                            */
/*                  insert_image=%str(c:\test_files\sgplot5.png#test!A1,                                */
/*                                    c:\test_files\sgplot1.png#test!I4),                               */
/*                  create_workbook=c:\test_files\Combined_File.xml,                                    */
/*                  file_format=xlsx);                                                                  */                    
/* ***************************************************************************************************  */



options noxwait noxsync;

%macro Excel_enhance(open_workbook=,
                  insert_workbook=,
                  insert_sheet=,
                  insert_image=,
                  create_workbook=,
                  file_format=);

 %local open_workbook insert_sheet insert_image create_workbook file_format;
 %let script_loc=%sysfunc(getoption(WORK))\enhance.vbs;

data _null_;
   file "&script_loc";
   put "Set objExcel = CreateObject(""Excel.Application"")  ";
   put "objExcel.Visible = True ";
   put "objExcel.DisplayAlerts=False";
   put "Set objWorkbook1= objExcel.Workbooks.Open(""&open_workbook"")";

    %if &insert_image ne %then %do;
          %let pic_count=%sysfunc(countc(&insert_image,","));

             %if %sysfunc(countc(&insert_image,","))=0 %then %do;

               %let sheet_name=%sysfunc(scan(&insert_image,2,"#")));
               %let sheet_name=%sysfunc(scan(&insert_image,2,"#"));
               %let range_field=%sysfunc(scan(&insert_image,2,"!"));
               %let image_loc=%sysfunc(scan("&insert_image",1,"#"));

                sheet_name=quote(scan("&sheet_name",1,"!"));
                range_field=quote("&range_field");
                image_loc=quote("&image_loc");

               put "Set Xlsheet = objWorkbook1.Worksheets(" sheet_name ")";
               put "Xlsheet.Range(" range_field ").Activate";
               put "Xlsheet1.Pictures.Insert(" image_loc ")";

          %end;
          %else %do;

             %let image_count=%sysfunc(countc(&insert_image,","));
             %let image_count=%eval(&image_count+1);

            %do j=1 %to &image_count;

                %let insert_image&j=%sysfunc(scan(&&insert_image,&j,","));
                %let sheet_name&j=%sysfunc(scan(&&insert_image&j,2,"#"));
                %let sheet_name&j=%quote(%str(%")%sysfunc(scan(&&sheet_name&j,1,"!"))%str(%"));
                %let range_field&j=%quote(%str(%")%sysfunc(scan(&&insert_image&j,2,"!"))%str(%"));
                %let image_loc&j=%quote(%str(%")%sysfunc(scan("&&insert_image&j",1,"#"))%str(%"));

                sheet_name=quote(scan("&&sheet_name&j",1,"!"));
                range_field=quote("&&range_field&j");
                image_loc=quote("&&image_loc&j");

                put;
                put "Set Xlsheet = objWorkbook1.Worksheets( &&sheet_name&j)";
                put "Xlsheet.Range(&&range_field&j).Activate";
                put "Xlsheet.Pictures.Insert(&&image_loc&j)";

            %end;
      %end;
   %end;

    %if &insert_workbook ne %then %do;

      put;
      put "set objWorkbook2=objExcel.Workbooks.Open(""&insert_workbook"")";

      %let sheet_count=%sysfunc(countc(&insert_sheet,","));
      %let sheet_count=%eval(&sheet_count+1);

      %do i=1 %to &sheet_count;
         %let x=%sysfunc(scan(&insert_sheet,&i));
         %if &i=1 %then
         %let s&i=%sysfunc(quote(&x));
      %else
         %let s&i=&s%eval(&i-1),%sysfunc(quote(&x)) ;
         %let list=%nrbquote(&&s&i);
      %end;

       put "set sheetsToCopy=objWorkbook2.Sheets(Array(%quote(&list))) ";
       put "sheetsToCopy.Copy objWorkbook1.Sheets(1) ";

   %end;


  %if &file_format ne %then %do;
     %if &file_format=xlsx %then %let file_formatn=51;
       %else  %if &file_format=xls %then %let file_formatn=1;
     %else  %if &file_format=csv %then %let file_formatn=16;
  %end;


   %if &create_workbook ne %then %do;
       %if &file_format ne %then
          %let save="objWorkbook2.saveAs ""&create_workbook"",&file_formatn";
       %else
          %let save="objWorkbook2.saveAs(""&create_workbook"")";

         put &save;
   %end;


   %else %do;
      %let name=%sysfunc(scan(%sysfunc(reverse(%sysfunc(scan(%sysfunc(reverse(&open_workbook)),2)))),1,"."))_update.&file_format;
      %put &name;
       %if &file_format ne %then
           %let save="objWorkbook2.saveAs ""&name"",&file_formatn";
         %else
           %let save="objWorkbook2.saveAs(""&name"")";

         put &save ;
   %end;


   put "objWorkbook2.close";
   put "objExcel.DisplayAlerts=True";
   put "set objExcel=nothing";
run;

x "cscript '&script_loc\enhance.vbs'";

%mend;

%Excel_enhance( )
