execcmd: method

  inCmd   :char
  retCode :num

           optional=outCmd:char
;
*------------------- Find USUBJID --------------------;
if upcase(incmd)='FINDU' then do;
    if ^missing(outCmd) then do;
            findlist = 'find(usubjid,"'||strip(outCmd)||'")';
            _self_._findRow(findlist);
    end;

   /* let VT know that we processed the command */
   retCode = 1;
end;

*------------------- Find SUBJECT --------------------;
else if upcase(incmd)='FINDS' then do;
    if ^missing(outCmd) then do;
            findlist = 'find(subject,"'||strip(outCmd)||'")';
            _self_._findRow(findlist);
    end;

   /* let VT know that we processed the command */
   retCode = 1;
end;

*------------------- Find SUBJECT --------------------;
/* else if upcase(incmd)='FINDF' then do;
    if ^missing(outCmd) then do;
        matchvar = scan(outCmd,1);
        matchval = scan(outCmd,-1);
        if find(outCmd,'=') then do;
            if _self_._getColumnAttribute(matchvar,'TYPE') ='C' then findlist = strip(matchvar)||'="'||strip(matchval)||'"';
            else findlist = strip(matchvar)||'='||strip(matchval);
        end;
        else do;
            findlist = 'find('||strip(matchvar)||',"'||strip(matchval)||'")';
        end;
        _self_._findRow(findlist);     
    end; */

   /* let VT know that we processed the command */
/*    retCode = 1;
end; */
*------------------- Goto Specific row --------------------;
else if upcase(incmd)='GOTO' then do;

   obs=input(outCmd, 12.);

   if obs > 0 then _self_._gotoAbsoluteRow(obs);

   /* let VT know that we processed the command */
   retCode = 1;
end;
  /* otherwise, if command ne 'GOTO' let VIEWTABLE */
  /* try to process it  */
else call super(_SELF_, '_execCommand', inCmd, retCode, outCmd);

_self_=_self_;
endmethod;