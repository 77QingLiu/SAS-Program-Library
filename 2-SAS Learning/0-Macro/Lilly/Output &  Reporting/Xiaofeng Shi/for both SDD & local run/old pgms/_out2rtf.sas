/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : _out2rtf.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : Japan I4V-JE-JADN
DESCRIPTION               : convert from data of text format to rtf file
SOFTWARE/VERSION#         : SAS/Version 9.2
INFRASTRUCTURE            : SDD version 3.4
LIMITED-USE MODULES       : N/A
BROAD-USE MODULES         : N/A
INPUT                     : Text format
OUTPUT                    : RTF file
PROGRAM PURPOSE           : Out to RTF
VALIDATION LEVEL          : 3
REQUIREMENTS              : N/A
ASSUMPTIONS               : N/A
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: 
	1.count page, line number;

	2.add following information into title line.
	  all property is added as right alignment.

	  1st line : Page XXX of YYY(format $15.)
	    XXX : current page number(format 3.)
	    YYY : total page number(format 3.)

	  2nd line : (format hh:mm ddMMMyyyy)

	  3rd line : Data Environment, Execution Environment(format $4.)
	    PDPM : Production Data Production Mode
	    PDTM : Production Data Test Mode
	    TDTM : Test Data Test Mode

	3.search specified special caracter.
	  add escape character before specified special caracter. 
	  (reason : some special characters(\ { }) are used as control character in rtf code.
	            when convert to rtf, need to add escape character before these characters.)

	4.convert from text into rtf.

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: N/A

PARAMETERS: 
Name           Type     Default    Description and Valid Values
-------------- -------- ---------- ---------------------------------------------
in                      required tmpfile    reference to text information
out                     required rtfout     reference to rtf output

_o2r_PrpPgYN   required Y          output page number : Y(Yes) / N or Other value(No)
_o2r_PrpPgFMT  required %quote(Page XXX of YYY)
                                   page format.
                                   if _o2r_PrpPgYN = N, is not required.
                                   see LIMITED-USE MODULE SPECIFIC INFORMATION.

_o2r_PrpDtYN   required Y          output executed date and time : Y(Yes) / N or Other value(No)
_o2r_PrpDt     required %quote(&systime. &sysdate9.)
                                   executed date and time.
                                   if _o2r_PrpDtYN = N, is not required.

_o2r_PrpMdYN   required Y          output data mode and execution mode : Y(Yes) / N or Other value(No)
_o2r_PrpMd     required %quote(&gPMDM.)
                                   execution-mode and data-mode.
                                   if _o2r_PrpMdYN = N, is not required.
                                   1.specify with using "gPMDM" global macro variable, 
                                   or 2.specify directly value.

_o2r_lstCenter optional null       line numbers of title lines to center.
                                   specyfy list the numbers separated by blank.
                                   (e.g. _o2r_lstcenter = 2 3 4)
_o2r_lstMask   optional null       line numbers of title lines to mask.
                                   specyfy list the numbers separated by blank.
                                   (e.g. _o2r_lstMask = 1 2)

_o2r_Orient    required L          page orientation of the rtf output
                                   : L(Landscape) / P or Other value(Portrait) 
_o2r_Lang      required E          select paper property type
                                   : E(for English) / J(for Japanese)
                                   / O(select if you specify each property)

_o2r_LineSpace optional null       paper property
_o2r_FontId    optional null       if not specified, automatically set default value.
_o2r_FontTbl   optional null       parameters(linespace, fonttable, fontsize) : 
_o2r_FontSize  optional null         default value depends on _o2r_Lang(English or Japanese).
_o2r_paperw    optional null       parameters(paperw - fs) : 
_o2r_paperh    optional null         default value depends on _o2r_Orient(Landscape or Portrait).
_o2r_margl     optional null       
_o2r_margr     optional null       
_o2r_margt     optional null       
_o2r_margb     optional null       
_o2r_gutter    optional null       
_o2r_headery   optional null       
_o2r_footery   optional null       
_o2r_linex     optional null       
_o2r_fs        optional null       

