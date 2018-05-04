%MACRO REPORT ( COLUMN       =
                ,COLLBL       = 
                ,WIDTH        =
                ,ORDVAR       =
                ,PGVAR        =
                ,LINE_VAR     =
                ,ORIENT       =
                ,MARGIN       =  
                ,SMARGIN      =  
                ,HALIGN       =   
                ,CALIGN       =
                ,ADDLBL       =  Y
                ,VJUST        = TOP
                ,LOADTF       =  Y
                ,LINE_FONT    = 0.7
                ,TOPLINE      =  Y
                ,SUBTLINE     =  Y
                ,HEADERLINE   =  N
                ,FOOTLINE     =  N
                ,DEBUG        =  N
                ) / DES = "V1.0";

 %******************************************************************************;
 %* AUTHOR: Catlin Wei ;
 %* ;
 %* PURPOSE: Generate RTF output per Janssen Standard ;
 %* ;
 %* VERSION: 1.0
 %******************************************************************************;
 %* ;
 %* PROGRAM NAME: report.sas ;
 %* ;
 %* PROGRAM LOCATION: \\cn-sha-hfp001\VOL5\Groups\STATISTICAL PROGRAMMING\DeptShare\21_Janssen\03_Macros for Janssen Standard TLFs ;
 %* ;
 %******************************************************************************;
 %* ;
 %* USER REQUIREMENTS: 
 %*  1. Use the most current Version of %report %loadtf, the usage for parameters for %report will be stable after Version 0.1;
 %*  2. Make sure you have set options NOTHREADS NOQUOTELENMAX in SETUP.SAS.
 %*  3. Make sure you defined a global macro varible at the beginning of each Production program, you can refer to the sample code under deptshare;
 %*  4. Generate the final dataset TABLES.&PGID or LISTINGS.PGID, make sure all the variables in the final DS start with GRPX ITEM COL;
 %*  5. Make sure you have a variable to control the page break in the final DS.
 %*  6. The default input dataset is Tables.&PGID or Listings.&PGID.
 %*  7. Parameters marked as Required must be included when using %report;
 %* ;
 %* ;
 %* COLUMN (Required);
 %*  Same with the Column statement in Report Procedure;
 %* ;
 %* COLLBL (Required);
 %*  You must define labels for each variable started with ITEM COL in COLUMN, each label should be separated by |;
 %* ;
 %* WIDTH (Required);
 %*  You must define width for each variable started with ITEM COL in COLUMN, each width should be separated by blank space,total width should less than 99;
 %* ;
 %* ORDVAR;
 %*  Usually used for listings. When you define a variable as ORDER variable, each value of it will display once in the output;
 %* ;
 %* PGVAR (Required for listings/tables with ORDVAR);
 %*  If you define a ORDER variable, you must define a page varibale properly, or the output can not display correctly ;
 %* ;
 %* LINE_VAR;
 %*  Make sure the LINE_VAR has been sorted, %report will insert a blank line between different value;
 %* ;
 %* ORIENT;
 %*  Values: LANDSCAPE PORTRAIT. The default is for listings with more than five columns will be set to LANDSCAPE, otherwise PORTRAIT;
 %* ;
 %* MARGIN;
 %*  The default margin is 7pt when number of display variables less than 5, 2pt when between 5 and 7, 1pt when large than 7;
 %* ;
 %* SMARGIN;
 %*  Margin for spanning header, the default is equal to MARGIN;
 %* ;
 %* HALIGN;
 %*  Align for header, default is C;
 %* ;
 %* CALIGN;
 %*  Align for column, default is L for first column, and C for the other;
 %* ;
 %* ADDLBL;
 %*  Add label defined in the COLLBL to the output dataset;
 %* ;
 %* LOADTF;
 %*  If you want to define a special title footnote then set it to blank;
 %* ;
 %* ;
 %* PROGRAMS CALLED: %loadtf %pageno ;
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

    %LOCAL _NOBS _ITEM _COL _NOBS __I __LENCOL TYPE COLLBL_ DSD FIND RC CHECKVAR
           _NOTE1 _NOTE2 _NOTE ;

    %GLOBAL _ERROR PS_ ;

    %IF %SUBSTR(%UPCASE(&PGID),1,1)=L %THEN %DO;
        %LET TYPE=LISTING;
        %LET OUTFILE=&_plis.%lowcase(&PGID).rtf;
    %END;
    %ELSE %IF %SUBSTR(%UPCASE(&PGID),1,1)=T %THEN %DO;
        %LET TYPE=TABLE;
        %LET OUTFILE=&_ptab.%lowcase(&PGID).rtf;
    %END;

    %LET _ERROR=;
    %LET _NOTE1=;
    %LET _NOTE2=;
    %LET PS_=%sysfunc(getoption(PS));

    PROC DATASETS LIBRARY=WORK NOLIST NOWARN;
        DELETE _INDATA;
    RUN;

    DATA _INDATA;SET &TYPE.S.%lowcase(&PGID);RUN;

    %MACRO COUNT(LIST,OUT,DELI);
        %GLOBAL &OUT;
        %LOCAL __COUNT;
        %LET __COUNT=1;

        %DO %WHILE( %length( |%scan(%str( &LIST ),&__COUNT,&DELI)| )>2 );
            %LET __COUNT=%eval(&__COUNT+1);
        %END;

        %LET &OUT=%eval(&__COUNT-1);
    %MEND COUNT;

    /*create FOOTNOTE SUBFOOT SUBTITLE SUBTITLE1 _NLINET _NLINEF PROGRAM PROGPATH*/
    %IF %upcase(&LOADTF)=Y %THEN %LOADTF(PGN=&PGID);

    PROC SQL NOPRINT;
        SELECT NAME INTO :_ALLVAR SEPARATED BY ' ' FROM DICTIONARY.COLUMNS
        WHERE LIBNAME="&TYPE.S" & MEMNAME=%upcase("&PGID");
    QUIT;

    DATA _NULL_;
        LENGTH CHECKVAR $1000 DISVAR DISVAR_ $200;
        CHAR="%bquote(&COLUMN)";
        L1=indexc(CHAR,'"',"'");
        CHECKVAR=CHAR;
        DO WHILE (L1>0);
            L2=indexc(substr(CHECKVAR,L1+1),'"',"'");
            CHECKVAR=SUBSTR(CHECKVAR,1,L1-1)||SUBSTR(CHECKVAR,L1+L2+1);
            L1=indexc(CHECKVAR,'"',"'");
        END;
        CHECKVAR=upcase(compbl(compress(CHECKVAR,'()"')));
        CALL SYMPUT("CHECKVAR",CHECKVAR);

        L3=1;
        DISVAR=' ';
        DO WHILE (SCAN(CHECKVAR,L3,' ')^=' ');
            DISVAR_=UPCASE(SCAN(CHECKVAR,L3,' '));

            IF not index(%upcase("&_ALLVAR"),%upcase(STRIP(DISVAR_))) THEN DO;
                CALL SYMPUT("_ERROR2",DISVAR_);
            END;

            IF SUBSTR(DISVAR_,1,4)='ITEM' | SUBSTR(DISVAR_,1,3)='COL' THEN DISVAR=strip(DISVAR)||' '||strip(DISVAR_);
            L3=L3+1;
        END;
        CALL SYMPUT("DISVAR",DISVAR);
    RUN;

    %IF &_ERROR^=%str( ) %THEN %DO;
        %LET _ERROR=ERROR: %sysfunc(strip(&_ERROR2)) in the COLUMN statement was not find in %UPCASE(&TYPE.S.&PGID).;
        %GOTO EXIT;
    %END;

    %COUNT(&DISVAR,_NDSVAR,%str( ));

    %*Add Labels to the output dataset;

    %IF %upcase(&ADDLBL)=Y %THEN %DO;

        PROC SQL NOPRINT;SELECT count(*) INTO :_NOBS FROM _INDATA;QUIT;

        DATA &TYPE.S.%lowcase(&PGID);

            %IF &_NOBS=0 %THEN %DO;
                LENGTH %scan(&DISVAR,1,%str( )) $200;
                %scan(&DISVAR,1,%str( ))="No Data to Report.";
                OUTPUT;
                %LET _NOTE1= NOTE: The input dataset is NULL!!!;
            %END;
            %ELSE %DO;
                SET &TYPE.S.%lowcase(&PGID);
                OUTPUT;
            %END;

            LABEL %DO __I=1 %TO &_NDSVAR;
                      %scan(&DISVAR,&__I,%str( ))=
                          %IF %length(%scan(%str( &COLLBL),&__I,%str(|))) %THEN "%sysfunc(strip( %scan(%str( &COLLBL),&__I,%str(|)) ))";
                                                                          %ELSE "%scan(%str( &COLLBL),&__I,%str(|))";
                  %END;;
        RUN;

    %END;

    %IF %length(&ORIENT)=0 %THEN %DO;
        %IF &TYPE=LISTING & &_NDSVAR>5 %THEN %LET ORIENT=LANDSCAPE;
        %ELSE %LET ORIENT=PORTRAIT; 
    %END;

    %IF %length(&MARGIN)=0 %THEN %DO;
              %IF &_NDSVAR>5 %THEN %LET MARGIN=2PT;
        %ELSE %IF &_NDSVAR>7 %THEN %LET MARGIN=1PT;
        %ELSE %LET MARGIN=7PT;
    %END;

    %IF %length(&SMARGIN)=0 %THEN %LET SMARGIN=&MARGIN;

    %LET ORDVAR=%upcase(&ORDVAR);
    %LET LINE_VAR=%upcase(&LINE_VAR);
    %LET PGVAR=%upcase(&PGVAR);

    %IF not %index(%str( &ORDVAR ),%str( &PGVAR )) & %length(&PGVAR) %THEN %LET ORDVAR=&PGVAR &ORDVAR;
    %IF not %index(%str( &COLUMN),%str( &PGVAR )) & %length(&PGVAR) %THEN %LET COLUMN=&PGVAR &COLUMN;
    
    %COUNT(&WIDTH,_NWIDTH,%str( ));
    %IF %sysevalf(&_NWIDTH<&_NDSVAR) %THEN %DO;
        %LET _ERROR3=ERROR: WIDTH is not enough for variables begin with ITEM COL in COLUMN;
        %GOTO EXIT;
    %END;

    %COUNT(&COLLBL,_NCOLLBL,%str(|));
    %IF %sysevalf(&_NCOLLBL^=&_NDSVAR) %THEN %DO;
        %LET _ERROR=ERROR: COLLBL should define the same number of labels for variables begin with ITEM COL in COLUMN.;
        %GOTO EXIT;
    %END;

    %IF %length(&LINE_VAR) & not %index(&CHECKVAR,&LINE_VAR) %THEN %DO;
        %LET _ERROR=ERROR: &LINE_VAR was not find in COLUMN statement.;
        %GOTO EXIT;
    %END;

    %COUNT(&CALIGN,_NCALIGN,%str( ));
    %COUNT(&HALIGN,_NHALIGN,%str( ));

    %*Do the output;

    %IF %length(&SUBTITLE)=0 %THEN %DO;
        %LET _ERROR=%STR(ERROR: Can not find TITLE for %UPCASE(&TYPE.S.&PGID).);
        %GOTO EXIT;
    %END;

    ***output page for listing***;
    %IF &TYPE.=LISTING %THEN %DO;
        FOOTNOTE j=r "Page XXXX of YYYY";;
    %END;

    %IF %upcase(&SUBTLINE)=Y %THEN %LET SUBTLINE=\brdrb\brdrs\brdrw10;

    OPTIONS ORIENTATION=&ORIENT;
    ODS ESCAPECHAR='~';
    ODS LISTING CLOSE;
    ODS HTML CLOSE;
    ODS RTF FILE="&OUTFILE"    STYLE=GLOBAL.&TYPE.S
                               HEADERY = 1
                               FOOTERY = 0
							   WORDSTYLE = "{\s1 Caption;}{\s2 Heading 1;}"
                               ;

    ODS DECIMAL_ALIGN;
