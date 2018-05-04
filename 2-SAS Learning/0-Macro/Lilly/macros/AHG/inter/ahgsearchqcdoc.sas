%macro AHGsearchqcdoc(issues,dsn=qclib.allqcdoc,related=0,strict=0,fields=%str(bugid filename reason studyname datetime));
        %local i localissues words;
        %if &strict=1 %then %let boundary=%str( );
        %else %let boundary=;
        
        %if &related=1 %then
            %do;
            %do i=1 %to %AHGcount(&issues);
                %AHGrelatedwords(dose,words);
                %AHGpm(words);
                %let localissues=&localissues &words; 
                
            %end;
            %let issues=%AHGnodup(&localissues);
            %end;
        %AHGpm(issues);
        %do i=1 %to %AHGcount(&issues);
            data searchresult&i ;
            keep &fields wgt change div;
            set &dsn;
            change=(length(reason)+1-length(tranwrd(reason,"&boundary%scan(%upcase(&issues),&i)&boundary",' ')));
            div=length("&boundary%scan(%upcase(&issues),&i)&boundary"); ;
            wgt=change/div;
            where index(' '||upcase(reason)||' ',"&boundary%scan(%upcase(&issues),&i)&boundary") >0;
            run;
        %end;

         data searchresult;
            set 
            %do i=1 %to %AHGcount(&issues);
                searchresult&i 
            %end;
            ;
         run;
         
         /*
         %macro columns(columns);
            %local items;
            %let items
            %do i= 1 %to %AHGcount(&columns);
            %let 
            %end;
         %mend;
         */
         proc sql;

            create table searchresult as
            select distinct * , ceil(sum(wgt)) as RelationshipWgt
            from searchresult
            group by bugid
            order by calculated relationshipWgt  descending 
            ;        
      
         
            create table searchresult as
            select distinct *,'%AHGbug('||TRIM(STUDYNAME) ||','||TRIM(BUGID) ||')' as IssueId
            from searchresult(drop=wgt change div)
            order by relationshipWgt  descending
            ; 
            quit;
         
         proc report data=searchresult  nowd ;
            column Issueid relationshipWgt filename reason datetime;
            define issueid/width=30 ;
            define relationshipWgt/width=2 '';
            define filename/width=10 flow 'Object';
            define reason /width=50 flow 'Issue';
            /*define studyname/width=8 ;*/
            define datetime/width=20 ;
         run;
/*
         proc sql;
            select distinct &fields , count(bugid) as RelationshipWgt
            from searchresult
            group by bugid
            order by calculated relationshipWgt  descending 
            ;
            
*/          
            
 %mend;



