%macro AHGcopyAndopenbatch;
    data _null_;
        file "&preadandwrite\blank.txt";
        put "";
    run;

	x "copy &preadandwrite\blank.txt &rdownfiles &localtemp\batch.sas";
	x "  &localtemp\batch.sas";
%mend;
