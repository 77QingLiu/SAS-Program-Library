*m203d06b;

%macro customers(cust1,cust2,cust3);
   %let list=%bquote("&cust1", "&cust2", "&cust3");
   title "Customers: &list";
   proc print data=orion.customer_dim;
      var customer_ID customer_name customer_gender 
	    customer_age_group;
      where customer_lastname in (&list);
   run;
%mend customers;

%customers(Hill, Lewis, Gibbs)
