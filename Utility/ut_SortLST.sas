*--------------------------------------------------------------------------------------------------
Program Purpose:       The macro %ut_SortLST sort a macro list

    Macro Parameters:

        Name:                list
            Allowed Values:    macro variable list
            Default Value:     REQUIRED
            Description:       sort macro variable list       
*--------------------------------------------------------------------------------------------------;

%macro ut_SortLST(macroVar
                  , reverse=N);
    %local  ut_SortLST_List
            i
            j
            ut_SortLST_TemList
            ut_SortLST_OutList
            ut_SortLST_Min;
    %Let ut_SortLST_List = &&&macroVar;
    %Let ut_SortLST_TemList = &ut_SortLST_List;

    %let i = 1;
    %Do %While(%Length(%qscan(&ut_SortLST_List, &i)));
        %* %put &i; %*;
        %* Selection sort %*;
        %let j = 1;
        %let ut_SortLST_Min = ;

        %Do %While(%Length(%qscan(&ut_SortLST_TemList, &j)));
            %If &j = 1 %Then %Let ut_SortLST_Min = %qscan(&ut_SortLST_TemList, &j);
            %Else %if &ut_SortLST_Min > %qscan(&ut_SortLST_TemList, &j) %Then %Let ut_SortLST_Min = %qscan(&ut_SortLST_TemList, &j);
            %let j = %eval(&j+1);
        %End;
        %Let ut_SortLST_TemList = %Sysfunc(prxchange(s/&ut_SortLST_Min//, 1, &ut_SortLST_TemList));

        %If &I = 1 %Then %do; 
            %let ut_SortLST_OutList = &ut_SortLST_Min;
        %End;
        %Else %do;
            %If &reverse = Y %Then %let ut_SortLST_OutList = &ut_SortLST_Min &ut_SortLST_OutList;
            %Else %let ut_SortLST_OutList = &ut_SortLST_OutList &ut_SortLST_Min;
        %End;

        %let i = %eval(&i+1);
    %End;

    &ut_SortLST_OutList;
%mend;
