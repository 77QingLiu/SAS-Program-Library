%MACRO paging3( data=, rows=, bylist=, byBlock=0, skipvar=, txtlist=, split=,
                  lenlist=, skiplist=, spaclist=, page=page, lastpage=9999,
                  altBreak=, plus=0);

%******************************************************************************;
%*                          PAREXEL INTERNATIONAL LTD                          ;
%*                                                                             ;
%* CLIENT:            PAREXEL                                                  ;
%*                                                                             ;
%* PROJECT:           paging  macro                                            ;
%*                                                                             ;
%* TIMS CODE:         56981                                                    ;
%*                                                                             ;
%* SOPS FOLLOWED:     1213                                                     ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* PROGRAM NAME:      paging3.sas                                              ;
%*                                                                             ;
%* PROGRAM LOCATION:  /opt/pxlcommon/stats/macros/sas/code/paging3/ver002      ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* USER REQUIREMENTS: The macro provides an additional counting variable       ;
%*                    as used for paginating SAS datasets ready for output     ;
%*                    via PROC REPORT                                          ;
%*                                                                             ;
%* TECHNICAL          Depending on a count of data records in a SAS dataset    ;
%* SPECIFICATIONS:    representing the count of rows for an output an          ;
%*                    addtional variable will be increased.                    ;
%*                                                                             ;
%* EXAMPLE:                                                                    ;
%*    %paging3( data=rin1, rows=27, bylist=reihe centno med ptno,              ;
%*             txtlist=cdicdd cdx, lenlist=48,                                 ;
%*             page=dummy, lastpage=&lastpage,                                 ;
%*             altBreak=%STR(first.ptno AND _line>16))                         ;
%*                                                                             ;
%* INPUT:             Macro Parameters:                                        ;
%*                        data    - SAS dataset to be paginated                ;
%*                        rows    - count of rows per page                     ;
%*                        bylist  - list of BY variables                       ;
%*                        byBlock - number identifying a variable of the       ;
%*                                  bylist for which the row counter will      ;
%*                                  hold on the same row in the output         ;
%*                                  (usage if PROC REPORT is used with         ;
%*                                  ACROSS variables)                          ;
%*                                  Default = 0                                ;
%*                        txtlist - list of the text variables to be           ;
%*                                  considered for line breaks increasing      ;
%*                                  the count of rows per page                 ;
%*                        lenlist - list of length of the text variables       ;
%*                        split   - split character for the text variables     ;
%*                                  indicating a line break                    ;
%*                        skiplist- no function (for compatibilty reason)      ;
%*                        spaclist- no function (for compatibilty reason)      ;
%*                        page    - name of the page variable to be created    ;
%*                                  Default = page                             ;
%*                        lastpage- number of the last page in the page        ;
%*                                  variable                                   ;
%*                                  Default = 9999                             ;
%*                        altbreak- alternative if clause to constrain         ;
%*                                  additional pagebreak                       ;
%*                        plus    - no function (for compatibilty reason)      ;
%*                                                                             ;
%* OUTPUT:                                                                     ;
%*                        data    - paginated SAS dataset                      ;
%*                                                                             ;
%* PROGRAMS CALLED:   N/A                                                      ;
%*                                                                             ;
%* ASSUMPTIONS/       the dataset to be passed through the macro is sorted by  ;
%* REFERENCES         the bylist variables                                     ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* MODIFICATION HISTORY                                                        ;
%*-----------------------------------------------------------------------------;
%* VERSION:           1                                                        ;
%* AUTHOR:            Ralf Ludwig (B&P Berlin)                                 ;
%* QC BY:             N/A                                                      ;
%*                                                                             ;
%*  CREATED: 01.09.1998 RL                                                     ;
%*  UPDATE: 02.04.2001 RL                                                      ;
%*   - debugged: if element in txtlist in bylist the byvar was                 ;
%*     cleared to blank                                                        ;
%*   - ACTUAL page number for last page                                        ;
%*  UPDATE: 04.05.2001 RL                                                      ;
%*   - Left(rear) for looking for DLM                                          ;
%*   - Skiplist, Spaclist                                                      ;
%*   - Split                                                                   ;
%*  UPDATE: 12.06.2001 RL                                                      ;
%*   - If condition for string subtraction                                     ;
%*  UPDATE: 28.09.2001 RL                                                      ;
%*   - Default for split changed to BLANK                                      ;
%*  UPDATE: 08.10.2001 RL                                                      ;
%*   - If condition for string subtraction                                     ;
%*  UPDATE: 04.09.2002 RL                                                      ;
%*   - byBlock improved                                                        ;
%*  UPDATE: 11.05.2005 RL                                                      ;
%*   - skiplist disabled, but paramter kept for compatibility reasons          ;
%*   - in case of altbreak used and the if clause is true the page number      ;
%*     will be increased if page GT 1                                          ;
%*-----------------------------------------------------------------------------;
%* VERSION:           2                                                        ;
%*                                                                             ;
%* RISK ASSESSMENT                                                             ;
%* Business:          High   [ ]: System has direct impact on the provision of ;
%*                                business critical services either globally   ;
%*                                or at a regional level.                      ;
%*                    Medium [X]: System has direct impact on the provision of ;
%*                                business critical services at a local level  ;
%*                                only.                                        ;
%*                    Low    [ ]: System used to indirectly support the        ;
%*                                provision of a business critical service or  ;
%*                                operation at a global, regional or local     ;
%*                                level.                                       ;
%*                    None   [ ]: System has no impact on the provision of a   ;
%*                                business critical service or operation.      ;
%*                                                                             ;
%* Regulatory:        High   [ ]: System has a direct impact on GxP data and/  ;
%*                                or directly supports a GxP process.          ;
%*                    Medium [X]: System has an indirect impact on GxP data    ;
%*                                and supports a GxP process.                  ;
%*                    Low    [ ]: System has an indirect impact on GxP data or ;
%*                                supports a GxP process.                      ;
%*                    None   [ ]: System is not involved directly or           ;
%*                                indirectly with GxP data or a GxP process.   ;
%*                                                                             ;
%* REASON FOR CHANGE: 1) Validation of program to standards required by        ;
%*                       WSOP 1213.                                            ;
%*                    2) No changes to code required.                          ;
%*                                                                             ;
%* TESTING            Peer code review and review of test output created by    ;
%* METHODOLOGY:       Q:\Programming Steering Committee\SoftwareValidation\    ;
%*                    Software\SASMacros\Pageno\paging3_Val.sas                ;
%*                                                                             ;
%* DEVELOPER:         Ralf Ludwig (B&P Berlin)          Date : 11/05/2005      ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* CODE REVIEWER:     Frank Schuetz (B&P Berlin)        Date : 18/05/2005      ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* USER:              Frank Schuetz (B&P Berlin)        Date : 18/05/2005      ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%******************************************************************************;



