%macro AHGsasautomode(mode/*qc nonqc any*/);
PROC DATASETS lib=work MEMTYPE=catalog;
    delete sasmacr;
run;
%if %AHGwinOrUnix=UNIX %then
%do;
%if &mode=qc %then 
options nodate nonumber nocenter mautosource missing=' '
           sasautos=("&root3/analysis"  "&root2/analysis" "/home/liu04/macros"  
'!sasroot\base\sasmacro'
'!sasroot\core\sasmacro'
'!sasroot\stat\sasmacro'
'!sasroot\sasautos'   ) ;

%if &mode=nonqc %then 
options nodate nonumber nocenter mautosource missing=' '
           sasautos=("&root3/macros"  "&root2/macros" "&root1/macros"  "&root0/macros" "/Volumes/app/cdars/prod/saseng/pds1_0/macros" "/home/liu04/macros"
'!sasroot\base\sasmacro'
'!sasroot\core\sasmacro'
'!sasroot\stat\sasmacro'
'!sasroot\sasautos'   ) ;

%if &mode=any %then 
options nodate nonumber nocenter mautosource missing=' '
           sasautos=("&root3/analysis" "&root3/macros" "&root2/analysis" "&root2/macros" "&root1/macros"  "&root0/macros" "/Volumes/app/cdars/prod/saseng/pds1_0/macros" "/home/liu04/macros"
'!sasroot\base\sasmacro'
'!sasroot\core\sasmacro'
'!sasroot\stat\sasmacro'
'!sasroot\sasautos'   ) ;

;
%end;

%else

%do;
%if &mode=qc %then 
options nodate nonumber nocenter mautosource missing=' '
           sasautos=("&projectpath\analysis"  
'!sasroot\base\sasmacro'
'!sasroot\core\sasmacro'
'!sasroot\stat\sasmacro'
'!sasroot\sasautos'   ) ;

%if &mode=nonqc %then 
options nodate nonumber nocenter mautosource missing=' '
           sasautos=("&projectpath\macros"  
'!sasroot\base\sasmacro'
'!sasroot\core\sasmacro'
'!sasroot\stat\sasmacro'
'!sasroot\sasautos'   ) ;


%if &mode=any %then 
options nodate nonumber nocenter mautosource missing=' '
           sasautos=( "&projectpath\macros"  "&projectpath\analysis"  
'!sasroot\base\sasmacro'
'!sasroot\core\sasmacro'
'!sasroot\stat\sasmacro'
'!sasroot\sasautos'   ) ;


;
%end;
%mend;
