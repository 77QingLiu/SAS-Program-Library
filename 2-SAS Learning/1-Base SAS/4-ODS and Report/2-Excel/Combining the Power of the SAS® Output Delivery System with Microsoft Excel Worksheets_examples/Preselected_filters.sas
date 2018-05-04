



proc template;                                                                
   define tagset Tagsets.ExcelXP_mod;
     parent=tagsets.excelxp; 
                                                                              
      define event write_autofilter;                                          
                                                                              
         do /if $autofilter;                                                  
                                                                              
            trigger reset_autofilter /breakif $worksheet_has_autofilter;    
            trigger reset_autofilter /breakif ^$autofilter_row;               
                                                                              
            trigger reset_autofilter /breakif ^$last_autofilter_row;          
            set $worksheet_has_autofilter "True";                             
            putq "<AutoFilter";                                               
            put " x:Range=""";                                                
                                                                              
            do /if $last_autofilter_col;                                      
               eval $last $last_autofilter_col;                               
                                                                              
            else;                                                             
               eval $last 1;                                                  
            done;                                                             
                                                                              
            do /if cmp( $autofilter, "all");                                  
               put "R" $autofilter_row "C1:R" $last_autofilter_row "C" $last; 
                                                                              
            else /if index($autofilter, "-");                                 
               eval $tmp_col inputn(scan($autofilter,1,"-") , "BEST" );       
               set $tmp_col $last /if $tmp_col > $last;                       
               put "R" $autofilter_row "C" $tmp_col;                          
               eval $tmp_col inputn(scan($autofilter,2,"-") , "BEST" );       
               set $tmp_col $last /if $tmp_col > $last;                       
               put ":R" $last_autofilter_row "C" $tmp_col;                    
                                                                              
            else;                                                             
               eval $tmp_col inputn($autofilter,"BEST");                      
                                                                              
               do /if missing($tmp_col);                                      
                  put "R" $autofilter_row "C1:R" $last_autofilter_row "C" $   
                        last;                                                  
               else;                                                          
                  set $tmp_col $last /if $tmp_col > $last;                    
                  put "R" $autofilter_row "C" $tmp_col;                       
                  put ":R" $last_autofilter_row "C" $tmp_col;                 
               done;                                                          
                                                                              
            done;                                                             
                                                                              
            put """ xmlns=""urn:schemas-microsoft-com:office:excel"">";       
            set $autofilter_values $options["AUTOFILTER_VALUES" ];            
                                                                              
            do /if index($autofilter_values, ",");                            
               set $autofilter_values_list scan($autofilter_values,1,",");    
               putlog "this is the second test" $autofilter_values_list;      
               eval $auto_count 1;                                            
                                                                              
               do /while ^cmp( $autofilter_values_list, " ");                 
                  set $auto_value[] strip($autofilter_values_list);           
                  eval $auto_count $auto_count +1;                            
                  set $autofilter_values_list scan($autofilter_values,$       
                        auto_count,",");                                      
               done;                                                        
                                                                              
            else;                                                             
                          
               set $auto_value[] strip($autofilter_values);                   
            done;                                                             
                                                                              
            iterate $auto_value;                                              
                                                                              
            do /while _value_;                                                
               eval $Count +1;                                                
               set $column_filter scan(_value_,1,"|");                        
               set $column_filter substr($column_filter,2);                   
               putq "<AutoFilterColumn x:Index=" $column_filter;              
               put " x:Type=""Custom"">" NL;                                  
               putq " <AutoFilterCondition x:Operator=""Equals"" x:Value="    
                     scan(_value_,2,"|");                                     
               put "/>" NL;                                                   
               put "</AutoFilterColumn>" NL;                                  
               putlog _value_;                                                
               next $auto_value;                                              
            done;                                                             
                                                                              
         done;                                                                
                                                                              
      done;                                                                   
                                                                              
      putq "</AutoFilter>";                                                   
   done;                                                                      
                                                                              
   unset $autofilter_row;                                                     
   unset $last_autofilter_row; 
   unset  $autofilter_values;
   unset $auto_value;
  end;                                           
end;                                                                          
run;                         

/*****************************************************************************/  
/* Create filter conditions by adding the the column and the value to filter */
/* Multiple filters are added by separating with a comma.                    */
/*****************************************************************************/

 
Ods tagsets.ExcelXP_Mod file="c:\tempa.xls" options(autofilter_values="c2|M,C3|14" autofilter="yes");

Proc print data=sashelp.class noobs;
title "Using CSS for styles";
Run;

ods tagsets.test options(autofilter_values="c2|F,C3|11" autofilter="yes");


Proc print data=sashelp.class noobs;
title "Using CSS for styles";
Run;


Ods tagsets.ExcelXP_Mod close;

