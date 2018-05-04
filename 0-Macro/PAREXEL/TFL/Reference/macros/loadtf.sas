
%MACRO LOADTF ( PGN    = &PGID
                ,LS     = 110
				,DEBUG  = N
                );

 %******************************************************************************;
 %* AUTHOR: Catlin Wei ;
 %* ;
 %* PURPOSE: Generate global macro variables for title and footnote, can be used for listings/tables/figures ;
 %* ;
 %* VERSION: 0.1
 %******************************************************************************;
 %* ;
 %* PROGRAM NAME: loadtf.sas ;
 %* ;
 %* PROGRAM LOCATION: \\cn-sha-hfp001\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\03_Macros for Janssen Standard TLFs ;
 %* ;
 %******************************************************************************;
 %* ;
 %* USER REQUIREMENTS: 
 %*  1. Make sure you have a UTILITY.TF generated by %utility;
 %* ;
 %* PGN (Required);
 %*  identify the tables/listings/figures for witch you want to load the title and footnoe;
 %* ;
 %* ;
 %* PROGRAMS CALLED: ;
 %* ;
 %******************************************************************************;
 %* ;
 %* MODIFICATION HISTORY ;
 %*-----------------------------------------------------------------------------;
 %* VERSION: 0.1 ;
 %* AUTHOR: Catlin Wei;
 %* ;
 %*-----------------------------------------------------------------------------;
 %******************************************************************************;

    %LOCAL MPRINT MLOGIC ;
    %LET MPRINT=%sysfunc(getoption(MPRINT));
    %LET MLOGIC=%sysfunc(getoption(MLOGIC));

    %IF %upcase(&DEBUG)=Y %THEN OPTIONS MPRINT MLOGIC;
                          %ELSE OPTIONS NOMPRINT NOMLOGIC;;

    OPTIONS NOCENTER NODATE NONUMBER;
    TITLE;FOOTNOTE;

    %GLOBAL SUBTITLE SUBTITLE1 TITLE1 _NFOOT FOOTNOTE SUBFOOT POP _NLINET _NLINEF PROGRAM PROGPATH DATE;
    %LOCAL NTITLE _TYPE _FOOTNOTE _FOOTNOTE1 _FOOTNOTE2 _FOOTNOTE3 _FOOTNOTE4 _FOOTNOTE5 _FOOTNOTE6 _FOOTNOTE7 _FOOTNOTE8;

    %LET SUBTITLE=;
    %LET SUBTITLE1=;
    %LET FOOTNOTE=;
    %LET SUBFOOT=;
    %LET POP=;
    %LET _NFOOT=0;
    %LET _NLINET=0;
    %LET _NLINEF=0;
    %LET _TYPE=%upcase(%substr(&PGN,1,1));
    %LET DATE=%upcase(%substr(&SYSDATE9.,1,3))%lowcase(%substr(&SYSDATE9.,4));

    %IF %SYSFUNC(EXIST(UTILITY.MULTIRUN)) %THEN %DO;
        PROC SQL NOPRINT;
            SELECT LOWCASE(STRIP(PROGRAM)) INTO :PROGRAM FROM UTILITY.MULTIRUN WHERE upcase(ID)=%upcase("&PGN");
        QUIT;
    %END;
    %ELSE %LET PROGRAM=%lowcase(&PGN);

          %IF &_TYPE=T %THEN %LET PROGPATH=%sysfunc(compress(&_PTAB.&PROGRAM..sas));
    %ELSE %IF &_TYPE=L %THEN %LET PROGPATH=%sysfunc(compress(&_PLIS.&PROGRAM..sas));
    %ELSE %IF &_TYPE=F | &_TYPE=G %THEN %LET PROGPATH=%sysfunc(compress(&_PFIG.&PROGRAM..sas));

    DATA _NULL_;
        LENGTH FOOTNOTE $2500 TITLETXT_ $1600;
        SET UTILITY.TF(WHERE=( strip(upcase(TABLE))=upcase("&PGN") ));
        RETAIN NTITLE NFOOTER _NLINEF 0 FOOTNOTE;

        TEMP=substr(upcase(left(HDFT)),1,1);
        IF TEMP='T' THEN DO;
            NTITLE+1;
            CALL SYMPUT("TITLE"||compress(put(NTITLE,best.)), strip(TITLETXT));
            CALL SYMPUT("NTITLE", compress(put(NTITLE,best.)));
            CALL SYMPUT("POP",strip(population));
        END;
        ELSE IF TEMP='F' THEN DO;
            NFOOTER+1;
            _NLINEF+( int(length(strip(TITLETXT))/&LS)+1 );

                        IF FIRST(STRIP(TITLETXT))='~' THEN TITLETXT_="~R/RTF'\ql\fi-86\li86'"||strip(TITLETXT);
                        ELSE TITLETXT_="~R/RTF'\ql\fi0\li0'"||strip(TITLETXT);

            IF NFOOTER=1 THEN FOOTNOTE=TitleTxT_;
                         ELSE FOOTNOTE=strip(FOOTNOTE)||"~R/RTF'\par'"||strip(TitleTxT_);

            CALL SYMPUT("_FOOTNOTE"||cats(nfooter),strip(TITLETXT_));
            CALL SYMPUT("FOOTYN", "Y");
        END;

        CALL SYMPUT("_NFOOT", cats(NFOOTER));
        CALL SYMPUT("_FOOTNOTE", strip(FOOTNOTE));
        CALL SYMPUT("_NLINEF",strip(put(_NLINEF,8.)));
		CALL SYMPUT("PGN",strip(TABLE));
    RUN;

 %*=========================================================================;
 %* To custom your own title footnote style;
 %* You can also define SUBTITLE FOOTNOTE SUBFOOT outside the %loadtf to custom special style for a specific TLF;
 %*=========================================================================;

    %LET SUBTITLE=&PGN.: %bquote(&TITLE1.)%str(;) &POP. (Study CNTO148AKS3001);
    %LET FOOTNOTE=%bquote(&_FOOTNOTE);
    %LET SUBFOOT= ~{sub [%lowcase(&PGN)] [&PROGPATH] [&DATE]};

 %*=========================================================================;
 %* End ;
 %*=========================================================================;

    %LET _NLINET=%eval( %sysfunc(int(%length(&SUBTITLE)/&LS))+1 );
    OPTIONS &MPRINT &MLOGIC;
%MEND LOADTF;
