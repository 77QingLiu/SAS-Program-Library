*m203e04;

%macro clublist(level);
   proc print data=orion.club_members;
      where Club_Code=:"&level";
      var Customer_ID First_Name Last_Name Customer_Type;
      title "List of Club_Code=&level";
   run;
   title;
%mend clublist;

%clublist(GD) /* Gold Members     */
%clublist(IN) /* Internet Members */
%clublist(OR) /* Orion Members    */
%clublist(XX) /* Invalid value    */
%clublist()   /* Null value       */
