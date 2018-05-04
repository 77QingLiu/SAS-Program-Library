%macro AHGcmdNo(num);
    x "echo &num >&localtemp\cmdNo.txt";
%mend;
