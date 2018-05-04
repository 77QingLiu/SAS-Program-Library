/**soh******************************************************************************************************************
Eli Lilly and Company (required)- GSS
CODE NAME (required)              : chn_ut_readrtf.sas
PROJECT NAME (required)           : component_modules
DESCRIPTION (required)            : read big N in rtf - China Internal Use
SPECIFICATIONS(required)          : Validation Process in Handbook - China Internal Use
VALIDATION TYPE (required)        : Peer Review
INDEPENDENT REPLICATION (required): 
ORIGINAL CODE (required)          : N/A, this is the original code
COMPONENT CODE MODULES            : 
SOFTWARE/VERSION# (required)      : SAS/version 9.2
INFRASTRUCTURE                    : 
DATA INPUT                        : 
OUTPUT                            : 
SPECIAL INSTRUCTIONS              : the refference is http://www2.sas.com/proceedings/sugi31/066-31.pdf
                                    This macro is called by chn_ut_readN to read big N in rtf

-------------------------------------------------------------------------------------------------------------------------------  
-------------------------------------------------------------------------------------------------------------------------------
DOCUMENTATION AND REVISION HISTORY SECTION (required):
   Author &
Ver# Validator        Code History Description
---- ---------------- -----------------------------------------------------------------------------------------------------
1.0   Jiashu Li        Original version of the code
    
  
**eoh*******************************************************************************************************************/



*options mprint mlogic symbolgen;

		%macro fwords06(string=,root=,delim=,vnwords=nwords);
		  %global &vnwords;
		  %local count word spac;
		  %let count=1;
		  %if "&delim" ne ""
		      %then %let spac=%str(&delim);
		      %else %let spac=%str( );;
		  %let word=%qscan(&string,&count,&spac);
		  %do %while (&word ne);
		      %global &root&count;
		      %let &root&count=&word;
		      %let count=%eval(&count+1);
		      %let word=%qscan(&string,&count,&spac);
		  %end;
		  %let &vnwords=%eval(&count-1);
		%mend fwords06;

		%macro fbrowse01(indir=,
		                 type=,
		                 select=all,
		                 outds=,
		                 cleanup=yes);

		  %if %substr(&indir,%length(&indir),1)=\ %then
		    %let indir=%substr(&indir,1,%length(&indir)-1);
		  %let select=%upcase(&select);
		  %let select=%sysfunc(tranwrd(&select,.%upcase(&type),));
		  %if "&select"="ALL" or "&select"="" %then %let select=*;
		  %if &type= %then %let type=*;

		  data &outds;
		    length filename $96 folder $260;
		    set _null_;
		    call missing(filename,folder); /*to avoid uninitia lized message*/
		  run;

		  %local i;
		  %fwords06(string=&select, root=fbrowse);
		  %do i=1 %to &nwords;
		    %let fbrowse&i=&&fbrowse&i...&type;
		    %if %index(&&fbrowse&i,*)>0 or %index(&&fbrowse&i,?)>0 %then %do;
		      filename fin pipe "dir /b &indir\&&fbrowse&i";
		      data fbrowse01;
		        infile fin truncover;
		        input filename $96.;
		        folder="&indir";
		      run;
		      data &outds;
		        set &outds fbrowse01;
		      run;
		    %end;
		    %else %if %sysfunc(fileexist(&indir\&&fbrowse&i))=0 %then
		      %put WARNING: "&indir\&&fbrowse&i" is not fou nd.;
		    %else %do;
		      data fbrowse02;
		        filename="&&fbrowse&i";
		        folder="&indir";
		      run;
		      data &outds;
		        set &outds fbrowse02;
		      run;
		    %end;
		  %end;

		%mend fbrowse01;



%macro readrtf(indir=, rtf=, indata=, if=, outds=, cleanup=YES);

%let indent_c1=n; * option to mimic the rtf format;

%if &indata =  %then %do;

	  %if %superq(rtf) eq %then %let rtf=%str(*.rtf);;
	  %if %substr(&indir, %length(&indir))^=\ %then %let indir=&indir\;


	  %local MAX_PATH;
	  %let MAX_PATH=$260.;
	  filename dir pipe "dir &indir.&rtf /B";

	  %fbrowse01(indir=&indir, type=RTF, select=&rtf, outds=readrtf_0);

proc sql noprint;
	select filename into: file
	from READRTF_0;
	quit;
%put &file;

data readrtf_a1(where=(tableseq<=20));
/*		set readrtf_0;*/
	    length fileloc $260;
	    fileloc="&indir\" || "&file";
		tableseq=_n_;
		table=tranwrd(upcase("&file"),'.RTF','');
		rownum=0;
		infile dummy filevar=fileloc end=done missover length = l  lrecl = 2000	;
			input string $varying2000. l	;
			filename=scan("&rtf",1,'.');
			string=tranwrd(string, '{\field{\*\fldinst SYMBOL 179 \\f "Symbol" }}', '>=');
			string=tranwrd(string, '{\super a} ' , '');
/*			string=compress(string);*/
					if index(string,'\par')>0;
