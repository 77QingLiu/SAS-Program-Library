%MACRO hilomax(in=, out=, trt=, hi=, lo=, srmax=, pt=, cond=1);

   %******************************************************************************;
   %*                          PAREXEL INTERNATIONAL LTD                          ;
   %*                                                                             ;
   %* CLIENT:            PAREXEL                                                  ;
   %*                                                                             ;
   %* PROJECT:           A macro to calculate summary counts and percentages      ;
   %*                                                                             ;
   %*                                                                             ;
   %* TIMS CODE:         68372                                                    ;
   %*                                                                             ;
   %* SOPS FOLLOWED:     1213                                                     ;
   %*                                                                             ;
   %******************************************************************************;
   %*                                                                             ;
   %* PROGRAM NAME:      HILOMAX.SAS                                              ;
   %*                                                                             ;
   %* PROGRAM LOCATION:  /opt/pxlcommon/stats/macros/sas/code/hilomax/ver002      ;
   %*                                                                             ;
   %******************************************************************************;
   %*                                                                             ;
   %* USER REQUIREMENTS: A macro to calculate summary counts and percentages      ;
   %*                    within treatment groups for a dataset with higher and    ;
   %*                    lower level terms (e.g. AEs or concomitant medication)-  ;
   %*                    with additionally, a variable to be maximised over       ;
   %*                    multiple occurrences of an event (e.g. severity or study ;
   %*                    drug relationship).                                      ;
   %*                                                                             ;
   %* TECHNICAL          Notes:                                                   ;
   %* SPECIFICATIONS:    (1) also returns _LEVEL                                  ;
   %*                        0 = summary over all higher and lower level terms    ;
   %*                        1 = summary over lower level terms                   ;
   %*                        2 = within higher and lower level combination        ;
   %*                                                                             ;
   %*                    (2) creates combined treatment group                     ;
   %*                        - this is labelled 99 if TRT is numeric, and         ;
   %*                        labelled 'Total' if TRT is character                 ;
   %*                                                                             ;
   %*                    (3) deletes all work files prefixed with underscore (_)  ;
   %*                                                                             ;
   %* INPUT:             Macro paramters:                                         ;
   %*                    IN=input dataset. Must include at least one record for   ;
   %*                       each patient in the population under consideration-   ;
   %*                       this is necessary for accurate denominators           ;
   %*                    OUT=output dataset                                       ;
   %*                    TRT=variable representing treatment groups               ;
   %*                    HI=high level term                                       ;
   %*                    LO=low level term                                        ;
   %*                    SRMAX=variable indicating severity/study drug            ;
   %*                          relationship to be maximised over multiple         ;
   %*                          occurences of event                                ;
   %*                    PT=unique patient identifier                             ;
   %*                    COND=condition for selection of records for summary      ;
   %*                                                                             ;
   %* OUTPUT:            Counts within classes are returned in the variables:     ;
   %*                    n1, n2, ..., nN, nt(total) where tn refers to the        ;
   %*                                               combined treatment group      ;
   %*                                                                             ;
   %*                    Percentages are returned in the variables:               ;
   %*                    p1, p2, ..., pN, pt                                      ;
   %*                                                                             ;
   %*                    The decode of the treatment group is contained in:       ;
   %*                    trt1, trt2, ..., trtN, trtt                              ;
   %*                                                                             ;
   %*                    The treatment group totals (denominators) are            ;
   %*                    contained in:                                            ;
   %*                    dnm1, dnm2, ..., dnmN, dnmt                              ;
   %*                                                                             ;
   %* PROGRAMS CALLED:   N/A                                                      ;
   %*                                                                             ;
   %* ASSUMPTIONS/       None                                                     ;
   %* REFERENCES:                                                                 ;
   %*                                                                             ;
   %******************************************************************************;
   %*                                                                             ;
   %* MODIFICATION HISTORY                                                        ;
   %*-----------------------------------------------------------------------------;
   %* VERSION:           1                                                        ;
   %* AUTHOR:            Stuart Bellamy (Uxbridge) Sept 2003                      ;
   %* QC BY:             N/A                                                      ;
   %*-----------------------------------------------------------------------------;
   %* VERSION:           2                                                        ;
   %*                                                                             ;
   %* RISK ASSESSMENT                                                             ;
   %* Business:          High   [X]: System has direct impact on the provision of ;
   %*                                business critical services either globally   ;
   %*                                or at a regional level.                      ;
   %*                    Medium [ ]: System has direct impact on the provision of ;
   %*                                business critical services at a local level  ;
   %*                                only.                                        ;
   %*                    Low    [ ]: System used to indirectly support the        ;
   %*                                provision of a business critical service or  ;
   %*                                operation at a global, regional or local     ;
   %*                                level.                                       ;
   %*                    None   [ ]: System has no impact on the provision of a   ;
   %*                                business critical service or operation.      ;
   %*                                                                             ;
   %* Regulatory:        High   [X]: System has a direct impact on GxP data and/  ;
   %*                                or directly supports a GxP process.          ;
   %*                    Medium [ ]: System has an indirect impact on GxP data    ;
   %*                                and supports a GxP process.                  ;
   %*                    Low    [ ]: System has an indirect impact on GxP data or ;
   %*                                supports a GxP process.                      ;
   %*                    None   [ ]: System is not involved directly or           ;
   %*                                indirectly with GxP data or a GxP process.   ;
   %*                                                                             ;
   %* REASON FOR CHANGE: 1) Validation of program to standards required by        ;
   %*                       WSOP 1213.                                            ;
   %*                    2) No changes to code required.                          ;
   %*                                                                             ;
   %* TESTING            Peer code review and review of the test output from      ;
   %* METHODOLOGY:       Q:\Programming Steering Committee\SoftwareValidation\    ;
   %*                    Software\SASMacros\HILOMAX\HILOMAX_val.sas               ;
   %*                                                                             ;
   %* DEVELOPER:         Stuart Belamy                     Date :    Sept 2003    ;
   %*                                                                             ;
   %* SIGNATURE:         ................................  Date : ............... ;
   %*                                                                             ;
   %* CODE REVIEWER:     Phil Riley                        Date : 8 March 2005    ;
   %*                                                                             ;
   %* SIGNATURE:         ................................  Date : ............... ;
   %*                                                                             ;
   %* USER:              Phil Riley                        Date : 8 March 2005    ;
   %*                                                                             ;
   %* SIGNATURE:         ................................  Date : ............... ;
   %*                                                                             ;
   %******************************************************************************;
   %* Tested on UNIX platform:-                                                   ;
   %*                                                                             ;
   %* USER:              Dan Higgins                       Date : 14/07/2005      ;
   %*                                                                             ;
   %* SIGNATURE:         ................................  Date : ............... ;
   %*                                                                             ;
   %******************************************************************************;


   *- range of srmax                                                            -*;
   proc summary data=&in. nway missing;
      var &srmax.;
      output out=_srmax(keep=srmin0 srmax0) min=srmin0 max=srmax0;
      where (n(&srmax.));
   run;

   %local srmin0 srmax0;

   data _null_;
      set _srmax;
      do;
         call symput("srmin0", compress(put(srmin0, best8.)));
         call symput("srmax0", compress(put(srmax0, best8.)));
      end;
   run;   

   *- convert treatment groups to consecutive integers                          -*;
   *- for convenience in transposing                                            -*;
   proc summary data=&in. nway missing;
      class &trt.;
      output out=_trtsmm;
   run;

   %local maxitrt;
   data _trtsmm2;
      length _itrt 8;
      retain _itrt 0;
      set _trtsmm(keep=&trt.);
      by &trt.;
      do;
         _itrt+1;
         call symput("maxitrt", compress(put(_itrt, best8.)));
      end;
      keep _itrt &trt.;
   run;

   proc sort data=&in. out=_&in.2;
      by &trt.;
   run;

   *- add _itrt to input dataset                                                -*;
   data _&in.4;
      merge _&in.2(in=in_in) _trtsmm2(in=in_trt);
      by &trt.;
      do;

         if (in_in) then output _&in.4;
         if (not in_trt) then 
         do;
            put 'WA'"RNING check logic " &trt.=;
         end;
      end;
   run;

   %local trtvar;
   %let trtvar = %attrv(ds=_&in.4,var=&trt.,attrib=VARTYPE);

   *- create total treatment group                                              -*;
   data _&in.6;
      length dummy 8;
      retain dummy 1;
      set _&in.4;
      by &trt.;
      do;
         output;

         _itrt = %eval(&maxitrt. + 1);
         %if ("&trtvar." eq "C") %then
         %do;
            &trt. = "Total";
         %end;
         %else %if ("&trtvar." eq "N") %then
         %do;
            &trt. = 99;
         %end;
         %else
         %do;
            put 'WA'"RNING - &trt. not set for combined trt. group "
            &trtvar. = ;
         %end;
         output;

      end;
   run;

   proc sort data=_&in.6(keep=_itrt &trt. dummy) out=_trt nodupkey;
      by _itrt &trt.;
   run;

   proc transpose data=_trt out=_trt2(drop=_name_) prefix=trt;
      var &trt.;
      id  _itrt;
      by dummy;
   run;

   *- sub-population counts for denominator                                    -*; 
   proc summary data=_&in.6 nway missing;
      class _itrt &pt.;
      output out=_dnm;
   run;

   proc summary data=_dnm nway missing;
      class _itrt;
      output out=_dnm2;
   run;

   %local dim;
   %let dim = %eval(&maxitrt.+1);
   %local dnm1  dnm2  dnm3  dnm4  dnm5  dnm6  dnm7  dnm8  dnm9  dnm10
   dnm11 dnm12 dnm13 dnm14 dnm15 dnm16 dnm17 dnm18 dnm19 dnm20
   dnm21 dnm22 dnm23 dnm24 dnm25 dnm26 dnm27 dnm28 dnm29 dnm30;

   data _null_;
      set _dnm2;
      by _itrt;
      do;
         call symput("dnm"||compress(put(_itrt,  best8.)), 
         compress(put(_freq_, best8.))
         );
      end;
   run;

   *-    if severity/relationship is missing, assign max value                  -*;
   *- suppress records with higher level term missing                           -*;
   data _&in.8 _xcond _reject;
      set _&in.6;
      do;
      if (nmiss(&srmax.)) then
      do;
         put 'CH'"ECK - missing severity/relationship assigned max - "
         &trt.= &pt.= &hi.= &lo.=;
         &srmax. = &srmax0.;
      end;


      if (&hi. ne " ") then
      do;
         if (&cond.) then output _&in.8;
         else             output _xcond;
         end;
         else             output _reject;
      end;
   run;

   *- total events count                                                        -*;
   proc summary data=_&in.8 nway missing;
      var &srmax.;
      class _itrt &pt.;
      output out=_tot max=&srmax.;
   run;

   proc summary data=_tot nway missing;
      class &srmax. _itrt;
      output out=_tot2;
   run;

   *- template to force in all treatment groups                                 -*;
   data _tmplt0;
      length _n 8;
      retain _n 0;
      do;
         do &srmax. = &srmin0. to &srmax0.;
            do _itrt = 1 to %eval(&maxitrt.+1);
               output;
            end;
         end;
      end;
   run;

   data _tot4;
      merge _tmplt0(in=in_tmplt) _tot2;
      if (in_tmplt);
      by &srmax. _itrt;
      do;
         if (n(_freq_)) then _n = _freq_;
      end;
      drop _freq_;
   run;

   proc transpose data=_tot4 out=_tot6 prefix=n;
      var _n;
      id _itrt;
      by &srmax.;
   run;

   *- calculate percentages                                                     -*;
   data _tot8;
      length p1-p&dim. 8;
      set _tot6;
      by &srmax.;
      do;
         %do i = 1 %to &dim.;
            p&i. = round(100*n&i./&&dnm&i., 0.1);
         %end;
      end;
   run;

   *- high level events count                                                   -*;
   proc summary data=_&in.8 nway missing;
      var &srmax.;
      class &hi. _itrt &pt.;
      output out=_hi max=&srmax.;
   run;

   proc summary data=_hi nway missing;
      class &hi. &srmax. _itrt;
      output out=_hi2;
   run;

   *- template to force in all treatment groups                                 -*;
   proc sort data=_hi2(keep=&hi.) out=_hi0 nodupkey;
      by &hi.;
   run;

   data _tmplt2;
      length _n 8;
      retain _n 0;
      set _hi0;
      by &hi.;
      do;
         do &srmax. = &srmin0. to &srmax0.;
            do _itrt = 1 to %eval(&maxitrt.+1);
               output;
            end;
         end;
      end;
   run;

   proc sort data=_tmplt2 out=_tmplt4;
      by &hi. &srmax. _itrt;
   run;

   data _hi4;
      merge _tmplt4(in=in_tmplt) _hi2;
      if (in_tmplt);
      by &hi. &srmax. _itrt;
      do;
         if (n(_freq_)) then _n = _freq_;
      end;
      drop _freq_;
   run;


   proc transpose data=_hi4 out=_hi6 prefix=n;
      var _n;
      id _itrt;
      by &hi. &srmax.;
   run;

   *- calculate percentages                                                     -*;
   data _hi8;
      length p1-p&dim. 8;
      set _hi6;
      by &hi. &srmax.;
      do;
         %do i = 1 %to &dim.;
            p&i. = round(100*n&i./&&dnm&i., 0.1);
         %end;
      end;
   run;


   *- high and low level events count                                           -*;
   proc summary data=_&in.8 nway missing;
      var &srmax.;
      class &hi. &lo. _itrt &pt.;
      output out=_hilo max=&srmax.;
   run;

   proc summary data=_hilo nway missing;
      class &hi. &lo. &srmax. _itrt;
      output out=_hilo2;
   run;


   *- template to force in all treatment groups                                 -*;
   proc sort data=_hilo2(keep=&hi. &lo.) out=_HILOMAX nodupkey;
      by &hi. &lo.;
   run;

   data _tmplt6;
      length _n 8;
      retain _n 0;
      set _HILOMAX;
      by &hi. &lo.;
      do;
         do &srmax. = &srmin0. to &srmax0.;
            do _itrt = 1 to %eval(&maxitrt.+1);
               output;
            end;
         end;
      end;
   run;

   proc sort data=_tmplt6 out=_tmplt8;
      by &hi. &lo. &srmax. _itrt;
   run;

   data _hilo4;
      merge _tmplt8(in=in_tmplt) _hilo2;
      if (in_tmplt);
      by &hi. &lo. &srmax. _itrt;
      do;
         if (n(_freq_)) then _n = _freq_;
      end;
      drop _freq_;
   run;


   proc transpose data=_hilo4 out=_hilo6 prefix=n;
      var _n;
      id _itrt;
      by &hi. &lo. &srmax.;
   run;

   *- calculate percentages                                                     -*;
   data _hilo8;
      length p1-p&dim. 8;
      set _hilo6;
      by &hi. &lo. &srmax.;
      do;
         %do i = 1 %to &dim.;
            p&i. = round(100*n&i./&&dnm&i., 0.1);
         %end;
      end;
   run;


   *- assemble counts and percentages                                           -*;
   data _hilo10;
      length dummy 8;
      retain dummy 1;
      length _level 8;
      set _tot8 (in=in_tot)
      _hi8  (in=in_hi)
      _hilo8(in=in_hilo);
      do;
         if (in_tot)  then _level = 0;
         if (in_hi)   then _level = 1;
         if (in_hilo) then _level = 2;
      end;
      drop _name_;
   run;


   data _hilo12;
      merge _hilo10(in=in_hilo) _trt2;
      by dummy;
      drop dummy;
   run;

   data _hilo14;
      length dnm1-dnm&dim. 8;
      array _dnm(&dim.) 8 dnm1-dnm&dim. (
      %do i = 1 %to &dim.;
         &&dnm&i.
      %end;
      );
      length order0 order1 8;
      set _hilo12;
      do;
         if (_level eq 0)      then order0 = 0;
         else                       order0 = 1;
         if (_level in (0, 1)) then order1 = 0;
         else                       order1 = 1;
      end;
      rename n&dim.=nt p&dim.=pt trt&dim.=trtt dnm&dim.=dnmt;
   run;


   proc sort data=_hilo14 out=&out.(drop=order0 order1);
      by order0 &hi. order1 &lo. &srmax.;
   run;

   proc datasets nolist;
      delete _: /memtype=DATA;
   run;

%MEND hilomax;
