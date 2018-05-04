%macro AHGequaltext(text1,text2);
	(upcase(&text1)=upcase(&text2))
%mend;
