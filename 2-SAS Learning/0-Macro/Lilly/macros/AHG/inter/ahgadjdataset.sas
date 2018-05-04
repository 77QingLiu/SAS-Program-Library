/*
Adjust dataset by adjV
*/

%macro AHGadjdataset(
      InDSN, /*Original dataset*/
      outDSN,/*Output dataset*/
      grpV,  /*group variable for adjustment*/
      AdjV,  /*dependent variable for adjustment*/
      );

      proc sql;
        create table OutDsn(drop=ahuige&AdjV) as
        select *,avg(ahuige&AdjV) as &AdjV
        from &InDsn(rename=(&Adjv=ahuige&AdjV))
        group by &grpV
        ;quit;
%mend;

