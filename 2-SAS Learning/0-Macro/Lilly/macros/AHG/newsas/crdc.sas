data ahuige;
format one $50.;
%let all=%str(1ÉòÍ®150£»2ÕÅÞ±108£»3Ñî·«100£»4ÅíÈðÁá128£»5ÇØÇ¿70£»6ÁõÝíÝ¼86£»7»ÆÀöºì80£»8Íõ½¨ÐÀ88£»9Àî¾¸77£»10ÑÕ³ç³¬120£»11Ê¯Ïþ¶«110£»12·ëº£À¼149£»13Àîµ¤ 130£»14 Íõºê¿¡ 99£»15 ÁõÏè 108£»16 Áõçñ 166£»17ËïÔÆ186£»
18 ³ÂÜø 116£»19 ³ÂÐÇ 123£»20 ÐìÖØÆæ 118£» 21 Ò¦½à 96; 22 Íô³¿½à 99 ;23 ÆëÏþµ¤123£»)
;
line="&all";

do i=1 to 200;
one=kscan(line,i,'£»;');
if one>'' then 
do;
format name $10.;
name=compress(prxchange('s/(\d+)(\D*)(\d+)/\2/',-1,one),'');
answer=input(prxchange('s/(\d+)(\D*)(\d+)/\3/',-1,one),best.);


output;
end;
end;

run;

proc sort data=ahuige;
by answer;
run;

proc printto print='d:\guess.txt' new;
proc print noobs;
var name answer;
run;

proc printto;run;
x "start d:\guess.txt";
