%macro sudoku;
option mprint;

data _null_;

	 call symput('ahuigefromtime',put(time(),time8.));

run;
%local inc bk stkn;

  %let inc=000;

  %let bk=000;

  %let stkn=000;

libname cache  "d:\temp" memlib;

  proc datasets lib=cache kill;

  run;



/* Turn on full caching */

options memcache = 4;


%let columns=6,3,5,7,8,9,4,2,1;

%let rows=2,3,4,7,8,9,5,6,1;

                                %macro printMtrx(dsn);/*print matrix*/

                                  data _null_;
                                    set &dsn;
                                    array num(1:9,1:9) n11-n19 n21-n29 n31-n39 n41-n49 n51-n59 n61-n69 n71-n79 n81-n89 n91-n99;
                                    do i=1 to 9;
                                      do j=1 to 9;
                                        put num(i,j)@@;
                                      end;
                                      put;
                                    end; 
                                  run;

                                %mend;

                                  %macro backup(stkn);/* create datasets backup and bk*** from dataset ori */
                                  /*  %let bk=%incr(&bk);*/
                                    data cache.backup(keep=n11-n19 n21-n29 n31-n39 n41-n49 n51-n59 n61-n69 n71-n79 n81-n89 n91-n99) 
                                         cache.bk&stkn;
                                      set cache.ori;
                                    run;
                                  %mend;




                                          
                                        %macro tryAgain ;/*rollback to the latest stage and choose another number */
                                          %let inc=%incr(&inc);
                                          data cache.stack cache.stack&inc; /*stack(n)-snapshot*/
                                            set cache.stack end=eof;
                                            put _all_;
                                            if eof then
                                              do;
                                              call symput('i',outi);
                                              call symput('j',outj);
                                              call symput('value',substr(outvalue,1,1));
                                              call symput('id',left(stkn));
                                              if length(compress(outvalue))=1 then delete;
                                              outvalue=substr(outvalue,2);
                                              end;
                                          run;
                                          %let id=%addz(&id);

                                          data cache.ori;
                                            set cache.bk&id;
                                            array num(1:9,1:9) n11-n19 n21-n29 n31-n39 n41-n49 n51-n59 n61-n69 n71-n79 n81-n89 n91-n99;
                                            num(&i,&j)=&value;
                                          run;

                                        %mend;







                                              %macro goThrough;

                                              data cache.ori (keep=n11-n19 n21-n29 n31-n39 n41-n49 n51-n59 n61-n69 n71-n79 n81-n89 n91-n99) 
                                                  cache.single(keep=outj outi outvalue) ; /*check relevant elements to see whether this element can be decided*/
                                                set cache.ori;
                                                array num(1:9,1:9) n11-n19 n21-n29 n31-n39 n41-n49 n51-n59 n61-n69 n71-n79 n81-n89 n91-n99;
                                                call symput('wrongway','0');
                                                wrongway=0;
                                                call symput('progressed','0');
                                                progressed=0;
                                                call symput('over','1');
                                                over=1;
                                                do until(progressed=0 or enough=300);
                                              /*    put 'asdfjlsdfhkjsdhfkjdshafkjsahfdkjsah';*/
                                                  enough+1;
                                                  progressed=0;
                                                  lth=9;
                                                  do i=&rows;
                                                    if wrongway then leave;
                                                    do j=&columns;
                                                      if not missing(num(i,j)) then continue;
                                                      if normal(0)<0 then  string='123456789';
                                              		    else   string='987654321';
                                                      /*narrow options from column info*/
                                                      do ii=1 to 9;
                                                      string=compress(string,put(num(ii,j),1.));
                                                      end;
                                                      /*narrow options from raw info*/
                                                      do jj=1 to 9;
                                                      string=compress(string,put(num(i,jj),1.));
                                                      end;
                                                      iii=(ceil(i/3)-1)*3+1;
                                                      jjj=(ceil(j/3)-1)*3+1;
                                                      *put i= j= iii= jjj=;
                                                      /*narrow options from squre info*/
                                                      do k=iii to iii+2;
                                                        do l=jjj to jjj+2;
                                                          string=compress(string,put(num(k,l),1.));
                                                        end;
                                                      end;
                                                      lg=length(compress(string));
                                              /*        put i= j= string= lg=;*/
                                                      if string='' then do;wrongway=1;call symput('wrongway','1');leave;end;

                                                      if lg<lth then
                                                        do;
                                                        outi=i; outj=j; outvalue=string;lth=lg;
                                                        end;
                                                      if lg=1 then
                                                        do;
                                                        num(i,j)=input(string,best8.);
                                                        progressed=1;
                                                        call symput('progressed',1);
                                                        end;
                                                    end;
                                                  end;
                                                end;
                                                do i=1 to 9;
                                                    if not over then leave;
                                                    do j=1 to 9;
                                                    if missing(num(i,j)) then 
                                                      do;
                                                      over=0;
                                                      leave;
                                                      end;
                                                    end;
                                                end;
                                                if not wrongway then output cache.ori;
                                                if not over then call symput('over','0');
                                                if not over and not wrongway and not progressed then  output cache.single ;
                                              run;

                                              %mend;




                                                  %macro append(stkn);/* Add one record in the stack*/
                                                    data cache.single;
                                                      set cache.single;
                                                      stkn=&stkn;
                                                    run;

                                                    proc datasets;
                                                      append base=cache.stack
                                                      data=cache.single;
                                                    run;
                                                  %mend;




                                                  %macro addz(n);/*PUT n with format z3.*/
                                                    %if %length(&n)=1 %then %let n=00&n;
                                                    %if %length(&n)=2 %then %let n=0&n;
                                                    &n
                                                  %mend;







                                                  %macro incr(n); /*n++ with format z3.*/
                                                    %let n=%eval(&n+1);
                                                    %addz(&n)
                                                  %mend;







                                                          %macro main;

                                                            %backup;

                                                            %gth:

                                                            %goThrough;
                                                            %put over=&over progressed=&progressed wrongway=&wrongway;
                                                            %if &over %then 
                                                              %goto exit;
                                                            %else 
                                                              %do;
                                                              %if &wrongway %then 
                                                                %do;
                                                                %put ##############  wrongway  #############;
                                                                %printMtrx(ori);
                                                                %tryAgain;
                                                                %goto gth ;
                                                                %end;
                                                              %else;
                                                                %do;
                                                                %if &progressed %then
                                                                  %goto gth ;
                                                                %else;
                                                                  %do;
                                                                  %put not progressed;
                                                                  %let stkn=%incr(&stkn);
                                                                  %append(&stkn);
                                                                  %backup(&stkn);
                                                                  %put #######   Now  ########;
                                                                  %printMtrx(ori);
                                                                  %tryagain;
                                                                  %goto gth ;
                                                                  %end;
                                                                %end;
                                                              %end;
                                                            %exit:
                                                          %mend;


                                                %macro big;
                                                  %main;

                                                  %printMtrx(cache.ori);

                                                data _null_;

                                                	 diff=time()-input("&ahuigefromtime",time8.);

                                                	 put '################ time used :' diff time8.;

                                                run;
                                                %mend;

DATA cache.ori;
  set sudoku;
run;
%big;
%mend;



%macro generator;
*modify source;

  data sudoku;

    array num  (1:9,1:9) n11-n19 n21-n29 n31-n39 n41-n49 n51-n59 n61-n69 n71-n79 n81-n89 n91-n99;

    do i=1 to 9;

      do j=1 to 9;

        input num(i,j) @@;

      end;

    end;

    drop i j;
    cards;

3 5 . . . . 9 . . 
9 . 7 . . . 6 3 1 
. . . . . . . . 4 
. . . 2 7 . . . . 
. . . 1 6 8 . . . 
. . . . . 5 . . . 
. 6 . . . . 5 . 8 
5 . . . . . 7 . 3 
8 . . . . . 2 1 6


    ;

    run;


%mend;
