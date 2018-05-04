/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: < Janssen > / <CNTO148AKS3001>
  PXL Study Code:        <218185>

  SAS Version:           <92>
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                <Catlin Wei> $LastChangedBy: $
  Creation / modified:   <09/Apr/2015> / $LastChangedDate: $

  Program Location/name: $HeadURL: $

  Files Created:         None

  Program Purpose:       Create RTF styles definition
  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: $
-----------------------------------------------------------------------------*/


*Updating any previous versions of global.rtf *;
ODS PATH global.templates (UPDATE)
         sasuser.templat  (UPDATE)
         sashelp.tmplmst  (READ);

*Defining Style Template *;
PROC TEMPLATE;
	DEFINE STYLE global.tables;
		PARENT=styles.rtf;

		REPLACE FONTS /
				'TitleFont2'         = ("Times New Roman",10pt)
				'TitleFont'          = ("Times New Roman",10pt)
				'StrongFont'         = ("Times New Roman",9pt)
				'EmphasisFont'       = ("Times New Roman",9pt)
				'FixedEmphasisFont'  = ("Times New Roman",9pt)
				'FixedStrongFont'    = ("Times New Roman",9pt)
				'FixedHeadingFont'   = ("Times New Roman",9pt)
				'BatchFixedFont'     = ("Times New Roman",9pt)
				'headingEmphasisFont'= ("Times New Roman",9pt)
				'headingFont'        = ("Times New Roman",9pt)
				'FixedFont'          = ("Times New Roman",9pt)
				'docFont'            = ("Times New Roman",9pt)
				;
		STYLE TABLE FROM OUTPUT /
				BACKGROUND  = _undef_
				CELLPADDING = 0.50pt
				BORDERWIDTH = 0.25pt
				FONT_SIZE   = 10pt
				FRAME       = hsides
				RULES       = groups 
				;
		STYLE SystemTitle /    
				FONT_WEIGHT = bold
				FONT_SIZE    = 12pt
				FONT_FACE = "Times New Roman"
				;
		STYLE HEADER FROM HEADER /
				BACKGROUND  = _undef_
				BORDERWIDTH = 0.25pt
				FRAME       = hsides
				FONT_SIZE    = 9pt
				FONT_WEIGHT   = MEDIUM
				RULES       = groups
				;
		STYLE TableFooterContainer from TableFooterContainer /
				bordertopstyle=hidden;

		STYLE DATA FROM HEADER  /
				BACKGROUND  = _undef_
				FONT_SIZE    = 9pt
				FONT_WEIGHT   = MEDIUM
				RULES       = groups
				;
		STYLE ROWHEADER FROM ROWHEADER /
				RULES      = rows
				BACKGROUND = _undef_
				FRAME      = hsides
				;

		STYLE BODY FROM DOCUMENT  /
				TOPMARGIN    = 1 in
				BOTTOMMARGIN = 1 in
				RIGHTMARGIN  = 1 in
				LEFTMARGIN   = 1 in
				;
	END;

	DEFINE STYLE global.listings;
		PARENT=global.tables;
/*		REPLACE FONTS /*/
/*				'TitleFont2'         = ("Times New Roman",10pt)*/
/*				'TitleFont'          = ("Times New Roman",10pt)*/
/*				'StrongFont'         = ("Times New Roman",8pt)*/
/*				'EmphasisFont'       = ("Times New Roman",8pt)*/
/*				'FixedEmphasisFont'  = ("Times New Roman",8pt)*/
/*				'FixedStrongFont'    = ("Times New Roman",8pt)*/
/*				'FixedHeadingFont'   = ("Times New Roman",8pt)*/
/*				'BatchFixedFont'     = ("Times New Roman",8pt)*/
/*				'headingEmphasisFont'= ("Times New Roman",8pt)*/
/*				'headingFont'        = ("Times New Roman",8pt)*/
/*				'FixedFont'          = ("Times New Roman",8pt)*/
/*				'docFont'            = ("Times New Roman",8pt)*/
/*				;*/
	END;

	DEFINE STYLE GLOBAL.FIGURES;
	    PARENT=GLOBAL.TABLES;
		STYLE GRAPHFONTS FROM GRAPHFONTS /
            'GraphTitleFont' = ("Times New Roman",10pt,bold)
            'GraphLabelFont' = ("Times New Roman",9pt)
            'GraphValueFont' = ("Times New Roman",9pt)
            'GraphDataFont'  = ("Times New Roman",9pt)
            ;
	    STYLE SYSTEMTITLE FROM TITLESANDFOOTERS /
            FONT = ("Times New Roman", 10pt,bold)
            ;
		STYLE SYSTEMFOOTER FROM TITLESANDFOOTERS / 
		    FONT = ("Times New Roman", 9pt)
			;
		REPLACE BODY FROM DOCUMENT /
		    TOPMARGIN = 1in
			BOTTOMMARGIN = 1in
			RIGHTMARGIN = 1in
			LEFTMARGIN = 1in
			;
	END;
RUN;



RUN;
