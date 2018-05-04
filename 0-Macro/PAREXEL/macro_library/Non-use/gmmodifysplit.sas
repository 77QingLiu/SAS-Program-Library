/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Matthias Lehrkamp Dmitry Kolosov  $LastChangedBy: kolosod $
  Creation Date:         19Dec2013 $LastChangedDate: 2015-08-31 04:18:26 -0400 (Mon, 31 Aug 2015) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmmodifysplit.sas $

  Files Created:         N/A

  Program Purpose:       The macro sets delimiters in a variable. A user needs to specify the width parameter and the macro
                         will put the delimiter after the latest blank within the specified width or using rules.
                         In most cases, the delimiter characters are used as a line break in a report. 
                         It is called within a data step like a SAS DATA-Step function and has the following features:
                         * Searches for the maximum possible position to put the delimiter 
                         * Checks for existing delimiter in the variable
                         * Rules can used to control allowed split positions
                         * Words longer than the given user width are split using hardsplit

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                var
      Allowed Values:    ^[a-zA-Z_]{1}[a-zA-Z_0-9]{0,31}$
      Default Value:     REQUIRED
      Description:       A variable name for which the split is performed.

    Name:                width
      Allowed Values:    1-255
      Default Value:     REQUIRED
      Description:       Maximum width of a split part (1-255).

    Name:                delimiter
      Default Value:     ~
      Description:       A delimiter used to mark line breaks in the variable.
                         * Commas, brackets, and single quote must be quoted: %str(,), %str(%(), %str(%)), or %str(%').
                         * Character % must be quoted as %nrStr(%%).
                         * Space [%str( )] or double quote [%str(%")] characters cannot be used as a delimiter.

    Name:                rules
      Description:       List of split rules for words, delimiter is used to specify allowed split positions.
                         If a split occurs according to a rule, a hyphen is added by default. 
                         See the addHyphen parameter description for details.
                         # Example (when ~ is used as a delimiter):  head~ache@ce~pha~la~lgia
                         # In this case word headache will split only between head and ache and word cephalalgia will
                         split at 3 allowed positions.
                         # See the delimiter variable description for details on how to quote special characters.

    Name:                splitChar
      Default Value:     @
      Description:       Split character used to separate rules.

    Name:                addHyphen
      Allowed Values:    1|0
      Default Value:     1
      Description:       Controls whether a hyphen character is added when words are split according to the rules parameter.
                         # 1 - hyphen is added, 0 - hyphen is not added.

    Name:                minLength
      Allowed Values:    1 - width
      Default Value:     3
      Description:       In case of a hardsplit (split of a word with length > width parameter and which is not specified in rules)
                         controls how many characters at the beginning of a word are kept together.
                         * If minLength=width, hardsplit will always start from a new line.
                         * if minLength=1, hardsplit can happen at any positions.

    Name:                wordBorder 
      Description:       Combination of characters, which will be used to identify word boundaries in addition to whitespace.
                         * \s, which includs space, is always included in this class and must to be specified.
                         * SAS special characters must be escaped. See the delimiter parameter description for details.
                         * Perl regex $,@,\ and / characters must be escaped as \$,\@,\\, and \/.   
                         * The characters are surrounded with '[\s\Q' and '\E]', to quote metacharacters and used as a regex class.
                         * Examples: 
                         # %str(,).<>{}!?
                         # %nrStr(%%)%str(%"%',.;\\\@\$\/)
                         # .{}?! 
                         # .\E\W\Q. (you can use Perl regex character classes, but need to unquote the regex first)

    Name:                indentSize 
      Default Value:     0
      Description:       Number of spaces to be added as an indent before each line. If followed by +, then the for last
                         line an additional space is added, which can be useful when reporting variables using PROC
                         REPORT.
                         # In case indentSize is used, the macro still fits words and indent within the width parameter value.
                         * Examples(spaces are replaced with dots):
                         * Width = 20, IndentSize = 0  
                         # |SOC term line 1.....|
                         # |SOC term line 2.....|
                         * Width = 20, IndentSize = 2  
                         # |..PT term line 1....|
                         # |..PT term line 2....|
                         * Width = 20, IndentSize = 4+  
                         # |....Verbatim line 1.|
                         # |.....Verbatim line 2.| <- Note, the extra space is not a mistake and added because of the +

    Name:                varPrefix
      Allowed Values:    ^[a-zA-Z_]{1}[a-zA-Z_0-9]{0,10}$
      Default Value:     modSplit_
      Description:       Prefix for temporary variables (1-11 characters length) which are used to store values required for the macro.

    Name:                selectType
      Allowed Values:    N|NOTE|E|ERROR|ABORT
      Default Value:     E
      Description:       Possible values N/NOTE/E/ERROR/ABORT. See the selectType parameter description for gmMessage macro.
                         # The following checks are performed:
                         # 1) Variable contains word with length > width:
                         #    N/E: A note/error is reported and the split is performed using hardsplit.
                         #    ABORT: An error is reported and the split is not performed.
                         # 2) Variable contains delimiter character:
                         #    N/E: A error is reported and the split is considered as a character.
                         #    N value is reported as an error, because in such situations the result can be unexpected:
                         #    If the delimiter is the last character in a line, it is removed. A extra hyphen can be added if addHyphen=1.
                         #    ABORT: An error is reported and the split is not performed.
                         # PXL warnings are not reported by the macro, as they are reserved for DM issues.

  Macro Return value:    N/A
                          
  Macro Dependencies:    gmMessage (called)
                         gmStart (called )
                         gmEnd (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1074 $
-----------------------------------------------------------------------------*/

%macro gmModifySplit( var        =
                    , width      =
                    , delimiter=~
                    , selectType = E
                    , rules  =
                    , splitChar  = @
                    , varPrefix  = modSplit_
                    , minLength = 3
                    , addHyphen = 1
                    , wordBorder =
                    , indentSize = 0
);

    %gmStart( headURL            =
            $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmmodifysplit.sas $
          , revision           = $Rev: 1074 $
          , librequired        = 0
          , splitcharDebug     = °
          , checkMinSasVersion = 9.2
          )

    * Define local macro variables;
    %local modSplit_delimiterReplace
           modSplit_delimiter
           modSplit_splitChar
           modSplit_borderCl
           modSplit_nonBorderCl
           modSplit_splitCondition
           modSplit_rulesList
           modSplit_indent
           modSplit_rulesList
           modSplit_numberOfRules
           modSplit_rulesListMatch
           modSplit_arrayName
    ;

    * Remove extra blanks from the rules;
    %if "%superQ(rules)" ne "" %then %do;
        %let rules = %qSysFunc(compress(%superQ(rules)));
    %end;

    * --- check input parameters ---;
    * Check a variable is specified;
    %gmCheckValueExists( codeLocation   = gmModifySplit/Parameter var check
                       , value          = %superQ(var)
                       , selectMethod   = EXISTS
                       )
    * Check a variable is specified;
    %gmCheckValueExists( codeLocation   = gmModifySplit/Parameter width check
                       , value          = %superQ(width)
                       , selectMethod   = EXISTS
                       )
    * Check a varPrefix is specified;
    %gmCheckValueExists( codeLocation   = gmModifySplit/Parameter varPrefix check
                       , value          = %superQ(varPrefix)
                       , selectMethod   = EXISTS
                       )
 
    %* Check delimiter value (repeating quote comparison for proper highlighting);
    %if "%superQ(delimiter)" = " " or %superQ(delimiter) = %str(%") or %superQ(delimiter) = %str(%") %then %do; 
        %gmMessage( codeLocation = gmModifySplit/Parameter checks
                  , linesOut     = %str(@Invalid delimiter value: %superQ(delimiter).)
                  , selectType   = ABORT
                  , splitChar    = @
                  );
    %end;

   * Check parameter var is a SAS name with a maximal character length of 32;
    %if %qSysFunc(prxMatch(%qSysFunc(
          prxParse(/^%bQuote([a-zA-Z_]{1}[a-zA-Z_0-9]{0,31})$/)),%superQ(var))) ~= 1 %then %do;
        %gmMessage( codeLocation = gmModifySplit/Parameter checks
                  , linesOut     = %str(Parameter var= &var. has an invalid SAS name, please correct.)
                  , selectType   = ABORT
                  , splitChar    = @
                  )
    %end;

    * Check parameter varPrefix is a SAS name with a maximal character length of 8;
    %if %qSysFunc(prxMatch(%qSysFunc(
          prxParse(/^%bQuote([a-zA-Z_]{1}[a-zA-Z_0-9]{0,10})$/)),%superQ(varPrefix))) ~= 1 %then %do;
        %gmMessage( codeLocation = gmModifySplit/Parameter checks
                  , linesOut     = %str(Parameter varPrefix= &varPrefix. has an invalid SAS name, please correct.)
                  , selectType   = ABORT
                  , splitChar    = @
                  )
    %end;

    * Check width is more than one 1;
    %if %qLeft(&width) < 1 or %qLeft(&width) > 255 or %index(&width.,%str(.)) %then %do;
        %gmMessage( codeLocation = gmModifySplit/Parameter checks
                  , linesOut     = %str(Parameter width= &width. has an invalid value, please choose a value between 1 and 255.)
                  , selectType   = ABORT
                  , splitChar    = @
                  )
    %end;

    * Check selectType is N, E or ABORT;
    %if %qSysFunc(prxMatch(/^(N|E|ERROR|NOTE|ABORT)$/,%superQ(selectType))) ~= 1 %then %do;
      %gmMessage( codeLocation = gmModifySplit/Parameter checks
                , linesOut     = %str(Parameter selectType= &selectType. has an invalid value.
                                      @Please choose N,NOTE,E,ERROR or ABORT.)
                , selectType   = ABORT
                , splitChar    = @
                )
    %end;

    * Check minLength value;
    %if %qLeft(&minLength) < 1 or %qLeft(&minLength) > &width %then %do;
        %gmMessage( codeLocation = gmModifySplit/Parameter checks
                  , linesOut     = %str(Parameter minLength= &minLength. has an invalid value, please choose a value between 1 and &width..)
                  , selectType   = ABORT
                  , splitChar    = @
                  );
    %end;

    * Check the hyphen value;
    %if "%qLeft(&addHyphen)" ne "1" and "%qLeft(&addHyphen)" ne "0"  %then %do;
        %gmMessage( codeLocation = gmModifySplit/Parameter checks
                  , linesOut     = %str(Parameter addHyphen= &addHyphen. has an invalid value, please choose 1 or 0.)
                  , selectType   = ABORT
                  , splitChar    = @
                  );
    %end;

     * Check delimiter value;
    %if %qLeft(&addHyphen) = 1 and "%superQ(rules)" ne "" and %length(%bQuote(&delimiter)) > 1  %then %do;
        %gmMessage( codeLocation = gmModifySplit/Parameter checks
                  , linesOut     = %str(Multicharacter delimiter is not supported at the moment together with rules and addHyphen = 1.)
                  , selectType   = ABORT
                  , splitChar    = @
                  );
    %end;

    * Check delimiter value is not equal to split char value;
    %if "%qLeft(&delimiter)" = "%qLeft(&splitChar.)"  %then %do;
        %gmMessage( codeLocation = gmModifySplit/Parameter checks
                  , linesOut     = %str(Parameters splitChar and delimiter must not have the same value.)
                  , selectType   = ABORT
                  , splitChar    = @
                  );
    %end;

    * --- transform escape chars if nessesary ---;
    %local modSplit_delimiterReplace modSplit_delimiter modSplit_splitChar;
    * Check delimiter and correct escape chars for Perl Regular Expressions if nessesary;
    %if %index(%bQuote({}[]()^$.|+?/\*@),%bQuote(&delimiter.)) > 0 %then %do;
        %let modSplit_delimiter= \&delimiter.;
    %end;
    %else %do;
        %let modSplit_delimiter= &delimiter.;
    %end;

    * Check split character and correct escape chars for Perl Regular Expressions if nessesary;
    %if %index(%bQuote(^$/\@),%bQuote(&splitChar.)) > 0 %then %do;
        %let modSplit_splitChar= \&splitChar.;
    %end;
    %else %do;
        %let modSplit_splitChar= &splitChar.;
    %end;   

    * Check delimiter and correct escape chars for repleacement text if nessesary;
    %if %index(%bQuote(\/),%bQuote(&delimiter.)) > 0 %then %do;
        %let modSplit_delimiterReplace= \&delimiter.;
    %end;
    %else %do;
        %let modSplit_delimiterReplace= &delimiter.;
    %end;

    * Check the indentSize parameter;
    %if not %qSysFunc(prxMatch(/^\d+\+?$/,%bQuote(&indentSize.)))  %then %do;
        %gmMessage( codeLocation = gmModifySplit/Parameter checks
                  , linesOut     = %str(Parameter indentSize= &indentSize. has an invalid value.
                                        @Please use an integer number, optionally followed by +.)
                  , selectType   = ABORT
                  , splitChar    = @
                  )
    %end;

    * Generate regex parts depending on the wordBorder value;
    %if "%superQ(wordBorder)" = "" %then %do;
        %let modSplit_borderCl = \s;
        %let modSplit_nonBorderCl = \S;
        * Split only if followed by a whitespace or end of line;
        %let modSplit_splitCondition =(?=\s|$) ;
    %end;
    %else %do;
        %let modSplit_borderCl = [\s\Q%superQ(wordBorder)\E];
        %let modSplit_nonBorderCl = [^\s\Q%superQ(wordBorder)\E];
        * Split only if followed by a word border, preceeded by a word border except for whitespace or end of line;
        %let modSplit_splitCondition =(?=&modSplit_borderCl.|(?<=%qSysFunc(compress([\Q%superQ(wordBorder)\E])))|$) ;
    %end;

    * Generate macro variable with indent, -0 is added to get rid of possible +;
    %if %eval(&indentSize-0) > 0 %then %do;
        %let modSplit_indent = %quote(%sysFunc(repeat(%str( ),%eval(&indentSize.-1))));
        * If indentSize > 0 then width is reduced by the indent size;
        %let width = %eval(&width - &indentSize-0);
        * Check width is more than indent size;
        %if &width <= 0 %then %do;
            %gmMessage( codeLocation = gmModifySplit/Parameter checks
                      , linesOut     = %str(Value of indentSize = &indentSize. is more or equal to width.
                                            @Please update the width or indentSize parameter value)
                      , selectType   = ABORT
                      , splitChar    = @
                      )
        %end;
    %end;
    %else %do;
        %let modSplit_indent =;
    %end;
    

    * --- Perform split ---;
    length  &varPrefix.errormsg           $1 /* variable used for error reporting */
            &varPrefix.var_safe           $32767
            &varPrefix.longWords          $2048  
    ;
    drop &varPrefix.errormsg &varPrefix.var_safe &varPrefix.longWords;
    * initialize the variables;
    &varPrefix.errormsg= "";
    * Check that variable type is character;
    if vType(&var.) ne "C" then do;
        &varPrefix.errormsg = resolve('%gmMessage( codeLocation= gmModifySplit/Variable type check' ||
                                      ", linesOut    = The variable &var. has not the character type, please check." ||
                                      ", selectType  = ABORT)"
                                     );
    end;
    * Look for a split char in raw variable;
    if prxMatch("/&modSplit_delimiter./",trim(&var.)) then do;
        &varPrefix.errormsg = resolve('%gmMessage( codeLocation= gmModifySplit/Value check' ||
                                      ", linesOut    =@A delimiter character was found in variable &var.. "||
                                      "@This can result in an unexpected output. Please use a different delimiter value."||
                                      '@Record number: ' || strip(put(_n_,best.)) ||
                                      %if "%qTrim(&selectType.)" =  "ABORT" %then %do;
                                          ", selectType  = &selectType.)"
                                      %end;
                                      %else %do;
                                          ", selectType  = E)"
                                      %end;
                                     );
    end;

    * In case there are rules provided;
    %if "%superQ(rules)" ne "" %then %do;
        %local modSplit_rulesList modSplit_numberOfRules;
        * Convert rules to a match condition (\Qword1\E|\Qword2\E) and to a list of words without split symbol (word1@word2);
        %let modSplit_rulesList = %nrBQuote(%qSysFunc(compress(%superQ(rules),%superQ(delimiter))));
        * Number of rules;
        %let modSplit_numberOfRules = %eval(%qSysFunc(countc(%superQ(rules),%superQ(splitChar)))+1);
         ** Select unique name for a variable containing list of rule words matches, based on the variable name;
        %local modSplit_rulesListMatch;
        %let modSplit_rulesListMatch = &varPrefix.m%sysFunc(md5(&var%superQ(rules)%sysFunc(ranUni(10))),HEX20.);
       * Set length a drop temporary variables;
        length  &varPrefix.currentRule &varPrefix.currentRuleTmp &varPrefix.currentWord &varPrefix.ruleFirstPart
                &varPrefix.ruleSecondPart &varPrefix.ruleSecondP1 &varPrefix.ruleSecondP2 $1024
                &varPrefix.regex &modSplit_rulesListMatch $32767
                &varPrefix.X &varPrefix.Y $32
        ;
        drop &varPrefix.currentRule &varPrefix.currentRuleTmp &varPrefix.currentWord 
             &varPrefix.ruleFirstPart &varPrefix.ruleSecondPart &varPrefix.regex
             &varPrefix.i &varPrefix.j &varPrefix.X &varPrefix.Y &modSplit_rulesListMatch
             &varPrefix.ruleSecondP1 &varPrefix.ruleSecondP2

        ;
        retain &modSplit_rulesListMatch;
        * Create regexes for rules, it is done only once;
        if missing(&modSplit_rulesListMatch) then do;
            * Create array with rules;
            ** Select unique array name based on the variable name;
            %local modSplit_arrayName;
            %let modSplit_arrayName = &varPrefix.%sysFunc(md5(&var%superQ(rules)%sysFunc(ranUni(10))),HEX21.);
            array &modSplit_arrayName. [&modSplit_numberOfRules.] $2048 _temporary_;
            retain &modSplit_arrayName.;
            * Generate a special regex for each word from the rules;
            &varPrefix.i = 1;
            do while(not missing(scan("%superQ(rules)",&varPrefix.i,"&splitChar.")));
                * Current rule (word with split symbols);
                &varPrefix.currentRule = scan("%superQ(rules)",&varPrefix.i,"&splitChar.");
                * Validate the rule - there must be at least one split symbol and it must not be at the start or end of the rule;
                * and all parts must be less than width;
                if prxMatch("/^&modSplit_delimiter|&modSplit_delimiter.$|&modSplit_borderCl./",strip(&varPrefix.currentRule))
                   or not index(&varPrefix.currentRule,"&delimiter.")
                   or prxMatch("/(&modSplit_delimiter|^)((?!&modSplit_delimiter.).){%eval(&width+1-&addHyphen.),}(&modSplit_delimiter|$)/"
                               ,strip(&varPrefix.currentRule)
                              )
                   then do;
                    &varPrefix.errormsg = resolve('%gmMessage( codeLocation= gmModifySplit/Split rule check' ||
                            ', linesOut    = @Incorrect rule. @Rule: %NRBQUOTE(' || trim(&varPrefix.currentRule) || ')' ||
                                            '@%str(A rule must contain at least one delimiter, must not start or end with it,'||
                                            '@the length of each part must be <= width-1 or <= width if addHyphen = 0,'||
                                            '@and must not contain only full words.)'||
                            ", selectType  = ABORT)"
                             );
                end;
                * Current word without split chatacters;
                &varPrefix.currentWord = scan("&modSplit_rulesList.",&varPrefix.i,"&splitChar.");
                * For each rule generate the following regex which matches the word at the end of the current line, using part1~part2~part3 as a rule:
                *   (?:
                *        .{X,Y12}(?<!\S)part1part2(?=part3(?:\s|$))   - When both part1part2 can be put on the current line
                *       |.{X,Y1}(?<!\S)part1(?=part2part3(?:\s|$))    - When only the part1 can be put on the current line
                *       |(?<=(?<!\S)part1)part2(?=part3(?:\s|$))      - When part2part3 cannot be put on the same line
                *       |.{X,Width-1}\s(?=part1part2part3(?:\s|$))    - When the rule word cannot be put on the current line
                *   )
                * Where X = max of (0, width - length of the word + 1)). This is done in case word from the rule is < width
                * Where Yvu = width - (length of part v + part u) - 1(if hyphen is needed);
                * Where (?:(?<=\s)|^) identifies a word start and (?:\s|$) a word end;
                &varPrefix.X = put(max(0,&width - lengthn(&varPrefix.currentWord)+1),best.);
                &modSplit_arrayName.[&varPrefix.i] = "(?:";
                * Process rule part by part from the end;
                &varPrefix.currentRuleTmp = &varPrefix.currentRule; 
                do while (index(&varPrefix.currentRuleTmp,"&delimiter."));
                    * First part of the current rule (part1part2);
                    &varPrefix.ruleFirstPart = prxChange("s/(.*)&modSplit_delimiter.(.*)/$1/",1,strip(&varPrefix.currentRuleTmp));
                    * Remove any split symbol from the first part;
                    &varPrefix.ruleFirstPart = prxChange("s/&modSplit_delimiter.//",-1,strip(&varPrefix.ruleFirstPart));
                    * Second part of the current rule (part2);
                    &varPrefix.ruleSecondPart = prxChange("s/(.*)&modSplit_delimiter.(.*)/$2/",1,strip(&varPrefix.currentRuleTmp));
                    * Get width - length of the first part;
                    &varPrefix.Y = put(&width - lengthn(&varPrefix.ruleFirstPart) - &addHyphen.,best.);
                    * If X > Y then there is no need to create this rule, as in this case the whole word can be put on the line;
                    ** Such situation happens when hyphen is added and length of part3 is 1.;
                    ** Also it happens when rule parts are > width and Y becomes negative;
                    if input(&varPrefix.X,best.) <= input(&varPrefix.Y,best.) then do;
                        * Generate the rule for this part;
                        &modSplit_arrayName.[&varPrefix.i] = strip(&modSplit_arrayName.[&varPrefix.i])
                                                         ||".{"||strip(&varPrefix.X)||","
                                                         ||strip(&varPrefix.Y)||"}(?<!&modSplit_nonBorderCl.)\Q"
                                                         ||strip(&varPrefix.ruleFirstPart)||"\E(?=\Q"
                                                         ||strip(&varPrefix.ruleSecondPart)||"\E(?:&modSplit_borderCl.|$))|";
                    end;
                   * Update the rule by removing the last split symbol;
                    &varPrefix.currentRuleTmp = prxChange("s/(.*)&modSplit_delimiter./$1/",1,strip(&varPrefix.currentRuleTmp));
                end;
                * Rules for situation when part2part3 cannot be put on one line;
                * Lines like (?<=part1)part2(?=part3);
                * Process rule part by part from the start;
                &varPrefix.currentRuleTmp = &varPrefix.currentRule; 
                do while (index(&varPrefix.currentRuleTmp,"&delimiter."));
                    * First part of the current rule (part1);
                    &varPrefix.ruleFirstPart = prxChange("s/(.*?)&modSplit_delimiter.(.*)/$1/",1,strip(&varPrefix.currentRuleTmp));
                    * Second part of the current rule (part2part3);
                    &varPrefix.ruleSecondPart = prxChange("s/(.*?)&modSplit_delimiter.(.*)/$2/",1,strip(&varPrefix.currentRuleTmp));
                    * Check whether the part2part3 length > width;
                    if lengthn(strip(prxChange("s/&modSplit_delimiter.//",-1,strip(&varPrefix.ruleSecondPart)))) > &width. then do;
                        * Get maximum part with length <= width ( - 1 in case hyphen is added) and put it in ruleSecondP1 (part2);
                        * Put the rest to ruleSecondP2 (part3);
                        &varPrefix.j = 1;
                        &varPrefix.ruleSecondP1 = "";
                        &varPrefix.ruleSecondP2 = "";
                        do while(not missing(scan(&varPrefix.ruleSecondPart,&varPrefix.j,"&delimiter")));
                            if ( lengthn(&varPrefix.ruleSecondP1)
                                 + 
                                 lengthn(scan(&varPrefix.ruleSecondPart,&varPrefix.j,"&delimiter")) 
                               ) <= %eval(&width - &addHyphen.) and missing(&varPrefix.ruleSecondP2) 
                            then do;
                                &varPrefix.ruleSecondP1 = strip(&varPrefix.ruleSecondP1) 
                                                          || strip(scan(&varPrefix.ruleSecondPart,&varPrefix.j,"&delimiter"));
                            end;
                            else do;
                                &varPrefix.ruleSecondP2 = strip(&varPrefix.ruleSecondP2) 
                                                          || strip(scan(&varPrefix.ruleSecondPart,&varPrefix.j,"&delimiter"));
                            end;
                            &varPrefix.j = &varPrefix.j + 1;
                        end;
                        * Add the rule (?<=(?<!\S)part1)part2(?=part3(?:\s|$));
                        &modSplit_arrayName.[&varPrefix.i] = strip(&modSplit_arrayName.[&varPrefix.i])
                                                             ||"(?<=(?<!&modSplit_nonBorderCl.)\Q"||strip(&varPrefix.ruleFirstPart)||"\E)\Q"
                                                             ||strip(&varPrefix.ruleSecondP1);
                        * Avoid missing \Q\E;    
                        if not missing(&varPrefix.ruleSecondP2) then do;
                            &modSplit_arrayName.[&varPrefix.i] = strip(&modSplit_arrayName.[&varPrefix.i])
                                                                 ||"\E(?=\Q"
                                                                 ||strip(&varPrefix.ruleSecondP2)||"\E(?:&modSplit_borderCl.|$))|";
                        end;
                        else do;
                            &modSplit_arrayName.[&varPrefix.i] = strip(&modSplit_arrayName.[&varPrefix.i])
                                                                 ||"(?=(?:&modSplit_borderCl.|$))|";
                        end;
                    end;
                    * Update the rule by removing the last split symbol;
                    &varPrefix.currentRuleTmp = prxChange("s/(.*?)&modSplit_delimiter./$1/",1,strip(&varPrefix.currentRuleTmp));
                end;
                * Add the .{X,Width-1}\s(?=part1part2part3(?:\s?|$)) part;
                &modSplit_arrayName.[&varPrefix.i] = strip(&modSplit_arrayName.[&varPrefix.i])
                                                     ||".{"||strip(&varPrefix.X)||",%eval(&width.-1)}&modSplit_borderCl.(?=\Q"
                                                     ||strip(&varPrefix.currentWord)||"\E(?:&modSplit_borderCl.|$)))";
                * Handle \,/,$, and @ as they are not espaced by \Q \E, move them outside of \Q\E and escape as \\ \/ \$ \@;
                do while (prxMatch("/\\Q((?!\\E)[^\@\$\\\/])*((?!\\E)[\\\/\@\$])/",trim(&modSplit_arrayName.[&varPrefix.i])));
                    &modSplit_arrayName.[&varPrefix.i] = prxChange("s/\\Q((?:(?!\\E)[^\@\$\\\/])*)((?!\\E)[\@\$\\\/])/\\Q$1\\E\\$2\\Q/"
                                                                   ,-1,trim(&modSplit_arrayName.[&varPrefix.i])
                                                                  );
                end;
                * Remove missing \Q\E;
                &modSplit_arrayName.[&varPrefix.i] = prxChange("s/\\Q\\E//",-1,trim(&modSplit_arrayName.[&varPrefix.i]));
                %if &gmDebug = 1 %then %do;
                    put "NOTE:[PXL] Rule :" &varPrefix.i= ":" &modSplit_arrayName.[&varPrefix.i];
                %end;
                &varPrefix.i = &varPrefix.i+1;
            end;
            * Create a variable with list of rule words for matching.;
            ** Add \Q and \E;
            &modSplit_rulesListMatch. = prxChange("s/(?:[\Q&modSplit_splitChar.\E]+|^)([^\Q&modSplit_splitChar.\E]*)/\\Q$1\\E|/",-1,"%superQ(modSplit_rulesList)");
            ** Remove extra OR (|) at the end;
            &modSplit_rulesListMatch = prxChange("s/\|$//",-1,trim(&modSplit_rulesListMatch));
            ** Handle \,/,$, and @ as they are not espaced by \Q \E, move them outside of \Q\E and escape as \\ \/ \$ \@;
            do while (prxMatch("/\\Q((?!\\E)[^\@\$\\\/])*((?!\\E)[\\\/\@\$])/",trim(&modSplit_rulesListMatch)));
                &modSplit_rulesListMatch = prxChange("s/\\Q((?:(?!\\E)[^\@\$\\\/])*)((?!\\E)[\\\/\@\$])/\\Q$1\\E\\$2\\Q/",-1,trim(&modSplit_rulesListMatch));
            end;
            ** Remove missing \Q\E;
            &modSplit_rulesListMatch = prxChange("s/\\Q\\E//",-1,trim(&modSplit_rulesListMatch));
            %if &gmDebug = 1 %then %do;
                put "NOTE:[PXL] Match list:  " &modSplit_rulesListMatch=;
            %end;
        end;
        * Perform the split in case a rule from the list is found;
        if prxMatch("/(?:&modSplit_borderCl.|^)("||strip(&modSplit_rulesListMatch)||")(?:&modSplit_borderCl.|$)/i",trim(&var.))  then do;
            %if &gmDebug. eq 1 %then %do; put "NOTE:[PXL] 1) Replace with rules" &var.=; %end;
            &varPrefix.regex = " ";
            * Report long words;
            ** Extract all long words;
            &varPrefix.longWords = compbl(prxChange("s/(&modSplit_borderCl.|^)&modSplit_nonBorderCl.{1,&width}(?=&modSplit_borderCl.|$)//i",-1,trim(&var.)));
            &varPrefix.longWords = prxChange("s/(&modSplit_borderCl.|^)("||strip(&modSplit_rulesListMatch)||")(?=&modSplit_borderCl.|$)|//i",-1,trim(&varPrefix.longWords));
            %if "%superQ(wordBorder)" ne "" %then %do;
                * Delete all border characters, except for space;
                &varPrefix.longWords = prxChange("s/[\Q%superQ(wordBorder)\E]//i",-1,trim(&varPrefix.longWords)) ;
            %end;
            ** Report using gmMessage;
            if not missing(&varPrefix.longWords) then do;
                * Quote special characters;
                &varPrefix.longWords = prxChange('s/([()"'',%&])/%str(%$1)/',-1,trim(&varPrefix.longWords));
                &varPrefix.longWords = prxChange('s/%str\(%([,&])\)/%str($1)/',-1,trim(&varPrefix.longWords));
                &varPrefix.longWords = prxChange('s/%str\(%\)/%nrStr(%)/',-1,trim(&varPrefix.longWords));
                &varPrefix.errormsg = resolve('%gmMessage( codeLocation= gmModifySplit/Long word check' ||
                                              ", linesOut    = @Word found in variable &var is longer than the width specified."||
                                              "@A hard split using the width parameter value will be used. "||
                                              "@Record number: " || strip(put(_n_,best.))  ||
                                              ". List of words:@"||
                                              strip(&varPrefix.longWords) || 
                                              ", selectType  = &selectType.)"
                                             );
            end;
            * Iterate through each word and add the rule if the word is found;
            &varPrefix.i = 1;
            do while(not missing(scan("&modSplit_rulesList.",&varPrefix.i,"&splitChar.")));
                * Get the current word;
                 &varPrefix.currentWord = strip(scan("&modSplit_rulesList.",&varPrefix.i,"&splitChar."));
                ** Handle \,/,@,$ as they are not espaced by \Q \E, escape as \\ \/ \@ \$;
                if indexc(&varPrefix.currentWord,"\/@$") then do;
                    &varPrefix.currentWord = "\Q" || strip(prxChange("s/([\\\/\@\$])/\\E\\$1\\Q/",-1,trim(&varPrefix.currentWord))) || "\E";
                    * Remove missing \Q\E;
                    &varPrefix.currentWord = prxChange("s/\\Q\\E//",-1,trim(&varPrefix.currentWord));
                end;
                else do;
                    &varPrefix.currentWord = "\Q"|| strip(&varPrefix.currentWord) ||"\E";
                end;
                * Check it if is in the variable;
                if prxMatch("/(?:&modSplit_borderCl.|^)"||strip(&varPrefix.currentWord)||"(?:&modSplit_borderCl.|$)/i",trim(&var.)) then do;
                    if missing(&varPrefix.regex) then do;
                        &varPrefix.regex = "("||strip(&modSplit_arrayName.[&varPrefix.i]);
                    end;
                    else do;
                        &varPrefix.regex = strip(&varPrefix.regex)||"|"||strip(&modSplit_arrayName.[&varPrefix.i]);
                    end;
                end;
                &varPrefix.i = &varPrefix.i + 1;
            end;
            * Add hardsplit and normal split rules;
            &varPrefix.regex = "s/"||strip(&varPrefix.regex)
                               ||"|(?!.{1,%eval(&width-&minLength-1)}&modSplit_borderCl.&modSplit_nonBorderCl.{%eval(&width.+1)}).{1,&width.}&modSplit_splitCondition.|"
                               ||".{1,&width.}"
                               ||")(\s)?/$1$2&modSplit_delimiterReplace./i";
            * Check whether regex is out of length limit;
            if lengthn(&varPrefix.regex) > 32765 then do;
                &varPrefix.errormsg = resolve('%gmMessage( codeLocation= gmModifySplit/Regex check' ||
                                              ", linesOut    = @You have reached rule length limit."||
                                              '@Please specify less delimiters in your rules%str(,)'||
                                              "@extend the width or use hardsplit with minLength."||
                                              "@Record number: " || strip(put(_n_,best.))  || "." ||
                                              ", selectType  = ABORT)"
                                             );
            end;
            %if &gmDebug. eq 1 %then %do; put "NOTE:[PXL] Regex: " &varPrefix.regex=; %end;
            * Make the split;
            &varPrefix.var_safe = prxChange(strip(&varPrefix.regex),-1,trim(&var.));
            * Delete extra split characters at the end;
            &varPrefix.var_safe= prxChange("s/(.*?)&modSplit_delimiter.+$/$1/",-1,trim(&varPrefix.var_safe));
            * Remove extra space and add hyphen;
            ** Hyphen is added only in case the catch length is width - 1 or less, this gurantees hyphen is not added in case
            ** of a hardsplit;
            %if %qLeft(&addHyphen) = 1 %then %do;
                &varPrefix.var_safe= prxChange( "s/(?<!&modSplit_borderCl.)(?<!(?:(?!&modSplit_delimiter.).){&width.})(?<!&modSplit_delimiter.)(&modSplit_delimiter.)(?!&modSplit_borderCl.)/-$1/i"
                                                ,-1,trim(&varPrefix.var_safe));
            %end;
            * Add indent if required, needs to be done after hyphen processing;
            %if %length(|&modSplit_indent.|) > 2 %then %do;
                &varPrefix.var_safe = prxChange("s/(&modSplit_delimiter.)/$1&modSplit_indent./",-1,trim(&varPrefix.var_safe));
            %end;
            &varPrefix.var_safe= prxChange("s/\s(&modSplit_delimiter.)/$1/",-1,trim(&varPrefix.var_safe));
        end;
        else
    %end;
    %* Perform the split without split rules;
    if prxMatch("/&modSplit_nonBorderCl.{%eval(&width.+1)}/",trim(&var.))  then do;
        * When a long word found and hardsplit is required;
        %if &gmDebug. eq 1 %then %do; put "NOTE:[PXL] 2) Replace without rules and with long words" &var.=; %end;
         * Report long words;
        ** Extract all long words;
        &varPrefix.longWords = compbl(prxChange("s/(&modSplit_borderCl.|^)&modSplit_nonBorderCl.{1,&width}(?=&modSplit_borderCl.|$)//i",-1,trim(&var.)));
        %if "%superQ(wordBorder)" ne "" %then %do;
            * Delete all border characters, except for space;
            &varPrefix.longWords = prxChange("s/[\Q%superQ(wordBorder)\E]//i",-1,trim(&varPrefix.longWords)) ;
        %end;
        ** Report using gmMessage;
        if not missing(&varPrefix.longWords) then do;
            * Quote special characters;
            &varPrefix.longWords = prxChange('s/([()"'',%&])/%str(%$1)/',-1,trim(&varPrefix.longWords));
            &varPrefix.longWords = prxChange('s/%str\(%([,&])\)/%str($1)/',-1,trim(&varPrefix.longWords));
            &varPrefix.longWords = prxChange('s/%str\(%\)/%nrStr(%)/',-1,trim(&varPrefix.longWords));
            &varPrefix.errormsg = resolve('%gmMessage( codeLocation= gmModifySplit/Long word check' ||
                                          ", linesOut    = @Word found in variable &var is longer than the width specified."||
                                          "@A hard split using the width parameter value will be used. "||
                                          "@Record number: " || strip(put(_n_,best.))  ||
                                          ". List of words:@"||
                                          strip(&varPrefix.longWords) || 
                                          ", selectType  = &selectType.)"
                                         );
       end;
       * Make the split;
        &varPrefix.var_safe= prxChange("s/("
                            ||"(?!.{1,%eval(&width-&minLength-1)}&modSplit_borderCl.&modSplit_nonBorderCl.{%eval(&width.+1)}).{1,&width.}&modSplit_splitCondition.|"
                            ||".{1,&width.}"
                            ||")\s?/$1&modSplit_delimiterReplace.&modSplit_indent./"
                                     ,-1,trim(&var.));
        * Delete extra split characters at the end;
        &varPrefix.var_safe= prxChange("s/(.*?)(?:&modSplit_delimiter.)+$/$1/",-1,trim(&varPrefix.var_safe));
    end;
    else do;
        %if &gmDebug. eq 1 %then %do; put "NOTE:[PXL] 3) Simple replace without long words or rules" &var.=; %end;
        * Make a simple split;
        * If only whitechars are used as word boundaries, then do not use lookahead to split faster;
        %if "%superQ(wordBorder)" = "" %then %do;
            &varPrefix.var_safe= prxChange("s/(.{1,&width.})(\s|$)/$1&modSplit_delimiterReplace.&modSplit_indent./",-1,trim(&var.));
        %end;
        %else %do;
            &varPrefix.var_safe= prxChange("s/(.{1,&width.})&modSplit_splitCondition.\s?/$1&modSplit_delimiterReplace.&modSplit_indent./",-1,trim(&var.));
        %end;
        * Delete extra split characters at the end ;
        &varPrefix.var_safe= prxChange("s/(.*?)(?:&modSplit_delimiter.)+$/$1/",-1,trim(&varPrefix.var_safe));
    end;

    * Add an extra space for the last line, if was specified in indentSize by adding + to it;
    %if %index(&indentSize,+) %then %do;
        &varPrefix.var_safe= prxChange("s/^(.*&modSplit_delimiter)(.*)$/$1 $2/",1,trim(&varPrefix.var_safe));
    %end;
    
    * Add indent to the first line if it is not missing;
    %if %eval(&indentSize-0) > 0 %then %do;
        &varPrefix.var_safe= "&modSplit_indent." || trim(&varPrefix.var_safe);
    %end;

    %if &gmDebug. eq 1 %then %do; put "NOTE:[PXL] changed to: " &varPrefix.var_safe=; %end;
    * Check if the result is truncated;
    if  vLength(&var.) < length(trim(&varPrefix.var_safe))
        or
        length(compress(&var.," -&delimiter")) ne length(compress(&varPrefix.var_safe," -&delimiter"))
    then do;
         &varPrefix.errormsg = resolve('%gmMessage( codeLocation= gmModifySplit/Result truncation check' ||
                                       ', linesOut    = The variable length is not sufficient for the result. '||
                                       '@Split is not performed for record number ' ||strip(put(_n_,best.))||
                                        %if "%qTrim(&selectType.)" =  "ABORT" %then %do;
                                            ", selectType  = &selectType.)"
                                        %end;
                                        %else %do;
                                            ", selectType  = E)"
                                        %end;
                               );
    end;
    else do;
        &var. = trim(&varPrefix.var_safe);
    end;

  %gmEnd( headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmmodifysplit.sas $ )

%MEND gmModifySplit;
