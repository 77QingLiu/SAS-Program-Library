%macro AHGallstd;
	

	data _null_;
		file "&preadandwrite\allstd.txt";
		set allstd.allstudies;
		where property='LINK';
		put value;
	run;
	data _null_;
		file "&kanbox\allstd.txt";
		set allstd.allstudies;
		where property='LINK';
		put value;
	run;
	data _null_;
		set allstd.allstudies;
		put value;
	run;
%mend;
