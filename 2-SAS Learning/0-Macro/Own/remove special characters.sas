options cmplib = ( work.funcs ) ;
proc fcmp outlib = work.funcs.utilities ;
  function compress_npsc( var $ ) $32767 ;
    length npschars $256 ; 
    do i = 0 to 31, 127 to 255 ; 
      npschars = cats( npschars, byte( i ) ) ; 
    end ; 
    return( compress( var, npschars ) ) ; 
  endsub ; 
run ;





data temp2;
retain pre ;
    zcstresc = 'Diagnosis Form – Additional Information';

if _n_=1 then do; pre=prxparse("s/[\x7F-\xFF|\x00-\x19]/ /");end;
match=prxmatch(pre,zcstresc);
change= prxchange(pre,-1,zcstresc);
put change=;
run;