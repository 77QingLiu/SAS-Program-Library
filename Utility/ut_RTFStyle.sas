/*-----------------------------------------------------------------------------
    Program Purpose:       The macro %ut_RTFStyle define a RTF style to export

    Macro Parameters:

    Name:                MacroName
        Allowed Values:    Any valid macro name
        Default Value:     REQUIRED
        Description:       The name of a dataset (or view) that should be
                         used for reporting its number of logical observations.

-----------------------------------------------------------------------------*/
ods path sasuser.TEMPLAT(update) sashelp.TMPLMST(read);
/* ods path (prepend) work.templat(update); */
/* refer to SAS blog: https://blogs.sas.com/content/graphicallyspeaking/2017/11/17/advanced-ods-graphics-deeper-dive-item-stores/ */
*-------------------  A NEW ODS STYLE CALLED Arial9 --------------------;
proc template ;
    define style Arial9  /* / store = sasuser.TEMPLAT */; 
    parent = styles.journal ;
    replace fonts /
        'TitleFont2'          =   ("Arial", 8pt,italic)
        'TitleFont'           =    ("Arial",9pt,bold)
        'StrongFont'          =   ("Arial",9pt,Bold)
        'EmphasisFont'        = ("Arial",9pt,Bold)

        'FixedEmphasisFont'   = ("Courier",7pt,Bold)
        'FixedStrongFont'     =  ("Courier",7pt,Bold)
        'FixedHeadingFont'    = ("Courier",7pt,Bold)
        'BatchFixedFont'      =   ("Courier",7pt)
        'FixedFont'           =        ("Courier",7pt,Italic)

        'headingEmphasisFont' = ("Arial",9pt,Bold)
        'TextFont'            = ("Arial",9pt,italic)
        'headingFont'         = ("Arial",9pt,Bold)
        'docFont'             = ("Arial",9pt) ; /* DEFAULT FONT SELECTION */

    style Table from Output /
        asis        = on
        rules       = groups
        cellpadding = 1pt
        cellspacing = 1pt
        borderwidth = 0.75pt
        nobreakspace= off
        frame       = symget("frame")
        just        = center
        vjust       = bottom ; /* DEFAULT OPTIONS FOR TABLE LAYOUT AND BORDERS */

    replace Body from Document
        "Undef margins so we get the margins from the printer or SYS option" /
        bottommargin  = _undef_
        topmargin     = _undef_
        rightmargin   = _undef_
        leftmargin    = _undef_
        pagebreakhtml = _undef_ ; /* SET PAGE MARGINS */

    style SystemFooter from TitlesAndFooters
        "Controls system title text." /
        font = Fonts('TitleFont2') ;

    style SystemTitle from TitlesAndFooters
        "Controls system title text." /
        font                = Fonts('TitleFont')
        protectspecialchars = off ;

    style UserText from Note /* CHANGES STYLE OF TEXT= ODS OUTPUT */
        "Controls the TEXT= style" /
       protectspecialchars = off
       cellwidth           = symget("txtwidth") /* WIDTH OF THE RESULTING TEXT BOX SET AS A MACRO PARAMETER TO ALLOW FLEXIBILITY */
       font                = fonts('TextFont')
       just                = left ;

    replace NoteContent from Note  /* CHANGES THE STYLE WITHIN THE COMPUTED BLOCK */
        "Controls the contents for NOTEs." /
        just           = L
        font           = fonts('TextFont')
        bordertopwidth =0px
        frame           =void ;

    style Date from Container
        "Abstract. Controls how date fields look." /
        outputwidth = 100%
        font        = fonts('docFont');

    style ByLine /
        font = fonts('EmphasisFont') ;

    style BodyDate from Date
        "Controls the date field in the Body file." /
        cellspacing = 0
        cellpadding = 0
        font        = fonts('docFont');

    /* FROM STATISTICAL STYLE */
    class GraphFonts /
    'GraphTitleFont'    =   (" <sans-serif> , <MTsans-serif> ",9pt,bold)
    'GraphFootnoteFont' =(" <sans-serif> , <MTsans-serif> ",8pt,italic)
    'GraphLabelFont'    =   (" <sans-serif> , <MTsans-serif> ",9pt)
    'GraphValueFont'    =   (" <sans-serif> , <MTsans-serif> ",8pt)
    'GraphDataFont'     =    (" <sans-serif> , <MTsans-serif> ",8pt)
    'GraphUnicodeFont'  = (" <MTsans-serif-unicode> ",8pt)
    'GraphAnnoFont'     =    (" <sans-serif> , <MTsans-serif> ",9pt);

    class GraphColors /
        'gablock'           = cxF5F5F0
        'gblock'            = cxDFE6EF
        'gcclipping'        = cxDC531F
        'gclipping'         = cxE7774F
        'gcstars'           = cx445694
        'gstars'            = cxCAD5E5
        'gcruntest'         = cxE7774F
        'gruntest'          = cxE6E6CC
        'gccontrollim'      = cxCCCC97
        'gcontrollim'       = cxFFFFE3
        'gdata'             = cx000000/*cxCAD5E5*/
        'gcdata'            = cx000000
        'goutlier'          = cxB9CFE7
        'gcoutlier'         = cx000000
        'gfit2'             = cxDC531F
        'gfit'              = cx667FA2
        'gcfit2'            = cxDC531F
        'gcfit'             = cx667FA2
        'gconfidence2'      = cxE3D5CD
        'gconfidence'       = cxB9CFE7
        'gcconfidence2'     = cxE3D5CD
        'gcconfidence'      = cxE3D5CD
        'gpredict'          = cx667FA2
        'gcpredict'         = cx445694
        'gpredictlim'       = cx7486C4
        'gcpredictlim'      = cx7486C4
        'gerror'            = cxCA5E3D
        'gcerror'           = cxA33708
        'greferencelines'   = cxA5A5A5
        'gheader'           = colors('docbg')
        'gconramp3cend'     = cxFF3A2E
        'gconramp3cneutral' = cxEBC79E
        'gconramp3cstart'   = cx445694
        'gramp3cend'        = cx667FA2
        'gramp3cneutral'    = cxFFFFFF
        'gramp3cstart'      = cxAFB5A6
        'gconramp2cend'     = cxA23A23
        'gconramp2cstart'   = cxFFF1EF
        'gramp2cend'        = cx445694
        'gramp2cstart'      = cxF3F5FC
        'gtext'             = cx000000
        'glabel'            = cx000000
        'gborderlines'      = cxFFFFFF
        'goutlines'         = cx000000
        'ggrid'             = cxE6E6E6
        'gaxis'             = cx000000
        'gshadow'           = cx8F8F8F
        'gfloor'            = cxDCDAC9
        'glegend'           = cxFFFFFF
        'gwalls'            = cxFFFFFF
        'gcdata12'          = cxF9DA04
        'gdata12'           = cxDDD17E
        'gcdata11'          = cxB38EF3
        'gdata11'           = cxB7AEF1
        'gcdata10'          = cx47A82A
        'gdata10'           = cx87C873
        'gcdata9'           = cxD17800
        'gdata9'            = cxCF974B
        'gcdata8'           = cxB26084
        'gdata8'            = cxCD7BA1
        'gcdata7'           = cx2597FA
        'gdata7'            = cx94BDE1
        'gcdata6'           = cx7F8E1F
        'gdata6'            = cxBABC5C
        'gcdata5'           = cx9D3CDB
        'gdata5'            = cxB689CD
        'gcdata4'           = cx543005
        'gdata4'            = cxA9865B
        'gcdata3'           = cx01665E
        'gdata3'            = cx66A5A0
        'gcdata2'           = cxA23A2E
        'gdata2'            = cxD05B5B
        'gcdata1'           = cx000000
        'gdata1'            = cx000000;

    class Graph from Graph
        "Graph Attributes" /
        borderspacing = 1
        borderwidth   = 0;

    class GraphBackground from GraphBackground
        "Graph background attributes" /
        color           = GraphColors('gwalls')
        backgroundcolor = GraphColors('gwalls');

    class GraphGridLines from GraphGridLines
        "Grid line attributes" /
         linestyle = 2 ;

    class GraphDataDefault /
         markersize    = 10px
         linethickness = 3px
         markersymbol  = "SquareFilled"
         linestyle     = 1
         contrastcolor = Black
         color         = Black;

    class GraphData /
         markersize    = 10px
         linethickness = 4px
         markersymbol  = "SquareFilled"
         linestyle     = 1
         contrastcolor = Black
         color         = Black ;

    class GraphData1 /
         markersize    = 10px
         linethickness = 4px
         markersymbol  = "SquareFilled"
         linestyle     = 1
         contrastcolor = black
         color         = black
         transparency  = 0.7 ;

    class GraphData2 /
         markersize    = 10px
         linethickness = 4px
         markersymbol  = "triangleFilled"
         linestyle     = 2
         contrastcolor = blue
         color         = blue;

    class GraphData3 /
         markersize    = 10px
         linethickness = 4px
         markersymbol  = "diamondFilled"
         linestyle     =4
         contrastcolor = red
         color         = red
         transparency  = 0.7 ;

    class GraphData4 /
         markersize    = 10px
         linethickness = 4px
         markersymbol  = "StarFilled"
         linestyle     = 15
         contrastcolor = green
         color         = green;

    class GraphData5 /
         markersize    = 10px
         linethickness = 4px
         markersymbol  = "CircleFilled"
         linestyle     = 14
         contrastcolor = Orange
         color         = Orange
         transparency  = 0.5 ;

    /* THESE OPTIONS ARE USED FOR INDIVIDUAL PROFILE PLOTS */
    class GraphData6 /
         markersize    = 1px
         linethickness = 3px
         markersymbol  = "CircleFilled"
         linestyle     = 1
         contrastcolor = Blue
         color         = DarkBlue ;

    class GraphData7 /
         markersize    = 1px
         linethickness = 3px
         markersymbol  = "Circle"
         linestyle     = 1
         contrastcolor = Blue
         color         = DarkBlue ;

    class GraphData8 /
         markersize    = 4px
         linethickness = 3px
         markersymbol  = "TriangleFilled"
         linestyle     = 1
         contrastcolor = MediumGray
         color         = Red ;

    class GraphData9 /
         markersize    = 4px
         linethickness = 3px
         markersymbol  = "Triangle"
         linestyle     = 1
         contrastcolor = MediumGray
         color         = Red ;
    /* END OF STYLES USED FOR INDIVIUAL PROFILE PLOTS */

    class GraphConfidence /
        linestyle     = 1
        linethickness = 3px ;

    class GraphAxisLines /
        tickdisplay   = "outside"
        linethickness = 1px
        linestyle     = 1
        contrastcolor = GraphColors("gaxis")
        color         = GraphColors("gaxis");

 end; /* CLOSES THE DEFINE STYLE STATEMENT */
