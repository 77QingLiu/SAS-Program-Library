%macro AHGfindallmeta(metaIN,into=);
%local  metaOut ordered;
%AHGsortwords(&metaIN,into=metaIN);

%AHGfindmeta(&metaIn,into=metaOut);

%AHGsortwords(&metaOut &metain,into=metaIN);

%AHGfindmeta(&metaIn,into=metaOut);
%AHGsortwords(&metaOut &metain,into=metaIN);

%AHGfindmeta(&metaIn,into=metaOut);
%AHGsortwords(&metaOut &metain,into=metaIN);

%AHGfindmeta(&metaIn,into=metaOut);
%AHGsortwords(&metaOut &metain,into=metaIN);

%AHGfindmeta(&metaIn,into=metaOut);
%AHGsortwords(&metaOut &metain,into=metaIN);

%AHGfindmeta(&metaIn,into=metaOut);

%AHGsortwords(&metaOut &metain,into=&into);

%AHGpm(&into);




%mend;
