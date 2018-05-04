%macro AHGfiltercode(infile,putTo=);
    %if %length(%bquote(&putto)) eq %then %let putTo=%AHGaddslash(%AHGtempdir)&sysmacroname..log;

    data _null_;

        infile  "&infile" truncover;
        format line newline $500. blockid $50.;
        retain putflag 0 blockid '' ;
        file "&putTo";
        If _n_=1 then
        do;

        put "/*The start of file &infile*/";
        put ' ';
        end;

        input line $char500.;
        if lowcase(left(line))=:'/*codeblockhead:' then
        do;
        blockid=lowcase(left(tranwrd(lowcase(left(line)),'/*codeblockhead:','')));
        putflag=1;
        end;
        if putflag then put line 1-300;
        newline=compress(lowcase(left(line)));
        if compress(lowcase(left(line)))=compress('/*codeblockend:'||blockid||'*/') then
        do;
        put ' ';
        putflag=0;
        end;

    run;
%mend;

