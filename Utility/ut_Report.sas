/*-----------------------------------------------------------------------------
 Program Purpose:       The macro %Ut_report puts the given text into the log. 

    Macro Parameters:

    Name:                MessageLocation
      Allowed Values:    Any String
      Default Value:     REQUIRED
      Description:       Message location in original code

    Name:                MessageDisplay
      Allowed Values:    Any String
      Default Value:     REQUIRED
      Description:       The text that is put into the log. Special characters
                         like "," and "()" can be used by quoting.

    Name:                MessageType
      Allowed Values:    NOTE|WARNING|ERROR|ABORT
      Default Value:     NOTE
      Description:       The prefix that will be put in the beginning of each
                         line, ABORT is to abort the program execution.

    Name:                SplitChar
      Allowed Values:    Any single character
      Default Value:     @
      Description:       The character which is used to split lines when display in log window.

    Name:                DebugOnly
      Allowed Values:    N|Y
      Default Value:     N
      Description:       Setting this to Y will enable the ut_Message macro action only
                         if the global macro variable gmDebug is set to Y. (This
                         parameter is to suppress certain messages for normal
                         execution).
-----------------------------------------------------------------------------*/
%Macro ut_Report(  data_in             =
                  ,report_option       = 
                  ,report_style_report = 
                  ,report_style_column = 
                  ,report_style_header =
                  ,report_style_lines  = 
                  ,filter              = 
                  ,by                  =
                  ,column              =
                  ,column_option       =
                  ,style_column        =
                  ,style_header        =
                  ,break               = 
                  ,compute             = 
                  )/minoperator;
    %Ut_start(ut_Report);

    %Local  ut_Report_index
            ut_Report_count1
            ut_Report_count2
            ut_Report_count3
            ut_Report_outline
            ut_Report_type
            ut_Report_abort
            ut_Report_inittext
            ut_Report_text
            ut_Report_shift
            ut_Report_position
            ut_Report_format
            ut_Report_linecombined
    ;
    *------------------- Parameter Validation --------------------;
    %local i;

    %let i = 1;
    %do %while(%scan(&COLUMN, &i) ne );
        %let i = %eval(&i +1);
    %end;    
    %let ut_Report_count1 = %eval(&i - 1);
    *------------------- Make report code --------------------;
     PROC REPORT DATA=&data_in 
                                 &report_option /* Option in report statement */
                                 style(REPORT) = [&report_style_report]
                                 style(LINES)  = [&report_style_lines]
                                 style(HEADER) = [&report_style_header]
                                 style(COLUMN) = [&report_style_column];
        %if &filter ne %then where &filter;;
        %if &by ne %then by &by;;

         COLUMN &column;

         %Do _I_ = 1 %To &ut_Report_count1;
             DEFINE  %Scan(&column,&_I_,%Str( )) / 
                     %Scan(&column_option,&_I_,%Str(|))
                     %if &style_column ne %then  STYLE(COLUMN)=[%Scan(&style_column,&_I_,%Str(|))];
                     %if &style_header ne %then STYLE(HEADER)=[%Scan(&style_header,&_I_,%Str(|))];
                     ;
         %End;

/*          %Do _I_ = 1 %To &ut_Report_count2;
             break %Scan(&break,&_I_,%Str(|));
         %End;

         %Do _I_ = 1 %To &ut_Report_count3;
             compute %Scan(&compute,&_I_,%Str(|)); 
             endcomp;
         %End; */
     RUN;

     %Ut_end(ut_Message);
%Mend ut_Report;
