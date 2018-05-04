%macro AHGrefreshfolder(folders,exts=sas sasdrvr sas7bdat );
    %local i macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname); 
    
    %do i=1 %to %AHGcount(&folders);

    %AHGfuncloop(%nrbquote(  AHGrdown(save=0,rlevel=3,folder=%scan(&folders,&i),filename=*.ahuige )   ),
    loopvar=ahuige,loops= &exts
    );    %end;
%mend;