/*    ODS RTF STARTPAGE=NOW;*/
    PROC REPORT DATA=&TYPE.S.&PGID NOWINDOWS MISSING SPLIT='$'
         style(REPORT)=[PROTECTSPECIALCHARS=OFF JUST=C ASIS=ON OUTPUTWIDTH=99.99%
                        %IF %upcase(&TOPLINE)^=Y %THEN BORDERTOPCOLOR=WHITE;
                        %IF %upcase(&FOOTLINE)^=Y %THEN BORDERBOTTOMCOLOR=WHITE;%ELSE BORDERBOTTOMCOLOR=BLACK;
                        ]
         style(LINES)=[PROTECTSPECIALCHARS=OFF ASIS=ON]
         style(HEADER)=[PROTECTSPECIALCHARS=OFF ASIS=ON JUST=C MARGINLEFT=&SMARGIN MARGINRIGHT=&SMARGIN 
                        %IF %upcase(&HEADERLINE)=N %THEN BORDERBOTTOMCOLOR=WHITE;%ELSE BORDERBOTTOMCOLOR=BLACK; 
                        ]
         style(COLUMN)=[PROTECTSPECIALCHARS=OFF ASIS=ON JUST=C VJUST=&VJUST];

        COLUMN (( %IF %length(&SUBTITLE1) %THEN "~R/RTF'\fs0\brdrb\brdrs\brdrw10\fs20\b\ql\fi-1152\li1152'%str( )&SUBTITLE1";
                %IF %length(&SUBTITLE) %THEN "~R/RTF%bquote(')\fs0\fs20\b\ql&SUBTLINE\fi-1152\li1152\s1%bquote(')%str( )&SUBTITLE";
                &COLUMN
                ));

        %DO __I=1 %TO &_NDSVAR;
            %LET COLLBL_=%scan(%str( &COLLBL),&__I,%str(|));
            DEFINE %scan(&DISVAR,&__I,%str( )) / DISPLAY FLOW "&COLLBL_" %IF %length(&COLLBL_) & %upcase(&HEADERLINE)=N %THEN "~R/RTF'\fs0\brdrb\brdrs\brdrw10"; 

                STYLE(COLUMN)=[CELLWIDTH=%scan(&WIDTH,&__I,%str( ))% ASIS=ON
                               %IF &__I=1 %THEN JUST=L; %ELSE JUST=C;

                                     %IF &_NCALIGN=1 %THEN JUST=&CALIGN;
                               %ELSE %IF &_NCALIGN>1 %THEN JUST=%scan(&CALIGN,&__I,%str( ));
                               ]

                STYLE(HEADER)=[%IF &__I^=1 %THEN MARGINLEFT=&MARGIN;
                               %IF &__I^=&_NDSVAR %THEN MARGINRIGHT=&MARGIN; 
                               %IF &__I=1 %THEN JUST=C; %ELSE JUST=C;

                                     %IF &_NHALIGN=1 %THEN JUST=&HALIGN;
                               %ELSE %IF &_NHALIGN>1 %THEN JUST=%scan(&HALIGN,&__I,%str( ));
                               ]

                %IF %index( %str( &ORDVAR ),%str( )%scan(&DISVAR,&__I,%str( ))%str( ) ) %THEN %DO;
                    %LET ORDVAR=%sysfunc(tranwrd( %str( &ORDVAR ),%str( )%scan(&DISVAR,&__I,%str( ))%str( ),%str( )));
                    ORDER ORDER=INTERNAL
                %END;;

            %LET CHECKVAR=%sysfunc(tranwrd( %str( &CHECKVAR ),%str( )%scan(&DISVAR,&__I,%str( ))%str( ),%str( )));
        %END;

        %IF not %index(%str( &DISVAR ),%str( &LINE_VAR )) & %length(&LINE_VAR) %THEN %DO;
            %LET ORDVAR=%sysfunc(tranwrd( %str( &ORDVAR ),%str( )%scan(&LINE_VAR,&__I,%str( ))%str( ),%str( )));
            %IF not %index( %str( &DISVAR ),%str( &LINE_VAR ) ) %THEN %DO;
                DEFINE &LINE_VAR / ORDER ORDER=INTERNAL NOPRINT;
                %LET CHECKVAR=%sysfunc(tranwrd( %str( &CHECKVAR ),%str( &LINE_VAR ),%str( )));
            %END;
        %END;

        %IF %length(&ORDVAR)>0 %THEN %DO;
            %COUNT(&ORDVAR,_NODVAR,%str( ));

            %DO __I=1 %TO &_NODVAR;
                %IF not %index(&CHECKVAR,%scan(&ORDVAR,&__I,%str( ))) & %scan(&ORDVAR,&__I,%str( ))^=&LINE_VAR & %scan(&ORDVAR,&__I,%str( ))^=&PGVAR %THEN %DO;
                    %LET _ERROR=%scan(&ORDVAR,&__I,%str( )) was not find in the COLUMN statement.;
                    %GOTO EXIT;
                %END;

                DEFINE %scan(&ORDVAR,&__I,%str( )) / ORDER ORDER=INTERNAL NOPRINT;
                %LET CHECKVAR=%sysfunc(tranwrd( %str( &CHECKVAR ),%str( )%scan(&ORDVAR,&__I,%str( ))%str( ),%str( )));
            %END;

        %END;

        %IF %length(&CHECKVAR) %THEN %DO;
            %LET _NOTE2= NOTE:%upcase(&CHECKVAR) was not defined as a display variable or order variable.;

            %COUNT(&CHECKVAR,_NCKVAR,%str( ));

            %DO __I=1 %TO &_NCKVAR;
                DEFINE %scan(&CHECKVAR,&__I,%str( )) / NOPRINT;
            %END;
        %END;

        %IF %length(&PGVAR) %THEN BREAK AFTER &PGVAR / PAGE;;

        %IF &LINE_VAR^=%str( ) %THEN %DO;
            COMPUTE AFTER  &LINE_VAR / STYLE(LINES)={OUTPUTWIDTH=99.99% FONT_SIZE=%sysevalf(10*&LINE_FONT)pt};
                LINE ' ';
            ENDCOMP;
        %END;

    RUN;

