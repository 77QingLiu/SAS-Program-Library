%macro AHGcreatefile(
dir=%AHGtempdir,
filename=,
fullname=,
str=%str());
    %if %AHGblank(&fullname) and not %sysfunc(fileexist(&dir/tmp&filename..tmp))  %then  x "echo ""&str"" >&dir/tmp&filename..tmp";
    %else %if not %AHGblank(&fullname) and not %sysfunc(fileexist(&fullname))  %then x "echo ""&str"" >&fullname"
    ;
%mend;

