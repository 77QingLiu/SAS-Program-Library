%macro AHGaddwords(sentence,words,dlm=%str( ));

	%AHGremoveWords(&sentence,&words,dlm=&dlm)&dlm&words
	
%mend;


