%macro AHGsetallvarnil(except=);
	do;							
	array ahuigeallchar _character_;
	array ahuigeallnum _numeric_	;	
	do over  ahuigeallchar ;
	if not %AHGequaltext(vname(ahuigeallchar),&except) then ahuigeallchar='';
	end;
	do over  ahuigeallnum ;
	if not %AHGequaltext(vname(ahuigeallchar),&except) then ahuigeallnum=.;
	end;
	end;

%mend;
