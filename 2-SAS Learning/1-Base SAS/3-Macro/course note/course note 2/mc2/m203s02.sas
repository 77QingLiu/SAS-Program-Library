*m203s02;

%macro prodlist(prodline);
   %let prodline=%qupcase(&prodline);
   proc print data=orion.prodlist;
      where upcase(Product_Line) ="&prodline";
      var product_ID Product_Name ;
      title "Listing of %qsysfunc(propcase(&prodline, %str( &)))";
   run;
   title
%mend prodlist;

%prodlist(%nrstr(clothes&shoes))
