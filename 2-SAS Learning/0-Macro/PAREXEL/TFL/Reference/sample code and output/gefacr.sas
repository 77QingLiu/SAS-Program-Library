
/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / CNTO148AKS3001
  PXL Study Code:        218184

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Catlin Wei $LastChangedBy: $
  Creation / modified:   19Oct2015 / $LastChangedDate: $

  Program Location/name: $HeadURL: $

  Files Created:         gefacr01.sas7bdat
                         gefacr03.sas7bdat
                         gefacr.log

  Program Purpose:       To Create Figures GEFACR01 GEFACR03
  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 85 $
-----------------------------------------------------------------------------*/
title;footnote;
dm "log; clear; out; clear;";
proc datasets nolist lib=work memtype=data kill;quit;

%LET PGID=gefaCR01;
/* -------------Program body--------------------- */

PROC SORT DATA=ANALYSIS.ADEFF OUT=ADEFF NODUPKEY;
   WHERE PARAMCD in ('ACR20T' 'ACR50T') & FASFL="Y" & 2000<AVISITN<=2024 & ANL01FL='Y';
   BY PARAMCD AVISITN TRT01PN USUBJID;
RUN;

ODS OUTPUT BINOMIALPROP=ESTIMATE BINOMIALCLS=CL;
PROC FREQ DATA=ADEFF;
    BY PARAMCD AVISITN AVISIT TRT01PN;
    TABLE AVALC/OUT=A BINOMIAL(LEVEL='Y' CL=WALD);
RUN;

DATA FIGURES.GEFACR01 FIGURES.GEFACR03;
    LENGTH TRT01P $50;
    MERGE ESTIMATE(WHERE=(NAME1="_BIN_")) CL(DROP=AVISIT TABLE);
    BY PARAMCD AVISITN TRT01PN;
    NVALUE1=NVALUE1*100;
    UPPERCL=UPPERCL*100;
    LOWERCL=LOWERCL*100;
    avisit=propcase(avisit);
    grpx1=avisitn-2000;

     IF TRT01PN=1 THEN TRT01P='Placebo';
    ELSE IF TRT01PN=2 THEN TRT01P='Golimumab 2 mg/kg';

    IF PARAMCD='ACR20T' THEN OUTPUT FIGURES.GEFACR01;
    IF PARAMCD='ACR50T' THEN OUTPUT FIGURES.GEFACR03;
    RENAME NVALUE1=ESTIMATE;
    ATTRIB _ALL_ LABEL=' ';
    FORMAT _ALL_;
    INFORMAT _ALL_;
    KEEP AVISITN avisit TRT01PN TRT01P NVALUE1 UPPERCL LOWERCL grpx1;
RUN;

/*DATA FIGURES.GEFACR01;*/
/*    SET FIGURES.GEFACR01a;*/
/*    IF AVISITN<=2016;*/
/*RUN;*/

%MACRO FIGURE(DATA,INDEX);

    %AXIS_RANGE(DATA=FIGURES.&DATA,XORYAXIS=Y,VAL=ESTIMATE,INTERVAL=6,UPPER=UPPERCL,LOWER=LOWERCL);

    PROC TEMPLATE;
        DEFINE STATGRAPH PROFILE;
            BEGINGRAPH ;

                DISCRETEATTRMAP NAME="TRT";
                    VALUE "Placebo" / MARKERATTRS=(SYMBOL=CIRCLEFILLED COLOR=BLACK) LINEATTRS=(PATTERN=SOLID THICKNESS=0.5 COLOR=BLACK);
                    VALUE "Golimumab 2 mg/kg" / MARKERATTRS=(SYMBOL=SQUAREFILLED COLOR=BLACK) LINEATTRS=(PATTERN=SHORTDASH THICKNESS=0.5 COLOR=BLACK);
                ENDDISCRETEATTRMAP;

                DISCRETEATTRVAR ATTRVAR=TRT VAR=TRT01P ATTRMAP="TRT";

                LAYOUT LATTICE / ORDER=ROWMAJOR ROWS=2 COLUMNDATARANGE=UNION ROWWEIGHTS=(0.85 0.15);

                    ROWHEADERS;
                        LAYOUT GRIDDED / COLUMNS=1;
                            ENTRY "&INDEX.Response" / ROTATE=90;
                        ENDLAYOUT;
                    ENDROWHEADERS;

                    LAYOUT OVERLAY / XAXISOPTS=( TYPE=DISCRETE DISPLAY=(TICKS LINE) OFFSETMIN=0.04
                                            discreteopts=(tickvaluelist=("2" "4" "6" "8" "10" "12" "14" "16" "18" "20" "22" "24")))
                                     YAXISOPTS=(DISPLAY=(TICKS TICKVALUES) GRIDDISPLAY=OFF
                                                LINEAROPTS=(VIEWMIN=0 VIEWMAX=50 TICKVALUEFORMAT=12.%EVAL(&DECIMAL+0)
                                                            TICKVALUESEQUENCE=(START=-10 END=90 INCREMENT=10))
                                               );
                        SERIESPLOT X=grpx1 Y=ESTIMATE / GROUP=TRT01P NAME="SERIES" GROUPDISPLAY=CLUSTER CLUSTERWIDTH=0.5 CONNECTORDER=XAXIS;
                        SCATTERPLOT X=grpx1 Y=ESTIMATE / GROUP=TRT01P YERRORUPPER=UPPERCL YERRORLOWER=LOWERCL NAME="SCATTER" GROUPDISPLAY=CLUSTER CLUSTERWIDTH=0.5
                                                      ERRORBARATTRS=(THICKNESS=0.5);
