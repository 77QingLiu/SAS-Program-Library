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

    Name:                debugOnly
        Allowed Values:    N|Y
        Default Value:     N
        Description:       Setting this to Y will enable the pv_Message macro action only
                         if the global macro variable gdebugOnly is set to Y. (This
                         parameter is to suppress certain messages for normal
                         execution).
-----------------------------------------------------------------------------*/
%Macro pv_Message( MessageLocation =
                , MessageDisplay   =
                , MessageType      = NOTE
                , splitChar        = @
                , debugOnly        = N
                )/minoperator;
    %Local  _idx
            _outline
            _type
            _abort
            _inittext
            _text
            _count
            _shift
            _position
            _format
            _linecombined
    ;
    /*
    * This step prepares the starting line. Left alignment needed to avoid additional blanks.
    */
    %Let _text      = %Superq(MessageDisplay);
    %Let _idx       = 1;
    %Let _inittext  = /* %Sysfunc(DATETIME(),IS8601DT.)/     */%str( )&MessageLocation.;
    %Let _SplitChar = &SplitChar.;
    /*
    * Check SplitChar for non missing
    */
    %If %Length(%Superq(SplitChar)) ~= 1 %Then %Do;
        %Let _text      = Invalid value for parameter splitChar="%Superq(splitChar)";
        %Let _type      = ERROR:;
        %Let _abort     = Y;
        %Let _SplitChar = @;
    %End;
    /*
    * Check MessageDisplay for non missing
    */
    %Else %If ~%Length(%Superq(MessageDisplay)) %Then %Do;
        %Let _text      = Invalid value: Parameter MessageDisplay is empty;
        %Let _type      = ERROR:;
        %Let _abort     = Y;
        %Let _SplitChar = @;
    %End;
    /*
    * Check and harmonize Type
    */
    %Else %If %Qleft(%Qupcase(&MessageType.)) in (NOTE WARNING ERROR ABORT RETURN)  %Then %Do;
        %Let _type  = %Qleft(%Qupcase(&MessageType.)):;

        %if %Qleft(%Qupcase(&MessageType.)) = RETURN %then %Let _return = Y;
        %Else %Let _return = N;
        %if %Qleft(%Qupcase(&MessageType.)) = ABORT %then %Let _abort = Y;
        %Else %Let _abort = N;
    %End;
    %Else %Do;
        %Let _text  = Invalid option for parameter MessageType="%Superq(MessageType)";
        %Let _type  = ERROR:;
        %Let _abort = Y;
    %End;
    /*
    * Check debug flags;
    */
    %If not (%Superq(debugOnly) in (Y N)) %Then %Do;
        %Let _text      = Wrong debugOnly value: %Superq(debugOnly) Valid values: N/Y.;
        %Let _type      = ERROR:;
        %Let _abort     = Y;
        %Let _SplitChar = @;
    %End;

    /*
    * Split display text to line breaks by SplitChar.
    */
    %Let _count = %Eval(%Sysfunc(COUNT(&_text.,&_SplitChar.))+1);
    %Do %Until(&_idx. > &_count. );
        %Let _shift = 1;
        %Let _position = %Sysfunc(INDEXC(&_text.,&_SplitChar.));
        %If &_position.=0 %Then %Do;
            %Let _position = %Eval(%Length(&_text.));
            %Let _shift = 0;
        %End;
        %If &_position.<=1 %Then %Do;
            %If %Length(&_text.)=1 AND &_SplitChar. NE &_text. %Then %Do;
                %Let _outline  = &_text.;
            %End;
            %Else %Do;
                %Let _outline  =;
            %End;
        %End;
        %Else %Do;
            %Let _outline  = %Qsubstr(&_text.,1,%Eval(&_position.- &_shift.));
        %End;

        %If %Length(&_text.) >= %Eval(&_position.+ &_shift.) AND &_position > 0 %Then %Do;
            %Let _text     = %Qsubstr(&_text.,%Eval(&_position.+ &_shift.));
        %End;
        %Else %Do;
            %Let _text     = ;
        %End;
        /*
        * For lines >= 100 use the BEST format, for lines < 100 use Z2
        */
        %If &_idx < 100 %Then %Do;
            %Let _format = Z2.;
        %End;
        %Else %Do;
            %Let _format = BEST.;
        %End;

        %Let _linecombined = &_type.: %Left(%Sysfunc(PUTN(&_idx.,&_format.))) &_inittext. &_outline. ;

        %Put &_linecombined.;

        %Let _inittext =;
        %Let _idx      = %Eval(&_idx.+1);
    %End;
    /*
    * Abort SAS if abort = Y.
    */
    %If &_abort. = Y %Then %Do;
        %Abort CANCEL;
    %End;
    /*
    * Abort Macro if return = Y.
    */    
    %If &_return. = Y %Then %Do;
        %Put %Superq(Macro abort);
        %Return;
    %End;    
%Mend pv_Message;