%LOCAL _pageobs _bERROR _index _txt _len;

%LET _pageobs = 1;
%LET _bERROR = 0;
%LET _blockBy= ;

   %*** byBlock, 23.04.2002 RL ***;
   %IF &bylist NE %STR( ) AND &byBlock GT 0 %THEN %DO;
      %LET _blockBy=%SYSFUNC(SCAN( &bylist, &byBlock, %STR( )));
   %END;

   DATA _page;

      SET &data(KEEP = &bylist &txtlist) ;
      %IF &bylist NE %STR( ) %THEN %DO;
             BY &bylist;
      %END;

      RETAIN _line 0 &page 1;

      _lines = 1;

      %LET _index = 1 ;
      %DO %WHILE( %SCAN( &txtlist, &_index ) NE %STR( ) );
         %LET _txt = %UPCASE( %SCAN( &txtlist, &_index ) );
         %LET _len = %UPCASE( %SCAN( &lenlist, &_index ) );
         %LET _index = %EVAL( &_index + 1 );

         __lines = 0;
         DO WHILE( LENGTH( &_txt ) - ( &_txt = " " ) );

            _length = LENGTH( &_txt ) - ( &_txt = " " );

            **** looking for the next dlm ****;
            _row = MIN(_length, &_len);
            _word = SUBSTR( &_txt, 1, _row);
            _rear = INDEX(LEFT(REVERSE(_word)), ' '); %*** blank will be found everytime ***;
            %*** OLD, 08.10.2001 RL*** sStr=REVERSE(_word);
            %IF %STR(&split) NE %STR( ) %THEN %DO;
               _rear = MIN(_rear, INDEX(LEFT(REVERSE(_word)), "&split"));
            %END;
            _dlm = _row - _rear + 1;

            **** read string substracted from inputstring ****;
            %*** OLD, *** IF _dlm = 0 OR _length <= _dlm <= _length + 1 THEN &_txt = " ";
            %*** 12.06.2001 RL ***;
            IF      _length=_row            THEN DO;
               &_txt = " ";                             %* _len is sufficient for the entire string *;
               %***PUT _dlm= _length= _row= _rear= &_txt.=;
            END;
            ELSE IF _dlm>0                  THEN DO;
               &_txt = LEFT(SUBSTR( &_txt, _dlm + 1 )); %* insufficient and _dlm found *;
               %***PUT _dlm= _length= _row= _rear= &_txt.=;
            END;
            ELSE IF _dlm=0 THEN DO;
            %***OLD, 09.10.2001 RL *** ELSE IF _dlm=0 AND _length=_row THEN DO;
               &_txt = LEFT(SUBSTR( &_txt, _row+1 ));   %* insufficient and no _dlm found *;
               %***PUT _dlm= _length= _row= _rear= &_txt.=;
            END;
            ELSE DO;
               PUT "WAR" "NING (paging3):  Unexpected err" "or!";
            END;

            __lines = __lines + 1;

         END;
         _lines = MAX(1, _lines, __lines);

      %END;

      %*** OLD, 23.04.2002 RL *** _line = _line + _lines;

      %*;
      %* Skips;
      %*;
      __lines = 0;
      /*** disabled, 11.05.2005 RL
      %LET _index = 1 ;
      %DO %WHILE( %SCAN( &skiplist, &_index ) NE %STR( ) );
         %LET _skip = %UPCASE( %SCAN( &skiplist, &_index ) );
         %LET _space = %UPCASE( %SCAN( &spaclist, &_index ) );
         %LET _index = %EVAL( &_index + 1 );

         IF first.&_skip THEN __lines=__lines+&_space;

      %END;
      /***/
      _lines = MAX(1, _lines, __lines);

      %*** byBlock, 23.04.2002 RL ***;
      %IF &byBlock GT 0 AND &_blockBy NE %STR( ) %THEN %DO;
         IF first.&_blockBy THEN _line = _line + _lines;
      %END;
      %ELSE %DO;
         _line = _line + _lines;
      %END;

      IF _line > &rows    %IF &altBreak NE %str( ) %THEN %DO;
                               OR (&altBreak%str( ))
                          %END;
                         THEN DO;

                IF _N_>1 THEN &page = &page + 1;
                %*** OLD, 11.05.2005 RL *** &page = &page + 1;
                _line = _lines;
                CALL SYMPUT( '_pageobs', COMPRESS( PUT( _N_, best. )));
       END;
   RUN;

   %IF &_bERROR EQ %STR(0) %THEN %DO;

        DATA _page;
                SET _page(KEEP = &bylist &page);
                %IF %STR(&lastpage) NE %STR(ACTUAL) %THEN %DO;
                  IF _N_ GE &_pageobs THEN &page = &lastpage;
                %END;
                %*** OLD, 02.04.2001 RL *** IF _N_ GE &_pageobs THEN &page = &lastpage;
        RUN;

        DATA &data;
                MERGE _page(DROP=&page) &data _page(KEEP=&page);
                %*** OLD, 02.04.2001 RL *** MERGE &data _page;
        RUN;
   %END;

   PROC DATASETS MT = DATA nolist;
           DELETE _page;
   RUN;
   QUIT;

%MEND paging3;
