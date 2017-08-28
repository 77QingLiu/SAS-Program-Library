/*-----------------------------------------------------------------------------
 Program Purpose:       The macro %pv_message puts the given text into the log. 

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
        Allowed Values:    NOTE|WARNING|ERROR|ABORT|RETURN
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
        Description:       Setting this to Y will enable the pv_Message macro action only
                         if the global macro variable gmDebug is set to Y. (This
                         parameter is to suppress certain messages for normal
                         execution).
-----------------------------------------------------------------------------*/
%Macro pv_Message( MessageLocation =
                , MessageDisplay   =
                , MessageType      = NOTE
                , splitChar        = @
                , DebugOnly        = N
                )/minoperator;

    %Local  ut_Message_idx
            ut_Message_outline
            ut_Message_type
            ut_Message_abort
            ut_Message_inittext
            ut_Message_text
            ut_Message_count
            ut_Message_shift
            ut_Message_position
            ut_Message_format
            ut_Message_linecombined
    ;
    /*
    * This step prepares the starting line. Left alignment needed to avoid additional blanks.
    */
    %Let ut_Message_text      = %Superq(MessageDisplay);
    %Let ut_Message_idx       = 1;
    %Let ut_Message_inittext  = /* %Sysfunc(DATETIME(),IS8601DT.)/     */%str( )&MessageLocation.;
    %Let ut_Message_SplitChar = &SplitChar.;
    /*
    * Check SplitChar for non missing
    */
    %If %Length(%Superq(SplitChar)) ~= 1 %Then %Do;
        %Let ut_Message_text      = Invalid value for parameter splitChar="%Superq(splitChar)";
        %Let ut_Message_type      = ERROR:;
        %Let ut_Message_abort     = Y;
        %Let ut_Message_SplitChar = @;
    %End;
    /*
    * Check MessageDisplay for non missing
    */
    %Else %If ~%Length(%Superq(MessageDisplay)) %Then %Do;
        %Let ut_Message_text      = Invalid value: Parameter MessageDisplay is empty;
        %Let ut_Message_type      = ERROR:;
        %Let ut_Message_abort     = Y;
        %Let ut_Message_SplitChar = @;
    %End;
    /*
    * Check and harmonize Type
    */
    %Else %If %Qleft(%Qupcase(&MessageType.)) in (NOTE WARNING ERROR ABORT RETURN)  %Then %Do;
        %Let ut_Message_type  = %Qleft(%Qupcase(&MessageType.)):;

        %if %Qleft(%Qupcase(&MessageType.)) = RETURN %then %Let ut_Message_return = Y;
        %Else %Let ut_Message_return = N;
        %if %Qleft(%Qupcase(&MessageType.)) = ABORT %then %Let ut_Message_abort = Y;
        %Else %Let ut_Message_abort = N;
    %End;
    %Else %Do;
        %Let ut_Message_text  = Invalid option for parameter MessageType="%Superq(MessageType)";
        %Let ut_Message_type  = ERROR:;
        %Let ut_Message_abort = Y;
    %End;
    /*
    * Check debug flags;
    */
    %If not (%Superq(DebugOnly) in (Y N)) %Then %Do;
        %Let ut_Message_text      = Wrong DebugOnly value: %Superq(DebugOnly) Valid values: N/Y.;
        %Let ut_Message_type      = ERROR:;
        %Let ut_Message_abort     = Y;
        %Let ut_Message_SplitChar = @;
    %End;

    /*
    * Split display text to line breaks by SplitChar.
    */
    %Let ut_Message_count = %Eval(%Sysfunc(COUNT(&ut_Message_text.,&ut_Message_SplitChar.))+1);
    %Do %Until(&ut_Message_idx. > &ut_Message_count. );
        %Let ut_Message_shift = 1;
        %Let ut_Message_position = %Sysfunc(INDEXC(&ut_Message_text.,&ut_Message_SplitChar.));
        %If &ut_Message_position.=0 %Then %Do;
            %Let ut_Message_position = %Eval(%Length(&ut_Message_text.));
            %Let ut_Message_shift = 0;
        %End;
        %If &ut_Message_position.<=1 %Then %Do;
            %If %Length(&ut_Message_text.)=1 AND &ut_Message_SplitChar. NE &ut_Message_text. %Then %Do;
                %Let ut_Message_outline  = &ut_Message_text.;
            %End;
            %Else %Do;
                %Let ut_Message_outline  =;
            %End;
        %End;
        %Else %Do;
            %Let ut_Message_outline  = %Qsubstr(&ut_Message_text.,1,%Eval(&ut_Message_position.- &ut_Message_shift.));
        %End;

        %If %Length(&ut_Message_text.) >= %Eval(&ut_Message_position.+ &ut_Message_shift.) AND &ut_Message_position > 0 %Then %Do;
            %Let ut_Message_text     = %Qsubstr(&ut_Message_text.,%Eval(&ut_Message_position.+ &ut_Message_shift.));
        %End;
        %Else %Do;
            %Let ut_Message_text     = ;
        %End;
        /*
        * For lines >= 100 use the BEST format, for lines < 100 use Z2
        */
        %If &ut_Message_idx < 100 %Then %Do;
            %Let ut_Message_format = Z2.;
        %End;
        %Else %Do;
            %Let ut_Message_format = BEST.;
        %End;

        %Let ut_Message_linecombined = ERROR: %Left(%Sysfunc(PUTN(&ut_Message_idx.,&ut_Message_format.))) &ut_Message_inittext. &ut_Message_outline. ;

        %Put &ut_Message_linecombined.;

        %Let ut_Message_inittext =;
        %Let ut_Message_idx      = %Eval(&ut_Message_idx.+1);
    %End;
    /*
    * Abort SAS if abort = Y.
    */
    %If &ut_Message_abort. = Y %Then %Do;
        %Abort CANCEL;
    %End;
    /*
    * Abort Macro if return = Y.
    */    
    %If &ut_Message_return. = Y %Then %Do;
        %Put %Superq(Macro abort);
        %Return;
    %End;    
%Mend pv_Message;
