%macro AHGsubmitRcommand(cmd=);
    %syslput batchqcCommand=%nrbquote(&cmd);
    %put %bquote(&cmd);
    rsubmit;
    x "ksh -c %str(%')%bquote(. ~liu04/bin/myalias; PATH=/home/liu04/bin:/opt/sasprod:/usr/sbin:/etc:/usr/local/bin:/usr/bin:/bin:/usr/dt/bin:/usr/openwin/bin:/usr/ucb:.:/home/liu04/bin/perl;FPATH=/home/liu04/bin;)&batchqcCommand%str(%') ";;
    endrsubmit;
%mend;
