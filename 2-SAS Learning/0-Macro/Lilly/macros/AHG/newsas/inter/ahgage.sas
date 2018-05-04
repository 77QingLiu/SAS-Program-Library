%macro AHGage(dob=,now=,agevar=age);
     &agevar=substr(put(&now,yymmdd10.),1,4)-substr(put(&dob,yymmdd10.),1,4)
    -(substr(put(&now,yymmdd10.),5) <substr(put(&dob,yymmdd10.),5));
%mend;
