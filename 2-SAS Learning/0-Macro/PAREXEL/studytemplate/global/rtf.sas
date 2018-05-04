/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   <client> / <protocol>
  PXL Study Code:        <TIME Code>

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                <author> / $LastChangedBy:  $
  Creation Date:         <date in DDMMMYYYY format> / $LastChangedDate:  $

  Program Location/Name: $HeadURL: $

  Files Created:         None

  Program Purpose:       Create RTF styles definition

  Macro Parameters       NA

-------------------------------------------------------------------------------
  MODIFICATION HISTORY:  see Subversion $Rev: $
-----------------------------------------------------------------------------*/
%*----------------------------------------------------------------------------*;
%*--- Underlining justification calls for ODS RTF                          ---*;
%*----------------------------------------------------------------------------*;
  %GLOBAL _spanc _spanl _spanr _spanu _spancj _page;
  %LET _spanc=\brdrb\brdrs\qc;
  %LET _spanl=\brdrb\brdrs\ql;
  %LET _spanr=\brdrb\brdrs\qr;
  %LET _spanu=\brdrb\brdrs\ul;
  %LET _spancj=\qc;

%*----------------------------------------------------------------------------*;
%*--- Defining Style Template                                              ---*;
%*----------------------------------------------------------------------------*;

PROC TEMPLATE;
        DEFINE STYLE global.rtf;
        PARENT=styles.printer;

        REPLACE FONTS/
              'TitleFont2'         = ("Courier New, Courier",9pt)
              'TitleFont'          = ("Courier New, Courier",9pt)
              'StrongFont'         = ("Courier New, Courier",9pt)
              'EmphasisFont'       = ("Courier New, Courier",9pt)
              'FixedEmphasisFont'  = ("Courier New, Courier",9pt)
              'FixedStrongFont'    = ("Courier New, Courier",9pt)
              'FixedHeadingFont'   = ("Courier New, Courier",9pt)
              'BatchFixedFont'     = ("Courier New, Courier",9pt)
              'headingEmphasisFont'= ("Courier New, Courier",9pt)
              'headingFont'        = ("Courier New, Courier",9pt)
              'FixedFont'          = ("Courier New, Courier",9pt)
              'docFont'            = ("Courier New, Courier",9pt);

           STYLE TABLE FROM OUTPUT /
              BACKGROUND  = _undef_
              CELLPADDING = 0.50pt
              BORDERWIDTH = 0.29pt
              FRAME       = void
              RULES       = groups ;

           STYLE HEADER FROM HEADER /
              BACKGROUND  = _undef_
              BORDERWIDTH = 0.29pt
              FRAME       = below
              RULES       = groups;

           STYLE ROWHEADER FROM ROWHEADER /
              RULES      = rows
              BACKGROUND = _undef_
              FRAME      = below;

           REPLACE BODY FROM DOCUMENT "Controls the Body file." /
              TOPMARGIN    = 1.5in
              BOTTOMMARGIN =  1in
              RIGHTMARGIN  = 1in
              LEFTMARGIN   = 1in;
          END;
RUN;