*footnote;

    %IF %length(&FOOTNOTE)=0 %THEN %DO;
        %IF %length(&LINE_VAR)=0 %THEN ODS RTF TEXT="~S={OUTPUTWIDTH=99.99% FONTSIZE=%sysevalf(10*&LINE_FONT)pt} ~R/RTF'\ql'   ";
            %ELSE ODS RTF TEXT="~S={OUTPUTWIDTH=99.99% FONTSIZE=1pt} ~R/RTF'\ql'   ";; 
   %END;
    %ELSE %DO;
        %IF %length(&LINE_VAR)=0 %THEN ODS RTF TEXT="~S={OUTPUTWIDTH=99.99% FONTSIZE=%sysevalf(10*&LINE_FONT)pt}       ";;

        ODS RTF TEXT="~S={OUTPUTWIDTH=99.99% PROTECTSPECIALCHARS=ON}%bquote(&FOOTNOTE)";
    %END;

    %IF %length(&SUBFOOT) %THEN %DO;
        ODS RTF TEXT="~S={textalign= r just=r outputwidth=99.99% protectspecialchars=on}~R/RTF'\brdrt\brdrs\brdrw10'&SUBFOOT";
    %END;

    ODS RTF CLOSE;

    %IF &TYPE.=LISTING %THEN %DO;
        %PAGENO(FILE="&_PLIS.%lowcase(&PGID.).rtf");
    %END;

    %EXIT:

    QUIT;
    ODS LISTING;
    %PUT  === LINES USED TO GENERATE OUTPUT IS &PS_====;
    %LET _NOTE=&_ERROR&_NOTE1&_NOTE2;
    %IF %length(&_NOTE) %THEN %DO;
        %PUT ============================================================;
        %PUT  ;
        %IF %length(&_ERROR) %THEN %PUT &_ERROR;
        %IF %length(&_NOTE1) %THEN %PUT &_NOTE1;
        %IF %length(&_NOTE2) %THEN %PUT &_NOTE2;
        %PUT  ;
        %PUT ============================================================;

    %END;

    PROC DATASETS LIBRARY=WORK NOLIST NOWARN;
        DELETE _INDATA;
    QUIT;

    OPTIONS &MPRINT &MLOGIC;
%MEND REPORT;