/*                        REFERENCELINE Y=0 / LINEATTRS=(PATTERN=SHORTDASH);*/
                    ENDLAYOUT;

                    LAYOUT OVERLAY / WALLDISPLAY=NONE XAXISOPTS=( TYPE=DISCRETE DISPLAY=NONE OFFSETMIN=0.04
                                    discreteopts=(tickvaluelist=("2" "4" "6" "8" "10" "12" "14" "16" "18" "20" "22" "24")))
                                       ;
                        BLOCKPLOT X=grpx1 BLOCK=avisit / DISPLAY=(VALUES) VALUEHALIGN=CENTER REPEATEDVALUES=TRUE LABELATTRS=(SIZE=7PT) VALUEATTRS=(SIZE=8PT);
                        ENTRY HALIGN=CENTER "Visit" / LOCATION=OUTSIDE VALIGN=BOTTOM;
                    ENDLAYOUT;

                    SIDEBAR / ALIGN=BOTTOM SPACEFILL=FALSE;
                        MERGEDLEGEND "SERIES" "SCATTER" / OPAQUE=FALSE BORDER=FALSE HALIGN=RIGHT VALIGN=BOTTOM PAD=(TOP=15px) DISPLAYCLIPPED=TRUE;
                    ENDSIDEBAR;

                ENDLAYOUT;

            ENDGRAPH;
        END;
    RUN;

    OPTIONS ORIENTATION= LANDSCAPE;
    ODS _ALL_ CLOSE;
    ODS RTF FILE="&_PFIG.%LOWCASE(&DATA).rtf" IMAGE_DPI=300 STYLE=GLOBAL.FIGURES NOGTITLE NOGFOOTNOTE OPERATOR="{\dntblnsbdb}";
    TITLE;FOOTNOTE;

    %LOADTF(PGN=&DATA);

    ODS RTF TEXT="~S={outputwidth=99.99% protectspecialchars=on}~R/RTF'\brdrt\brdrs\brdrb\brdrs\brdrw10\fs3' ~R/RTF'\par\fs20\b\ql\fi-1152\li1152'&SUBTITLE";

    ODS GRAPHICS / RESET NOBORDER IMAGEFMT=JPG WIDTH=8in HEIGHT=5in NOSCALE;
    PROC SGRENDER DATA=FIGURES.&DATA TEMPLATE=PROFILE;
        DYNAMIC TITLE=" ";
    RUN;

    ODS RTF TEXT="~S={outputwidth=99.99% protectspecialchars=on}&FOOTNOTE";
    ODS RTF TEXT="~S={textalign= r just=r outputwidth=99.99% protectspecialchars=on}~R/RTF'\brdrt\brdrs\brdrw10'&SUBFOOT";

    ODS _ALL_ CLOSE;

%MEND FIGURE;

%FIGURE(DATA=GEFACR01,INDEX=Proportion of Subjects Achieving ACR 20)

%FIGURE(DATA=GEFACR03,INDEX=Proportion of Subjects Achieving ACR 50)
