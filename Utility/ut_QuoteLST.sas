*--------------------------------------------------------------------------------------------------
Program Purpose:       The macro %ut_QuoteLST quote every elements of a macro list

    Macro Parameters:

        Name:                str
            Allowed Values:    Any valid macro list separated by specified delimeter
            Default Value:     REQUIRED
            Description:       Function-style macro to quote the elements of a list

        Name:                quote
            Allowed Values:    any string
            Default Value:     "
            Description:       quote characters like ', "

        Name:                delim
            Allowed Values:    Any delimeter
            Default Value:     one space
            Description:       Delemeter seperate the input list            
*--------------------------------------------------------------------------------------------------;

%macro ut_QuoteLST(str
                   ,quote=%str(%")
                   ,delim=%str( ));
    %local i quotelst;
    %let i=1;
    %do %while(%length(%qscan(&str,&i,%str( ))) GT 0);
        %if %length(&quotelst) EQ 0 %then %let quotelst=&quote.%qscan(&str,&i,%str( ))&quote;
        %else %let quotelst=&quotelst.&quote.%qscan(&str,&i,%str( ))&quote;
        %let i=%eval(&i + 1);
        %if %length(%qscan(&str,&i,%str( ))) GT 0 %then %let quotelst=&quotelst.&delim;
    %end;
    %unquote(&quotelst)
%mend;
