%macro AHGdateandtime(outmac,format=datetime20.);

data _null_;
    call symput("&outmac",trim(left(compress(put(datetime(),&format),':')    )));
run; 

%mend;

