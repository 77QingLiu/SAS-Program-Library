data ahuige;
format one $50.;
%let all=%str(1��ͮ150��2��ޱ108��3�100��4������128��5��ǿ70��6����ݼ86��7������80��8������88��9�77��10�ճ糬120��11ʯ����110��12�뺣��149��13� 130��14 ���꿡 99��15 ���� 108��16 ���� 166��17����186��
18 ���� 116��19 ���� 123��20 ������ 118�� 21 Ҧ�� 96; 22 ������ 99 ;23 ������123��)
;
line="&all";

do i=1 to 200;
one=kscan(line,i,'��;');
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
