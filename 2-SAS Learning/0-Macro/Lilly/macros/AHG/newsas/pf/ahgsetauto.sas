%macro AHGsetauto(mode=allLib /*AllLib onlyMac onlyAna*/);

    %if %upcase(&theuser)=LIUH04 %THEN
        %DO;
        options nodate nonumber nocenter mautosource missing=' ' ;
        filename someauto ("&projectpath\analysis" "&projectpath\extract" "&projectpath\macros");
        option
                   sasautos=( %if &mymac ne %then "&mymac";   sasautos '!sasroot/sasautos'
  "&kanbox\my sas files\macros"  "&kanbox\allover "  "&kanbox\alloverhome" '!sasroot\base\sasmacro' someauto "&preadonly\pds1_0\macros" /*gmac hctools*/ sasautos   )
         ;option          fmtsearch=(work.formats library GCAT.GROFMTS GCAT.INTV6 GCAT.INTV5 GCAT.CSA608) cmdmac;
        option ls=180;
        option nofmterr;
        %END;
    %else
        %do;



        options nodate nonumber nocenter mautosource missing=' ' font=("Courier New" 9)
                   sasautos=(  %if &mymac ne %then "&mymac"; '!sasroot/sasautos' '!sasroot\base\sasmacro' "&projectpath\analysis" "&readonly\pds1_0\macros" "&projectpath\extract"  "&projectpath\macros"  '!sasroot\base\sasmacro'   /*gmac hctools*/ sasautos  /*_my*/ )
                   fmtsearch=(work.formats ) cmdmac;
        /*%b_formats;*/

        option ls=180;
        option nofmterr;


        %end;
%mend;
