*m203d05;

%let name=Taylor, Jenna;

%let initial=%substr(&name,1,1);				*failure;
%let initial=%substr(%str(&name),1,1);		*failure;
%let initial=%substr(%superq(name),1,1);	*success;

%put &=initial;
