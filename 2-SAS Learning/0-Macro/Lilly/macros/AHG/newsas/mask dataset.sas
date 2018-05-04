/*%AHGvarlist(ladam.adsl,Into=adsl,dlm=%str( ),print=1);*/

%let original=1234567890;
%let mask=4130972865;
/*/QWERTYUIOP;*/
%let maskstr=%str(subjid=translate(subjid,"&mask","&original"));

data sasuser.adsl;
  keep  subjid age ageu sex race enrlfl trt01pn fasfl arm  bmi  height heightu  subrace   weight weightu;
  set ladam.adsl;
  &maskstr;
  arm=tranwrd(arm,'LY2940680','Drug');
run;




%AHGvarlist(ladam.adae,Into=adae,dlm=%str( ),print=1);


data sasuser.adae;
  keep  subjid aebdsycd	aebodsys aectcsoc	aegrpid
 aedecod aesoc	aesoccd	aespid	aestdtc	aestdy	aeterm	aetox	aetoxcd	aetoxgr	anl01fl
astdt	astdtf	astdy	cycstdy	cycendy	trtemfl	visit	visitnum aedecod
;
  set ladam.adae;
  &maskstr;

run;

%AHGopendsn(sasuser.adsl);
%AHGopendsn(sasuser.adae);
/**/
/*  studyid siteid usubjid subjid age ageu sex race enrlfl fasfl arm trtp trtpn trta trtan trtsdt trtsdtm aeseq aeacn aeacnoth aebdsycd aebodsys aecat aecdver aecontrt aectcsoc aedecod aedur aeendtc aeendy aeenrf aegrpid aehlgt aehlgtcd aehlt aehltcd*/
/*aellt aelltcd aeloc aemodify aendt aendy aeout aepatt aepresp aeptcd aerefid aerel aerelnst aerpver aerstprc aescat aescong aesdisab aesdth aeser aesev aeshosp aeslife aesmie aesoc aesoccd aespid aestdtc aestdy aeterm aetox aetoxcd aetoxgr anl01fl anl02fl*/
/*anl03fl anl04fl anl05fl anl06fl anl07fl anl08fl anl09fl anl10fl anl11fl anl12fl anl13fl astdt astdtf astdy cycstdy cycendy trtemfl visit visitnum*/




