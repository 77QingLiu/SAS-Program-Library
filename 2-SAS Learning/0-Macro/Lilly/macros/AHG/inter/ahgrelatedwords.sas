	/* -------------------------------------------------------------------
	                          CDARS System Module
	   -------------------------------------------------------------------
	   $Source: $
	   $Revision: 1.1 $
	   $Author: Hui Liu $
	   $Locker:  $
	   $State: Exp $

	   $Purpose: Generate related strings from single word

	   $Assumptions:



	   -------------------------------------------------------------------
	                          Modification History
	   -------------------------------------------------------------------
	   $Log:$


	   -------------------------------------------------------------------
	*/
	
    %macro AHGrelatedwords(var,outmac);
        %local word1 word2;
        proc sql noprint;
            select distinct word2 into :word2 separated by ' '
            from allstd.wordtowords
            where upcase(word1)=upcase("&var")
            ;
            select distinct word1 into :word1 separated by ' '
            from allstd.wordtowords
            where upcase(word2)=upcase("&var")
            ;
        quit;
        %put outmac=&word1 &word2 &var;
        %let &outmac=%AHGnodup(&word1 &word2 &var);
    %mend;

