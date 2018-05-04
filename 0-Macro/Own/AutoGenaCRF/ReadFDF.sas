/*--------------------------------------------------------------------------------------------------*
* Macro to read FDF file and store comments related information in SAS dataset
*--------------------------------------------------------------------------------------------------*/
%macro ReadFDF(file=, out=);
filename fdf "&file";
*------------------- Read raw FDF file --------------------;
/* Step 1: Read raw file byte by byte */
data fdf_1; 
    infile fdf recfm=n;
    input text_byte ib1. @@;
    length text_raw $5000;
    retain text_raw;
    if text_byte = 32 then text_byte=94; /* Replace spcae with other characters(^) to prevent being removed by CATX function */
    if text_byte not in (13,10) and text_byte>0 then text_raw=cats(text_raw,byte(text_byte)); /* 13('0D'X) is FDF file record separater */
    if text_byte = 13 then do;
        text_raw  = prxchange('s/\^/ /o',-1,text_raw); /* Replace previous special characters(^) with blank space */
        output;
        call missing(text_raw);
    end;
run;

/* Step 2: Concatenate same logical record into one line*/
data fdf_2(drop=text_raw text_temp start_obj);
    set fdf_1(drop=text_byte);
    if text_raw not in ('%','%FDF-1.2') and _n_ > 5;
    length text_logical text_temp $20000 start_obj $50;
    retain text_logical text_temp start_obj;
    if not prxmatch('#^\d+ 0 obj$|^<</W .*>>$|^endobj$#',strip(text_raw)) then text_temp=cats(text_temp,text_raw);
    if prxmatch('#^\d+ 0 obj$#io',strip(text_raw)) then start_obj=text_raw;
    if text_raw = 'endobj' and ^missing(text_temp) then do;
        text_logical = start_obj;
        output;
        text_logical = prxchange('s#\\$##o',1,strip(text_temp));
        output;
        text_logical = 'endobj';
        output;
        call missing(of text_temp);
    end;
run;

/* Step 3: Derive comments related information from logical text */
%let comment    = %str(s#.*/Contents\((.*?)\)/.*#$1#io); /* Comments */
%let Background = %str(s#.*/C\[(.*?)\]/.*#$1#io); /* Background color */
%let style      = %str(s#.*/DS\((.*?)\)/.*#$1#io); /* Font, align, color */
%let page       = %str(s#.*\/Page (.*?)\/.*#$1#io); /* PDF page */
%let coordinate = %str(s#.*\/Rect\[(.*?)\]\/.*#$1#io); /* Position of the rectangular box*/

data &out;
    set fdf_2;
    length source comment Background style page coordinate $1000;
    source    = "&studyID";
    if prxmatch("#.*/Contents\((.*?)\)/.*#io",text_logical)     then comment    = strip(prxchange('s/\\r//o',-1,prxchange("&comment",-1,text_logical)));
    if prxmatch("#.*/C\[(.*?)\]/.*#io",text_logical)            then Background = strip(prxchange("&Background",-1,text_logical));
    if prxmatch("#.*/DS\((.*?)\)/.*#io",text_logical)           then style      = strip(prxchange("&style",-1,text_logical));
    if prxmatch("#.*\/Page (.*?)\/.*#io",text_logical)          then page       = strip(prxchange("&page",-1,text_logical));
    if prxmatch("#.*\/Rect\[(.*?)\]\/.*#io",text_logical)       then coordinate = strip(prxchange("&coordinate",-1,text_logical));
    if prxmatch('#^\d+ 0 obj$|^endobj$#',strip(text_logical))   then call missing(of comment Background style page coordinate);
    x1 = input(scan(coordinate,1,' '),best.);
    y1 = input(scan(coordinate,2,' '),best.);
    x2 = input(scan(coordinate,3,' '),best.);
    y2 = input(scan(coordinate,4,' '),best.);
    if ^missing(comment);

    array test(*) _Char_;
    do i = 1 to dim(test);
      test(i) = compbl(compress(test(i),,'kw'));
    end;    
    comment = prxchange('s/\\\(/(/o',-1,comment);
    comment = prxchange('s/\\\)/)/o',-1,comment);


    keep source comment Background style page coordinate x1 x2 y1 y2;
run;

%mend ReadFDF;
