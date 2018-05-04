%macro AHGonebyone(file=&localtemp\sas.txt,length=40);
	data onebyone;
		format one $&length..;
		infile "&file";
		input one @@;
	run;
%mend;