run ;

proc template ;
 define style Arial10  ; /* CREATE A NEW ODS STYLE CALLED Arial10 */
    parent = Arial9 ; /* BASE THE TEMPLATE ON ARIAL9 */
    replace fonts /
        'TitleFont2'   = ("Arial", 8pt,italic)
        'TitleFont'    = ("Arial", 10pt)
        'StrongFont'   = ("Arial", 9pt,Bold)
        'EmphasisFont' = ("Arial",10pt,Bold Italic)

        'FixedEmphasisFont'= ("Courier",7pt,Bold)
        'FixedStrongFont'  = ("Courier",7pt,Bold)
        'FixedHeadingFont' = ("Courier",7pt,Bold)
        'BatchFixedFont'   = ("Courier",7pt)
        'FixedFont'        = ("Courier",7pt,Italic)

        'headingEmphasisFont' = ("Arial",10pt,Bold)
        'TextFont'            = ("Arial",10pt,italic)
        'headingFont'         = ("Arial",10pt,Bold)
        'docFont'             = ("Arial",10pt) ; /* DEFAULT FONT SELECTION */
 end; /* CLOSES THE DEFINE STYLE STATEMENT */
run ;

proc template ;
 define style Arial8  ; /* CREATE A NEW ODS STYLE CALLED Arial8 */
    parent = Arial9 ; /* BASE THE TEMPLATE ON Arial9 */
    replace fonts /
        'TitleFont2'   = ("Arial", 8pt,italic)
        'TitleFont'    = ("Arial", 9pt,bold)
        'StrongFont'   = ("Arial",8pt,Bold)
        'EmphasisFont' = ("Arial",8pt,Bold)

        'FixedEmphasisFont'= ("Courier",7pt,Bold)
        'FixedStrongFont'  = ("Courier",7pt,Bold)
        'FixedHeadingFont' = ("Courier",7pt,Bold)
        'BatchFixedFont'   = ("Courier",7pt)
        'FixedFont'        = ("Courier",7pt,Italic)

        'headingEmphasisFont' = ("Arial",8pt,Bold)
        'TextFont'            = ("Arial",8pt,italic)
        'headingFont'         = ("Arial",8pt,Bold)
        'docFont'             = ("Arial",8pt) ; /* DEFAULT FONT SELECTION */
 end; /* CLOSES THE DEFINE STYLE STATEMENT */
run ;
