%macro AHGlocalmac(mac,value);
    %local &mac;
    %let &mac=&value;
%mend;
