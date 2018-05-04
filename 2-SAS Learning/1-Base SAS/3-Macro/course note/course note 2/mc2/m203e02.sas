*m203e02;

%macro prodlist(prodline);
   %let prodline=%upcase(&prodline);
   proc print data=orion.prodlist;
      where upcase(Product_Line) ="&prodline";
      var product_ID Product_Name ;
      title "Listing of %sysfunc(propcase(&prodline, %str( &)))";
   run;
   title;
%mend prodlist;

%prodlist(clothes&shoes)
