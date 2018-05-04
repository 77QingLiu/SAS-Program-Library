%inc "\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\Macro learning tool\program\init.sas";
%let dirname=D:\lillyce\qa\ly2835219\i3y_je_jpbc\intrm2\data\shared\adam;
%let dsn=adae;
libname inlib "&dirname";
%AHGcodeCompletion(inlib.&dsn);