_o2r_RepCtrlCd optional %nrstr('\' '{' '}') 
                                   special character to add escape character 
                                   see LIMITED-USE MODULE SPECIFIC INFORMATION.


* font table;
	default font 
		Courier New(for English Document)
		Font Id         : 2
		Font Definition : {\f2\fbidi \fmodern\fcharset0\fprq1{\*\panose 02070309020205020404}Courier New;}

		MS Gothic(for Japanese Document)
		Font Id         : 31501
		Font Definition : {\fdbmajor\f31501\fbidi \fmodern\fcharset128\fprq1{\*\panose 020b0609070205080204}\'82\'6c\'82\'72 \'83\'53\'83\'56\'83\'62\'83\'4e{\*\falt MS Gothic};}

	* other font definition(Font Id = Font Definition);
	f0     = %str({\f0\fbidi \froman\fcharset0\fprq2{\*\panose 02020603050405020304}Times New Roman;});
	f1     = %str({\f1\fbidi \fswiss\fcharset0\fprq2{\*\panose 020b0604020202020204}Arial;});
	f2     = %str({\f2\fbidi \fmodern\fcharset0\fprq1{\*\panose 02070309020205020404}Courier New;});
	f11    = %str({\f11\fbidi \froman\fcharset128\fprq1{\*\panose 02020609040205080304}\'82\'6c\'82\'72 \'96\'be\'92\'a9{\*\falt MS Mincho};});
	f34    = %str({\f34\fbidi \froman\fcharset1\fprq2{\*\panose 02040503050406030204}Cambria Math;});
	f39    = %str({\f39\fbidi \froman\fcharset128\fprq1{\*\panose 02020609040205080304}@\'82\'6c\'82\'72 \'96\'be\'92\'a9;});
	f40    = %str({\f40\fbidi \froman\fcharset238\fprq2 Times New Roman CE;});
	f41    = %str({\f41\fbidi \froman\fcharset204\fprq2 Times New Roman Cyr;});
	f43    = %str({\f43\fbidi \froman\fcharset161\fprq2 Times New Roman Greek;});
	f44    = %str({\f44\fbidi \froman\fcharset162\fprq2 Times New Roman Tur;});
	f45    = %str({\f45\fbidi \froman\fcharset177\fprq2 Times New Roman (Hebrew);});
	f46    = %str({\f46\fbidi \froman\fcharset178\fprq2 Times New Roman (Arabic);});
	f47    = %str({\f47\fbidi \froman\fcharset186\fprq2 Times New Roman Baltic;});
	f48    = %str({\f48\fbidi \froman\fcharset163\fprq2 Times New Roman (Vietnamese);});
	f50    = %str({\f50\fbidi \fswiss\fcharset238\fprq2 Arial CE;});
	f51    = %str({\f51\fbidi \fswiss\fcharset204\fprq2 Arial Cyr;});
	f53    = %str({\f53\fbidi \fswiss\fcharset161\fprq2 Arial Greek;});
	f54    = %str({\f54\fbidi \fswiss\fcharset162\fprq2 Arial Tur;});
	f55    = %str({\f55\fbidi \fswiss\fcharset177\fprq2 Arial (Hebrew);});
	f56    = %str({\f56\fbidi \fswiss\fcharset178\fprq2 Arial (Arabic);});
	f57    = %str({\f57\fbidi \fswiss\fcharset186\fprq2 Arial Baltic;});
	f58    = %str({\f58\fbidi \fswiss\fcharset163\fprq2 Arial (Vietnamese);});
	f60    = %str({\f60\fbidi \fmodern\fcharset238\fprq1 Courier New CE;});
	f61    = %str({\f61\fbidi \fmodern\fcharset204\fprq1 Courier New Cyr;});
	f63    = %str({\f63\fbidi \fmodern\fcharset161\fprq1 Courier New Greek;});
	f64    = %str({\f64\fbidi \fmodern\fcharset162\fprq1 Courier New Tur;});
	f65    = %str({\f65\fbidi \fmodern\fcharset177\fprq1 Courier New (Hebrew);});
	f66    = %str({\f66\fbidi \fmodern\fcharset178\fprq1 Courier New (Arabic);});
	f67    = %str({\f67\fbidi \fmodern\fcharset186\fprq1 Courier New Baltic;});
	f68    = %str({\f68\fbidi \fmodern\fcharset163\fprq1 Courier New (Vietnamese);});
	f152   = %str({\f152\fbidi \froman\fcharset0\fprq1 MS Mincho Western{\*\falt MS Mincho};});
	f150   = %str({\f150\fbidi \froman\fcharset238\fprq1 MS Mincho CE{\*\falt MS Mincho};});
	f151   = %str({\f151\fbidi \froman\fcharset204\fprq1 MS Mincho Cyr{\*\falt MS Mincho};});
	f153   = %str({\f153\fbidi \froman\fcharset161\fprq1 MS Mincho Greek{\*\falt MS Mincho};});
	f154   = %str({\f154\fbidi \froman\fcharset162\fprq1 MS Mincho Tur{\*\falt MS Mincho};});
	f157   = %str({\f157\fbidi \froman\fcharset186\fprq1 MS Mincho Baltic{\*\falt MS Mincho};});
	f432   = %str({\f432\fbidi \froman\fcharset0\fprq1 @\'82\'6c\'82\'72 \'96\'be\'92\'a9 Western;});
	f430   = %str({\f430\fbidi \froman\fcharset238\fprq1 @\'82\'6c\'82\'72 \'96\'be\'92\'a9 CE;});
	f431   = %str({\f431\fbidi \froman\fcharset204\fprq1 @\'82\'6c\'82\'72 \'96\'be\'92\'a9 Cyr;});
	f433   = %str({\f433\fbidi \froman\fcharset161\fprq1 @\'82\'6c\'82\'72 \'96\'be\'92\'a9 Greek;});
	f434   = %str({\f434\fbidi \froman\fcharset162\fprq1 @\'82\'6c\'82\'72 \'96\'be\'92\'a9 Tur;});
	f437   = %str({\f437\fbidi \froman\fcharset186\fprq1 @\'82\'6c\'82\'72 \'96\'be\'92\'a9 Baltic;});

	* ASCII variation of the "Headings" theme font
	f31500 = %str({\flomajor\f31500\fbidi \froman\fcharset0\fprq2{\*\panose 02020603050405020304}Times New Roman;});
	f31508 = %str({\flomajor\f31508\fbidi \froman\fcharset238\fprq2 Times New Roman CE;});
	f31509 = %str({\flomajor\f31509\fbidi \froman\fcharset204\fprq2 Times New Roman Cyr;});
	f31511 = %str({\flomajor\f31511\fbidi \froman\fcharset161\fprq2 Times New Roman Greek;});
	f31512 = %str({\flomajor\f31512\fbidi \froman\fcharset162\fprq2 Times New Roman Tur;});
	f31513 = %str({\flomajor\f31513\fbidi \froman\fcharset177\fprq2 Times New Roman (Hebrew);});
	f31514 = %str({\flomajor\f31514\fbidi \froman\fcharset178\fprq2 Times New Roman (Arabic);});
	f31515 = %str({\flomajor\f31515\fbidi \froman\fcharset186\fprq2 Times New Roman Baltic;});
	f31516 = %str({\flomajor\f31516\fbidi \froman\fcharset163\fprq2 Times New Roman (Vietnamese);});

	* East Asian variation of the "Headings" theme font
	f31501 = %str({\fdbmajor\f31501\fbidi \fmodern\fcharset128\fprq1{\*\panose 020b0609070205080204}\'82\'6c\'82\'72 \'83\'53\'83\'56\'83\'62\'83\'4e{\*\falt MS Gothic};});
	f31520 = %str({\fdbmajor\f31520\fbidi \fmodern\fcharset0\fprq1 MS Gothic Western{\*\falt MS Gothic};});
	f31518 = %str({\fdbmajor\f31518\fbidi \fmodern\fcharset238\fprq1 MS Gothic CE{\*\falt MS Gothic};});
	f31519 = %str({\fdbmajor\f31519\fbidi \fmodern\fcharset204\fprq1 MS Gothic Cyr{\*\falt MS Gothic};});
	f31521 = %str({\fdbmajor\f31521\fbidi \fmodern\fcharset161\fprq1 MS Gothic Greek{\*\falt MS Gothic};});
	f31522 = %str({\fdbmajor\f31522\fbidi \fmodern\fcharset162\fprq1 MS Gothic Tur{\*\falt MS Gothic};});
	f31525 = %str({\fdbmajor\f31525\fbidi \fmodern\fcharset186\fprq1 MS Gothic Baltic{\*\falt MS Gothic};});

	* default (non East Asian, non-ASCII) variation of "Headings" theme font
	f31502 = %str({\fhimajor\f31502\fbidi \fswiss\fcharset0\fprq2{\*\panose 020b0604020202020204}Arial;});
	f31528 = %str({\fhimajor\f31528\fbidi \fswiss\fcharset238\fprq2 Arial CE;});
	f31529 = %str({\fhimajor\f31529\fbidi \fswiss\fcharset204\fprq2 Arial Cyr;});
	f31531 = %str({\fhimajor\f31531\fbidi \fswiss\fcharset161\fprq2 Arial Greek;});
	f31532 = %str({\fhimajor\f31532\fbidi \fswiss\fcharset162\fprq2 Arial Tur;});
	f31533 = %str({\fhimajor\f31533\fbidi \fswiss\fcharset177\fprq2 Arial (Hebrew);});
	f31534 = %str({\fhimajor\f31534\fbidi \fswiss\fcharset178\fprq2 Arial (Arabic);});
	f31535 = %str({\fhimajor\f31535\fbidi \fswiss\fcharset186\fprq2 Arial Baltic;});
	f31536 = %str({\fhimajor\f31536\fbidi \fswiss\fcharset163\fprq2 Arial (Vietnamese);});

	* complex scripts variation of the "Headings" theme font
	f31503 = %str({\fbimajor\f31503\fbidi \froman\fcharset0\fprq2{\*\panose 02020603050405020304}Times New Roman;});
	f31538 = %str({\fbimajor\f31538\fbidi \froman\fcharset238\fprq2 Times New Roman CE;});
	f31539 = %str({\fbimajor\f31539\fbidi \froman\fcharset204\fprq2 Times New Roman Cyr;});
	f31541 = %str({\fbimajor\f31541\fbidi \froman\fcharset161\fprq2 Times New Roman Greek;});
	f31542 = %str({\fbimajor\f31542\fbidi \froman\fcharset162\fprq2 Times New Roman Tur;});
	f31543 = %str({\fbimajor\f31543\fbidi \froman\fcharset177\fprq2 Times New Roman (Hebrew);});
	f31544 = %str({\fbimajor\f31544\fbidi \froman\fcharset178\fprq2 Times New Roman (Arabic);});
	f31545 = %str({\fbimajor\f31545\fbidi \froman\fcharset186\fprq2 Times New Roman Baltic;});
	f31546 = %str({\fbimajor\f31546\fbidi \froman\fcharset163\fprq2 Times New Roman (Vietnamese);});

	* ASCII variation of the "Body" theme font
	f31504 = %str({\flominor\f31504\fbidi \froman\fcharset0\fprq2{\*\panose 02020603050405020304}Times New Roman;});
	f31548 = %str({\flominor\f31548\fbidi \froman\fcharset238\fprq2 Times New Roman CE;});
	f31549 = %str({\flominor\f31549\fbidi \froman\fcharset204\fprq2 Times New Roman Cyr;});
	f31551 = %str({\flominor\f31551\fbidi \froman\fcharset161\fprq2 Times New Roman Greek;});
	f31552 = %str({\flominor\f31552\fbidi \froman\fcharset162\fprq2 Times New Roman Tur;});
	f31553 = %str({\flominor\f31553\fbidi \froman\fcharset177\fprq2 Times New Roman (Hebrew);});
	f31554 = %str({\flominor\f31554\fbidi \froman\fcharset178\fprq2 Times New Roman (Arabic);});
	f31555 = %str({\flominor\f31555\fbidi \froman\fcharset186\fprq2 Times New Roman Baltic;});
	f31556 = %str({\flominor\f31556\fbidi \froman\fcharset163\fprq2 Times New Roman (Vietnamese);});

	* East Asian variation of the "Body" theme font
	f31505 = %str({\fdbminor\f31505\fbidi \froman\fcharset128\fprq1{\*\panose 02020609040205080304}\'82\'6c\'82\'72 \'96\'be\'92\'a9{\*\falt MS Mincho};});
	f31560 = %str({\fdbminor\f31560\fbidi \froman\fcharset0\fprq1 MS Mincho Western{\*\falt MS Mincho};});
	f31558 = %str({\fdbminor\f31558\fbidi \froman\fcharset238\fprq1 MS Mincho CE{\*\falt MS Mincho};});
	f31559 = %str({\fdbminor\f31559\fbidi \froman\fcharset204\fprq1 MS Mincho Cyr{\*\falt MS Mincho};});
	f31561 = %str({\fdbminor\f31561\fbidi \froman\fcharset161\fprq1 MS Mincho Greek{\*\falt MS Mincho};});
	f31562 = %str({\fdbminor\f31562\fbidi \froman\fcharset162\fprq1 MS Mincho Tur{\*\falt MS Mincho};});
	f31565 = %str({\fdbminor\f31565\fbidi \froman\fcharset186\fprq1 MS Mincho Baltic{\*\falt MS Mincho};});

	* default (non East Asian, non-ASCII) variation of the "Body" theme font
	f31506 = %str({\fhiminor\f31506\fbidi \froman\fcharset0\fprq2{\*\panose 02040604050505020304}Century;});
	f31568 = %str({\fhiminor\f31568\fbidi \froman\fcharset238\fprq2 Century CE;});
	f31569 = %str({\fhiminor\f31569\fbidi \froman\fcharset204\fprq2 Century Cyr;});
	f31571 = %str({\fhiminor\f31571\fbidi \froman\fcharset161\fprq2 Century Greek;});
	f31572 = %str({\fhiminor\f31572\fbidi \froman\fcharset162\fprq2 Century Tur;});
	f31575 = %str({\fhiminor\f31575\fbidi \froman\fcharset186\fprq2 Century Baltic;});

	* complex scripts variation of the "Body" theme font
	f31507 = %str({\fbiminor\f31507\fbidi \froman\fcharset0\fprq2{\*\panose 02020603050405020304}Times New Roman;});
	f31578 = %str({\fbiminor\f31578\fbidi \froman\fcharset238\fprq2 Times New Roman CE;});
	f31579 = %str({\fbiminor\f31579\fbidi \froman\fcharset204\fprq2 Times New Roman Cyr;});
	f31581 = %str({\fbiminor\f31581\fbidi \froman\fcharset161\fprq2 Times New Roman Greek;});
	f31582 = %str({\fbiminor\f31582\fbidi \froman\fcharset162\fprq2 Times New Roman Tur;});
	f31583 = %str({\fbiminor\f31583\fbidi \froman\fcharset177\fprq2 Times New Roman (Hebrew);});
	f31584 = %str({\fbiminor\f31584\fbidi \froman\fcharset178\fprq2 Times New Roman (Arabic);});
	f31585 = %str({\fbiminor\f31585\fbidi \froman\fcharset186\fprq2 Times New Roman Baltic;});
	f31586 = %str({\fbiminor\f31586\fbidi \froman\fcharset163\fprq2 Times New Roman (Vietnamese);});

	rtf code specification;
	* \f<decimal>                  = Font number;
	* \f<lo/db/hi/bi><minor/major> = Font theme;
	* \fbidi                       = Arabic, Hebrew, or other bidirectional font;
	* \froman                      = Roman, proportionally spaced serif fonts;
	* \fswiss                      = Swiss, proportionally spaced sans serif fonts;
	* \fmodern                     = Fixed-pitch serif and sans serif fonts;
	* \fcharset                    = Character set(e.g. 0 : ANSI, 128 : Shift JIS);
	* \fprq2                       = The pitch of a font in the font table(Variable pitch);

USAGE NOTES: N/A

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable: optional

	***************************************;
	1.basic usage;
	***************************************;

	* create reference to output file;
	* (rtfout is default argument for _o2r_refOut);
	filename rtfout "&goutloc./&gpgmnm..rtf";

	* get information execution-mode and data-mode from parameter dataset;
	* and set to global macro variable;
	* see setup lum;
	* (global macro variable gPMDM is default argument for _o2r_PrpMd);
	%let gPMDM = PMPD;

	* output;
	* (tmpfile is default argument for _o2r_refIn);
	filename tmpfile temp;

	proc printto new file = tmpfile;
	run;

	<proc report | data _null_>
		...;
	run;

	proc printto;
	run;

	%a_out2rtf;

	filename tmpfile clear;
	filename rtfout clear;

	...;


	***************************************;
	2.if specified value directly;
	***************************************;
	%a_out2rtf(
		_o2r_PrpDt = 2011/04/01, 
		_o2r_PrpMd = PMPD
	);

	***************************************;
	3.if change paper orientation;
	***************************************;
	%a_out2rtf(
		_o2r_Orient   = P
	);	* L(Default : landscape) / P(portrait);


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Xiaofeng Shi        Original version of the code
      Weishan Shi
**eoh************************************************************************/

%macro _out2rtf(
	in     =,
	out    =,

	_o2r_PrpPgYN   = Y, 
	_o2r_PrpPgFMT  = %bquote(Page XXX of YYY), 
	_o2r_PrpPgFMTC = %bquote(XXX), 
	_o2r_PrpPgFMTM = %bquote(YYY), 
	_o2r_PrpPgSPC  = 2, 
	_o2r_PrpDtYN   = Y, 
	_o2r_PrpDt     = %bquote(&systime. &sysdate9.), 
	_o2r_PrpDtSPC  = 2, 
	_o2r_PrpMdYN   = N, 
	_o2r_PrpMd     =, 
	_o2r_PrpMdSPC  = 2, 

	_o2r_lstCenter =, 
	_o2r_lstMask   =, 

	_o2r_Orient    = L, 
	_o2r_Lang      = E, 

	_o2r_LineSpace =, 
	_o2r_FontId    =, 
	_o2r_FontTbl   =, 
	_o2r_FontSize  =, 
	_o2r_paperw    =, 
	_o2r_paperh    =, 
	_o2r_margl     =, 
	_o2r_margr     =, 
	_o2r_margt     =, 
	_o2r_margb     =, 
	_o2r_gutter    =, 
	_o2r_headery   =, 
	_o2r_footery   =, 
	_o2r_linex     =, 
	_o2r_fs        =, 
	_o2r_RepCtrlCd = %quote("\" "{" "}"), 

	_o2r_DebugYN   = N , 
	_o2r_DebugMin  = 1, 
	_o2r_DebugMax  = 100, 

	_o2r_lrecl     = 1000 
	);

	%put  --- now executing macro a_out2rtf ---;

	*******************************************************************************;
	* setting;
	*******************************************************************************;

	***************************************;
	* check input value(set default value);

	* In, Out;
	%if (%quote(&in.    ) = ) %then %let _o2r_refIn     = tmpfile;
	%if (%quote(&out.   ) = ) %then %let _o2r_refOut    = rtfout;

	%if (%sysfunc(fexist(&in.)) = 0) %then %do;
		%put %sysfunc(sysmsg());
		%goto blkerr;

	%end;

	* Eexecution information;
	%if (%quote(&_o2r_PrpPgYN.  ) ^=) %then %let _o2r_PrpPgYN   = %upcase(&_o2r_PrpPgYN.);
	%if (%quote(&_o2r_PrpDtYN.  ) ^=) %then %let _o2r_PrpDtYN   = %upcase(&_o2r_PrpDtYN.);
	%if (%quote(&_o2r_PrpMdYN.  ) ^=) %then %let _o2r_PrpMdYN   = %upcase(&_o2r_PrpMdYN.);

	%if (%quote(&_o2r_PrpPgYN.  ) ^= Y) %then %do;
		%let _o2r_PrpPgYN   = N;
		%let _o2r_PrpPgFMT  =;
		%let _o2r_PrpPgFMTC =;
		%let _o2r_PrpPgFMTM =;
		%let _o2r_PrpPgSPC  =;

	%end;

	%if (%quote(&_o2r_PrpDtYN.  ) ^= Y) %then %do;
		%let _o2r_PrpDtYN   = N;
		%let _o2r_PrpDt     =;
		%let _o2r_PrpDtSPC  =;

	%end;

	%if (%quote(&_o2r_PrpMdYN.  )  = Y) %then %do;
		%if (%quote(&_o2r_PrpMd.    ) = ) %then %do;
			%if %symexist(gPMDM) %then %let _o2r_PrpMd     = %quote(&gPMDM.);

		%end;

	%end; %else %do;
		%let _o2r_PrpMdYN   = N;
		%let _o2r_PrpMd     =;
		%let _o2r_PrpMdSPC  =;

	%end;

	* Page property;
	%let _o2r_Orient    = %upcase(&_o2r_Orient. );
	%if (%quote(&_o2r_Orient.   ) ^= L) %then %do;
		%let _o2r_Orient    = P;

	%end;

	%let _o2r_Lang      = %upcase(&_o2r_Lang.   );

	* set default properties for rtf output file;
	%if (%quote(&_o2r_Lang.) = E) %then %do;	* English;
		%if (%quote(&_o2r_LineSpace.) =) %then %let _o2r_LineSpace = -179;	* Space between lines;
		%if (%quote(&_o2r_FontId.   ) =) %then %let _o2r_FontId    = 2;	* Font Id;
		%if (%quote(&_o2r_FontTbl.  ) =) %then %let _o2r_FontTbl   = {\f2\fbidi \fmodern\fcharset0\fprq1 Courier New%str(;)};
		%if (%quote(&_o2r_FontSize. ) =) %then %let _o2r_FontSize  = 16;	* Font size in half-points;

	%end; %else %if (%quote(&_o2r_Lang.) = J) %then %do;	* Japanese;
		%if (%quote(&_o2r_LineSpace.) =) %then %let _o2r_LineSpace = -179;	* Space between lines;
		%if (%quote(&_o2r_FontId.   ) =) %then %let _o2r_FontId    = 31501;	* Font Id;
		%if (%quote(&_o2r_FontTbl.  ) =) %then %let _o2r_FontTbl   = {\fdbmajor\f31501\fbidi \fmodern\fcharset128\fprq1\%str(%')82\%str(%')6c\%str(%')82\%str(%')72 \%str(%')83\%str(%')53\%str(%')83\%str(%')56\%str(%')83\%str(%')62\%str(%')83\%str(%')4e%str(;)};
		%if (%quote(&_o2r_FontSize. ) =) %then %let _o2r_FontSize  = 16;	* Font size in half-points;

	%end; %else %do;	* Other;
		* if value is not specified, set value for English;
		%if (%quote(&_o2r_LineSpace.) =) %then %let _o2r_LineSpace = -179;	* Space between lines;
		%if (%quote(&_o2r_FontId.   ) =) %then %let _o2r_FontId    = 2;	* Font Id;
		%if (%quote(&_o2r_FontTbl.  ) =) %then %let _o2r_FontTbl   = {\f2\fbidi \fmodern\fcharset0\fprq1 Courier New%str(;)};
		%if (%quote(&_o2r_FontSize. ) =) %then %let _o2r_FontSize  = 16;	* Font size in half-points;

	%end;

	%if (%quote(&_o2r_Orient.) = L) %then %do;	* Landscape;
		%if (%quote(&_o2r_paperw.   ) =) %then %let _o2r_paperw    = 15840;	* Paper size;
		%if (%quote(&_o2r_paperh.   ) =) %then %let _o2r_paperh    = 12240;
		%if (%quote(&_o2r_margl.    ) =) %then %let _o2r_margl     =  1440;	* Margin;
		%if (%quote(&_o2r_margr.    ) =) %then %let _o2r_margr     =  1440;
		%if (%quote(&_o2r_margt.    ) =) %then %let _o2r_margt     =  1440;
		%if (%quote(&_o2r_margb.    ) =) %then %let _o2r_margb     =  1440;
		%if (%quote(&_o2r_gutter.   ) =) %then %let _o2r_gutter    =     0;	* Gutter width;
		%if (%quote(&_o2r_headery.  ) =) %then %let _o2r_headery   =  1080;	* Margin;
		%if (%quote(&_o2r_footery.  ) =) %then %let _o2r_footery   =  1080;
		%if (%quote(&_o2r_linex.    ) =) %then %let _o2r_linex     =     0;	* Distance from the line number to the left text margin;
		%if (%quote(&_o2r_fs.       ) =) %then %let _o2r_fs        =     0;	* (Default) Font size;

	%end; %else %if (%quote(&_o2r_Orient.) = P) %then %do;	* Portrait;
		%if (%quote(&_o2r_paperw.   ) =) %then %let _o2r_paperw    = 12240;	* Paper size;
		%if (%quote(&_o2r_paperh.   ) =) %then %let _o2r_paperh    = 15840;
		%if (%quote(&_o2r_margl.    ) =) %then %let _o2r_margl     =  1440;	* Margin;
		%if (%quote(&_o2r_margr.    ) =) %then %let _o2r_margr     =  1440;
		%if (%quote(&_o2r_margt.    ) =) %then %let _o2r_margt     =  1440;
		%if (%quote(&_o2r_margb.    ) =) %then %let _o2r_margb     =  1440;
		%if (%quote(&_o2r_gutter.   ) =) %then %let _o2r_gutter    =     0;	* Gutter width;
		%if (%quote(&_o2r_headery.  ) =) %then %let _o2r_headery   =  1080;	* Margin;
		%if (%quote(&_o2r_footery.  ) =) %then %let _o2r_footery   =  1080;
		%if (%quote(&_o2r_linex.    ) =) %then %let _o2r_linex     =     0;	* Distance from the line number to the left text margin;
		%if (%quote(&_o2r_fs.       ) =) %then %let _o2r_fs        =     0;	* (Default) Font size;

	%end; %else %do;	* Other;
		* if value is not specified, set value for Landscape;
		%if (%quote(&_o2r_paperw.   ) =) %then %let _o2r_paperw    = 15840;	* Paper size;
		%if (%quote(&_o2r_paperh.   ) =) %then %let _o2r_paperh    = 12240;
		%if (%quote(&_o2r_margl.    ) =) %then %let _o2r_margl     =  1440;	* Margin;
		%if (%quote(&_o2r_margr.    ) =) %then %let _o2r_margr     =  1440;
		%if (%quote(&_o2r_margt.    ) =) %then %let _o2r_margt     =  1440;
		%if (%quote(&_o2r_margb.    ) =) %then %let _o2r_margb     =  1440;
		%if (%quote(&_o2r_gutter.   ) =) %then %let _o2r_gutter    =     0;	* Gutter width;
		%if (%quote(&_o2r_headery.  ) =) %then %let _o2r_headery   =  1080;	* Margin;
		%if (%quote(&_o2r_footery.  ) =) %then %let _o2r_footery   =  1080;
		%if (%quote(&_o2r_linex.    ) =) %then %let _o2r_linex     =     0;	* Distance from the line number to the left text margin;
		%if (%quote(&_o2r_fs.       ) =) %then %let _o2r_fs        =     0;	* (Default) Font size;

	%end;

	* debug flag;
	%if (%quote(&_o2r_DebugYN.  ) ^=) %then %let _o2r_DebugYN   = %upcase(&_o2r_DebugYN.);


	***************************************;
	* other;
	%local _o2r_ls _o2r_pblines;

	* linesize for centering;
	%let _o2r_LsMax = %sysfunc(getoption(ls));
	%put _o2r_LsMax = &_o2r_LsMax.;


	*******************************************************************************;
	* Data Processing;
	*******************************************************************************;

	***************************************;
	* 1.count page, line number;
	* 2.add output status into title line;
	* 3.search specified special caracter.;
	*   add escape character before specified special caracter. ;
	* 4.convert from text into rtf.
	***************************************;

	* tmporary reference;
	filename _o2r_w1 temp;
	filename _o2r_w2 temp;
	filename _o2r_w3 temp;


	***************************************;
	* 1.count page, line number;
	*   dataset _o2r_pbs_w01 will have one observation per page.;
	***************************************;
	data _o2r_pbs_w01;
		infile &in. lrecl = &_o2r_lrecl. recfm = F length = lenRec unbuffered;
		file   _o2r_w1      lrecl = &_o2r_lrecl. recfm = N;

		length numPg numLs 8. bufI $1. cntI 8.;
		retain numPg numLs 1;

		if (_n_ = 1) then output;

		input @1 @;	* refresh length parameter(lenRec);
		do cntI = 1 to lenRec;
			* input data character by character;
			input @cntI bufI $char1. @;
			* if find FF(Form Feed) code, count page number;
			if bufI = '0C'x then do;
				numPg + 1;
				output;

			* other;
			end; else do;
				put bufI $char1. @;

			end;

			* if find LF(Line Feed) code, count line number;
			if bufI = '0A'x then numLs + 1;

		end;

		put;

		keep numPg numLs;

	run;

	***************************************;
	* max page number;
	* list of 1st line numbers;
	%local _o2r_PgMax _o2r_lstPgBreak;
	proc sql noprint;
		select max(numPg) 
		into :_o2r_PgMax 
		from _o2r_pbs_w01 
		;

		select numLs 
		into :_o2r_lstPgBreak separated by ' ' 
		from _o2r_pbs_w01 
		;

		%let _o2r_PgMax      = &_o2r_PgMax.;
		%let _o2r_lstPgBreak = &_o2r_lstPgBreak.;

	quit;


	***************************************;
	* 2.add output status into title line;
	***************************************;
	%if (%quote(&_o2r_DebugYN.  )  = Y) %then %let _o2r_OutDs = _o2r_Property;
	%else %let _o2r_OutDs = _null_;

	***************************************;
	* set properties;
	data &_o2r_OutDs.;
		infile _o2r_w1 lrecl = &_o2r_lrecl.;
		file _o2r_w2 lrecl = &_o2r_lrecl.;

		length 
			bufBefore bufAfter $&_o2r_lrecl.. lenBufBefore lenBufAfter 8. 
		  %if (%quote(&_o2r_PrpPgYN.  )  = Y) %then %do;
			strPrpPg $%length(&_o2r_PrpPgFMT.). 
			lenPrpPg 8. 
		  %end;
		  %if (%quote(&_o2r_PrpDtYN.  )  = Y) %then %do;
			lenPrpDt 8. 
		  %end;
		  %if (%quote(&_o2r_PrpMdYN.  )  = Y) %then %do;
			lenPrpMd 8. 
		  %end;
		  %if (%quote(&_o2r_PrpPgYN.  )  = Y) or (%quote(&_o2r_PrpDtYN.  )  = Y) or (%quote(&_o2r_PrpMdYN.  )  = Y) %then %do;
			lenTtl $20. 
		  %end;
			;
		length cntPg 8.;
		retain cntPg 0;

		* input data line by line;
		input;
		bufBefore = _infile_;
		lenBufBefore = length(bufBefore);

		* check line number;

		* 1st line at each page;
		if (_n_ in (&_o2r_lstPgBreak.)) then do;
			cntPg + 1;
		  * (specify to set page number);
		  %if (%quote(&_o2r_PrpPgYN.  )  = Y) %then %do;
			strPrpPg = tranwrd("&_o2r_PrpPgFMT.", "&_o2r_PrpPgFMTC.", put(cntPg, %length(&_o2r_PrpPgFMTC.).));
			strPrpPg = tranwrd(strPrpPg, "&_o2r_PrpPgFMTM.", put(&_o2r_PgMax., %length(&_o2r_PrpPgFMTM.).));

			lenPrpPg = length(strPrpPg);
			lenTtl   = compress("$char" || put(&_o2r_LsMax. - lenPrpPg - &_o2r_PrpPgSPC., best.) || ".");

			_infile_  = putc(_infile_, lenTtl) || trim(left(strPrpPg));
		  %end;

		* 2nd line at each page;
		end; else if ((_n_ - 1) in (&_o2r_lstPgBreak.)) then do;
		  * (specify to set executed date and time);
		  %if (%quote(&_o2r_PrpDtYN.  )  = Y) %then %do;
			lenPrpDt = length("&_o2r_PrpDt.");
			lenTtl   = compress("$char" || put(&_o2r_LsMax. - lenPrpDt - &_o2r_PrpDtSPC., best.) || ".");

			_infile_ = putc(_infile_, lenTtl) || trim(left("&_o2r_PrpDt."));
		  %end;

		* 3rd line at each page;
		end; else if ((_n_ - 2) in (&_o2r_lstPgBreak.)) then do;
		  * (specify to set data mode and execution mode);
		  %if (%quote(&_o2r_PrpMdYN.  )  = Y) %then %do;
			lenPrpMd = length("&_o2r_PrpMd.");
			lenTtl   = compress("$char" || put(&_o2r_LsMax. - lenPrpMd - &_o2r_PrpMdSPC., best.) || ".");

			_infile_ = putc(_infile_, lenTtl) || trim(left("&_o2r_PrpMd."));
		  %end;

		end;

		* output;
		bufAfter = _infile_;
		lenBufAfter = length(bufAfter);
		put _infile_;

	  %if   (%quote(&_o2r_DebugYN.  )  = Y) 
	    and (%quote(&_o2r_DebugMin.  ) ^= ) and (%quote(&_o2r_DebugMax.  ) ^= ) %then %do;
		if (&_o2r_DebugMin. <= _n_ <=  &_o2r_DebugMax.) then output;
	  %end;

	run;


	***************************************;
	* 3.search specified special caracter.;
	*   add escape character before specified special caracter. ;
	***************************************;
	%local _o2r_OutDs;
	%if (%quote(&_o2r_DebugYN.  )  = Y) %then %let _o2r_OutDs = _o2r_SpecialCharacter;
	%else %let _o2r_OutDs = _null_;

	***************************************;
	* search special character and add escape character;
	%local _o2r_CntRepChr _o2r_RepChr;
	data &_o2r_OutDs.;
		infile _o2r_w2 lrecl = &_o2r_lrecl.;
		file _o2r_w3 lrecl = &_o2r_lrecl.;

		length 
			bufBefore bufAfter $&_o2r_lrecl.. lenBufBefore lenBufAfter 8.;
			;

		* input data line by line;
		input;
		bufBefore = _infile_;
		lenBufBefore = length(bufBefore);

		* (specify to 
			search special character 
			and add escape character before it.);
		%if (%quote(&_o2r_RepCtrlCd.) ^=) %then %do;
			* search character by character;
			* set 1st character in _o2r_RepCtrlCd;
			%let _o2r_CntRepChr = 1;
			%let _o2r_RepChr = %scan(%bquote(&_o2r_RepCtrlCd.), &_o2r_CntRepChr., " ");
			%do %while (%length(%bquote(&_o2r_RepChr.)) ^= 0);
				* add escape character;
				_infile_ = tranwrd(_infile_, "%bquote(&_o2r_RepChr.)", "\%bquote(&_o2r_RepChr.)");

				* set next character in _o2r_RepCtrlCd;
				%let _o2r_CntRepChr = %eval(&_o2r_CntRepChr. + 1);
				%let _o2r_RepChr = %scan(%bquote(&_o2r_RepCtrlCd.), &_o2r_CntRepChr., " ");

			%end;

		%end;

		* output;
		bufAfter = _infile_;
		lenBufAfter = length(bufAfter);
		put _infile_;

	  %if   (%quote(&_o2r_DebugYN.  )  = Y) 
	    and (%quote(&_o2r_DebugMin.  ) ^= ) and (%quote(&_o2r_DebugMax.  ) ^= ) %then %do;
		if (&_o2r_DebugMin. <= _n_ <=  &_o2r_DebugMax.) then output;
	  %end;

	run;


	*******************************************************************************;
	* 4.convert from text into rtf.
	*******************************************************************************;

	***************************************;
	* define rtf code;

	* for file header;
	* default language;
    %let _o2r_RtfCd_FilHead_Lang  = %str(
			"{\rtf1\ansi\ansicpg932\deff4\deflang1033\deflangfe1041" 
		);
	* font table;
    %let _o2r_RtfCd_FilHead_Font  = %str(
			"{\fonttbl " / 
				"{\f4\froman\fcharset0\fprq2 Times New Roman;}" / 
				"{\f5\fswiss\fcharset0\fprq2 Arial;}" / 
				"&_o2r_FontTbl." / 
				"{\f14\fmodern\fcharset255\fprq2 Modern;}" / 
			"}"
		);
	* style sheet table;
    %let _o2r_RtfCd_FilHead_Style = %str(
			"{\stylesheet"  
				"{\sb14\sa144\sl-300\slmult0\nowidctlpar \f4 \snext0 Normal;}" 
				"{\s27\fi-1944\li1944\sb240\sa120\sl259\slmult0\keep\keepn\nowidctlpar " 
					"\b\f5\fs22 \sbasedon43\snext0 Tbl Title Cont;}" 
				"{\s34\sl&_o2r_LineSpace.\slmult0\nowidctlpar " 
					"\b\f&_o2r_FontId.\fs&_o2r_FontSize. \sbasedon41\snext34 md_SAS Tbl Entry;}" 
				"{\s41\sl259\slmult0 \keep\keepn\nowidctlpar " 
					"\f4\fs20 \sbasedon0\snext41 md_Tbl Entry;}" 
				"{\s43\fi-1944\li1944\sb240\sa120\sl259\slmult0\keep\keepn\nowidctlpar " 
					"\b\f5\fs22 \sbasedon0\snext0 Tbl Title;}" 
			"} "
		);
	* paper property;
    %let _o2r_RtfCd_FilHead_Paper = %str(
			"\paperw&_o2r_paperw.\paperh&_o2r_paperh." 
			"\margl&_o2r_margl.\margr&_o2r_margr.\margt&_o2r_margt.\margb&_o2r_margb." 
			"\gutter&_o2r_gutter. " 
			"\widowctrl\ftnbj \sectd" 
			"\headery&_o2r_headery.\footery&_o2r_footery.\linex&_o2r_linex. \fs&_o2r_fs. " 
		);
	* for file footer;
    %let _o2r_RtfCd_FilFoot = %str("}");

		* \rtf1          : RTF Version(1 : Version 1);
		* \ansi          : Character Set(ANSI);
		* \ansicpg932    : Default ANSI code page used to perform the Unicode to ANSI conversion when writing RTF text;
		*                  (932 : Japanese);
		* \deff          : Default Font Id;
		*                  (for English Document,      2 : Courier New);
		*                  (for Japanese Document, 31501 : MS Gothic);
		* \deflang1033   : Default language to be used when the \plain control word is encountered;
		*                  (1033 : English (United States));
		* \deflangfe1041 : Default language ID for East Asian text in Word;
		*                  (1041 : Japanese (Japan));

		* \paperw        : Paper width in twips;
		*                  (for Landscape, 15840 twips);
		*                  (for Portrait   12240 twips);
		* \paperh        : Paper height in twips;
		*                  (for Landscape, 12240 twips);
		*                  (for Portrait   15840 twips);
		* \margl         : Left margin in twips;
		*                  (for Landscape,  1440 twips);
		*                  (for Portrait    1440 twips);
		* \margr         : Right margin in twips;
		*                  (for Landscape,  1440 twips);
		*                  (for Portrait    1440 twips);
		* \margt         : Top margin in twips;
		*                  (for Landscape,  1440 twips);
		*                  (for Portrait    1440 twips);
		* \margb         : Bottom margin in twips;
		*                  (for Landscape,  1440 twips);
		*                  (for Portrait    1440 twips);
		* \gutter        : Gutter width in twips;
		*                  (for Landscape,     0 twips);
		*                  (for Portrait       0 twips);
		* \headery       : Header is N twips from the top of the page;
		*                  (for Landscape,  1080 twips);
		*                  (for Portrait    1080 twips);
		* \footery       : Footer is N twips from the bottom of the page;
		*                  (for Landscape,  1080 twips);
		*                  (for Portrait    1080 twips);
		* \linex         : Distance from the line number to the left text margin in twips;
		*                  (for Landscape,     0 twips);
		*                  (for Portrait       0 twips);
		* \fs            : Font size in half-points;
		*                  (for Landscape,     0 points);
		*                  (for Portrait       0 points);

	* for page break;
    %let _o2r_RtfCd_PgBreak = %str("\par \pard\plain \s34\sl&_o2r_LineSpace.\slmult0\nowidctlpar \b\f&_o2r_FontId.\fs&_o2r_FontSize.\page ");
	* for mask;
    %let _o2r_RtfCd_MaskPre = %str("\fs12{\field\fldlock{\*\fldinst comments ");
    %let _o2r_RtfCd_PbMask  = %str("\par \pard\plain\fs12{\field\fldlock{\*\fldinst comments ");
    %let _o2r_RtfCd_MaskSuf = %str("}{\fldrslt}}\fs0");
	* for body line;
    %let _o2r_RtfCd_NormPre = %str("\par \pard\plain \s34\sl&_o2r_LineSpace.\slmult0\nowidctlpar \b\f&_o2r_FontId.\fs&_o2r_FontSize. ");

		* \field\fldlock : Field is locked and cannot be updated;
		* \*\fldinst     : Field instructions.(Comment Field);

		* \par         : New paragraph;
		* \pard        : Resets to default paragraph properties;
		* \plain       : Resets any previous character formatting;
		* \sl          : Space between lines;
		* \slmult0     : Line spacing multiple("At Least" or "Exactly" line spacing);
		* \nowidctlpar : No widow/orphan control;
		* \page        : Required page break;
		* \b0          : Bold control(Off);
		* \f0          : Font number;
		* \fs          : Font size;


	***************************************;
    * output to rtf file;
	data _null_;
		infile _o2r_w3 lrecl = &_o2r_lrecl. end = flgEnd;
		file &out. lrecl = &_o2r_lrecl.;

		length flgPgBreak flgMask flgCenter cntLn 8.;
		retain flgPgBreak flgMask flgCenter cntLn 0;
			* page break flag, mask flag, center flag, line number;

		length numLeading 8;
			* for centering;

		***************************************;
		* input data line by line;
		input;


		***************************************;
		* _n_ = 1(1st page, 1st line);
		***************************************;
		if _n_ = 1 then do;
			* write rtf file header including margins and fonts.;
	        put &_o2r_RtfCd_FilHead_Lang.;
	        put &_o2r_RtfCd_FilHead_Font.;
	        put &_o2r_RtfCd_FilHead_Style. @;
	        put &_o2r_RtfCd_FilHead_Paper. @;

		end;


		***************************************;
		* 1 <= _n_;
		***************************************;

		***************************************;
		* page break(1st line of each page);
		* count line number;
		if (_n_ in (&_o2r_lstPgBreak.) and (_n_ ^= 1)) then do;
			flgPgBreak = 1;
			cntLn = 1;

		end; else do;
			flgPgBreak = 0;
			cntLn + 1;

		end;

		***************************************;
		* mask;
	  %if (%quote(&_o2r_lstMask.  )  ^=) %then %do;
		if (cntLn in (&_o2r_lstMask.)) then flgMask = 1;
		else flgMask = 0;
	  %end; %else %do;
		flgMask = 0;
	  %end;

		***************************************;
		* center;
	  %if (%quote(&_o2r_lstCenter.  )  ^=) %then %do;
		if (cntLn in (&_o2r_lstCenter.)) then flgCenter = 1;
		else flgCenter = 0;
	  %end; %else %do;
		flgCenter = 0;
	  %end;

		***************************************;
		* output;

		* mask;
		if (flgMask = 1) then do;
			* mask + page break;
			if (flgPgBreak = 1) then put &_o2r_RtfCd_PbMask. @;
			* mask;
			else put &_o2r_RtfCd_MaskPre. @;

			put _infile_ &_o2r_RtfCd_MaskSuf.;

		* centering;
		end; else if (flgCenter = 1) then do;
			numLeading = int((&_o2r_LsMax. - length(_infile_)) / 2);

			* centering + page break;
			if (flgPgBreak = 1) then put &_o2r_RtfCd_PgBreak. @;
			* centering;
			else put &_o2r_RtfCd_NormPre. @;

			put +numLeading _infile_;

		* other;
		end; else do;
			* page break;
			if (flgPgBreak = 1) then put &_o2r_RtfCd_PgBreak. @;
			* normal;
			else put &_o2r_RtfCd_NormPre. @;

			put _infile_;

		end;

		flgPgBreak = 0;
		flgMask = 0;
		flgCenter = 0;

		***************************************;
		* close rtf;
		if flgEnd then put &_o2r_RtfCd_FilFoot.;

	run;

	filename _o2r_w1 clear;
	filename _o2r_w2 clear;
	filename _o2r_w3 clear;

%blkerr:
  * (specify to output datase for dedug.);
  %if (%quote(&_o2r_DebugYN.  )  = Y) %then %do;
	%put _global_;

  %end; %else %do;
	proc datasets lib=work nolist;
		delete _o2r:;

	quit;
  %end;

%mend _out2rtf;
