*m203s04;

%macro clublist(level)/minoperator;
   %if %superq(level)= %then %do;
      %put ERROR: A null value for LEVEL is not valid.;
      %put ERROR- Valid values are OR, IN, or GD.;
      %put ERROR- The macro will terminate now.;
      %return;
   %end;
   %else %if %superq(level) in %str(IN OR GD) %then %do;
      proc print data=orion.club_members;
         where Club_Code=:"&level";
         var Customer_ID First_Name Last_Name Customer_Type;
         title "List of Club_Code=&level";
      run;
      title;
   %end;
   %else %do;
      %put ERROR: Value of LEVEL: &level is not valid.;
      %put ERROR- Valid values are OR, IN, or GD.;
      %put ERROR- The macro will terminate now.;
   %end;
%mend clublist;

%clublist(GD) /* Gold Members     */
%clublist(IN) /* Internet Members */
%clublist(OR) /* Orion Members    */
%clublist(XX) /* Invalid value    */
%clublist()   /* Null value       */