run;
data readrtf_a;
	set readrtf_a1;
		tableseq=_n_;
		retain c1-c99 dropme indent;
		
        length c1-c2 $200 c3-c99 $50 prep0 $200;
			array c{99} $;
			if index(string, '\par') then do;
				count = 0;
				indent = 0;
				do i=1 to dim(c);
					c{i} = '';
				end;
			end;
			if (  (index(string, '(N') or  index(string, '( N')) and index(string, ')') and index(string, '='))  or
             ( index(upcase(string), 'ITT') and index(upcase(string), 'POPULATION') ) or 
              ( index(upcase(string), 'PROTOCOL') and index(upcase(string), 'POPULATION') ) or
              (index(upcase(string), 'ALL') and index(upcase(string), 'PATIENTS')) or
               (index(upcase(string), 'SAFETY ANALYSIS') ) or
               (index(upcase(string), 'FULL ANALYSIS SET') ) 
			   %if %length(&population) gt 0 %then or (index(upcase(string), upcase("&population")) );
               then do;
				count + 1;
				prep0 = strip(tranwrd(string, '\par \pard\plain \s34\sl-179\slmult0\nowidctlpar',''));
				length =length('\par \pard\plain \s34\sl-179\slmult0\nowidctlpar'||''||scan(prep0, 1,''))+1;
				prep = substr(string,length);
				prep1 = compress(prep, byte(13));
				prep1 = tranwrd(prep1, ' = ','=');
				if PREP1^='' then do;	
               if  index(string, '(N')  then do;
                do j=1 to 99;	
				prep2=substr(prep1, index(prep1, '(N') -3);
				prep2=compress(prep2, '*OvrabcPp-vlue[]');
					c{j} = scan(prep2,j, ' ');
				end;
               end;	
               else if  index(string, '( N')  then do;
                do j=1 to 99;	
				prep2=substr(prep1, index(prep1, '( N') -3);
				prep2=compress(prep2, '*OvrabcPp-vlue[]');
					c{j} = scan(prep2,j, ' ');
				end;
               end;
			   else do;			   
                do j=1 to 2;	
					c{j} = scan(prep1,j, '');
				end;
			   end;
			  end;
            end;
			if tableseq=1 then dropme = 1;
			if index(compress(lowcase(string)), '--') then do;dropme+1;end;
				do i=1 to dim(c);
					if compress(c{i}, '(N') ne '' then allblank = 0;
				end;					
			
/*			if dropme>2 and count=0  then allblank=1;*/
			
	run;

	proc sql noprint;
	select dropme into: max
	from readrtf_a
	having dropme=max(dropme);
	quit;
    %put &max;

	proc sort data=readrtf_a(where=(dropme<&max and allblank=0));
	by tableseq rownum;
	run;
	proc transpose data=readrtf_a(drop=count) out=chk;
	var c:;
	by tableseq rownum;
	run;

	%global dropper numvars;
	proc sql noprint;
		select distinct _name_ into: dropper separated by ' '
		from chk where _name_ not in (select _name_ from chk where col1 ne '');
		select distinct count(distinct _name_) into: numvars
		from chk where col1 ne '';
	quit;


	proc sort data=readrtf_a(drop=count &dropper) out=readrtf_b;
	by tableseq indent rownum;
	run;
	data readrtf_c;*(index=(tablseq rownum));
		set readrtf_b;
		by tableseq indent rownum;
		if first.tableseq then level=0;
		if first.indent then level + 1;
	run;

	data readrtf(drop=i num1 pct1 allblank);
		set readrtf_c;
		array c (&numvars) c:;
		array num(&numvars) ;
		array pct(&numvars) ;
		do i=2 to dim(c);
		if c(i) not in ('' '-') and verify(compress(c(i)), '-0123456789.%><')=0 then num(i) = input(c(i), ??best.);
		else if c(i) not in ('' '-') and verify(compress(c(i)), '-0123456789.()%><')=0 then do;
			num(i) = input(scan( c(i) , 1, '('), ??best.);
			pct(i) = input(scan(compress(c(i), ')'), 2, '('), ??best.);
		end;
		end;
	run;
	proc sort data=readrtf;
	by tableseq rownum ;
	run;

	data &outds(keep = filename segment--rownum c: num: pct: table:);
		length segment level subitem rownum 8.;
		retain segment 0 subitem;
		set readrtf;
		by tableseq rownum;
		if level = 1 then segment + 1;
		if level ne lag(level) then subitem = 0;
		subitem + 1;
		if first.tableseq then rownum=0;
		rownum + 1;
		if compress(lowcase("&indent_c1")) = 'y' then do;
		if level = 2 then c1 = ' ' ||c1;
		else if level > 2 then c1 = repeat(' ', level-2)||c1;
		end;
		

	run;

%end;
%else %if &indata ne %then %do;


	data &outds(keep = filename segment--rownum c: num: pct: table:);
		length segment level subitem rownum 8.;
		retain segment 0 subitem;
		set &indata;
		by tableseq rownum;
		if level = 1 then segment + 1;
		if level ne lag(level) then subitem = 0;
		subitem + 1;
		if first.tableseq then rownum=0;
		rownum + 1;
		if compress(lowcase("&indent_c1")) = 'y' then do;
		if level = 2 then c1 = ' ' ||c1;
		else if level > 2 then c1 = repeat(' ', level-2)||c1;
		end;
		

	run;

%end;

	%if %upcase(&cleanup)=YES %then %do;

	  proc datasets memtype=data nolist;
	  delete readrtf_:;
	  quit;

	%end;

%mend readrtf;

