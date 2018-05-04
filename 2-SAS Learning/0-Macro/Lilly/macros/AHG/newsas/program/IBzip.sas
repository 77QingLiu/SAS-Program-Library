
%let zippath=\\mango\sddext.grp\SDDEXT056\TRASH;
%let awepath=\\mango\sddext.grp\SDDEXT056\prd\ly2835219\i3y_mc_jpbm\dmc_blinded3;
%LET tpo=A56;
data all(where=(not missing(SDDTOPATH)) keep=SDDtopath  proj   pref   AWEDescription cmd);
  infile datalines truncover; 
  format line $500. SDDtopath $100. proj $4. pref $13.  AWEDescription $100. alltype $100. cmd $1000. awepath $500.;
  input line 1-300 ;
  SDDtopath=tranwrd(scan(line,1,' '),'\','/');
  SDDtopath=tranwrd(SDDtopath,'program_','programs_');
  proj=scan(line,2,' ');
  pref=scan(line,3,' ');
  do i=4 to 20;
  AWEDescription=trim(AWEDescription)||' '||scan(line,i,' ');
  end;  
  select (SDDtoPath);
     when ('data/shared/custom')  do;awepath='data\custom';alltype='sas sas7bdat xls*';end; 
     when ('data/shared/sdtm') do;awepath='data\sdtm';alltype='sas7bdat';end;
     when ('data/shared/adam') do;awepath='data\adam';alltype='sas7bdat';end;
     when ('programs_nonsdd') do;awepath='programs_stat';alltype='sas';end;
     when ('programs_nonsdd/sdtm') do;awepath='programs_stat\sdtm';alltype='sas';end;
     when ('programs_nonsdd/adam') do;awepath='programs_stat\adam';alltype='sas';end;
     when ('programs_nonsdd/tfl') do;awepath='programs_stat\tfl';alltype='sas';end;
     when ('programs_nonsdd/tfl_output') do;awepath='programs_stat\tfl_output';alltype='rtf gif pdf sas7bdat';end;
     when ('programs_nonsdd/author_component_modules') 
          do; alltype='sas'; 
          awepath='programs_stat\adam\author_component_modules programs_stat\sdtm\author_component_modules programs_stat\tfl\author_component_modules';
          end;
     when ('programs_nonsdd/system_files') 
          do; alltype='log lst'; 
          awepath='programs_stat\adam\system_files programs_stat\sdtm\system_files programs_stat\tfl\system_files';
          end;
     when ('replica_programs_nonsdd/system_files') 
          do; alltype='lst log'; 
          awepath='replica_programs\adam\system_files replica_programs\sdtm\system_files replica_programs\tfl\system_files';
          end;
     when ('replica_programs_nonsdd') 
          do; alltype='sas'; 
          awepath='replica_programs\adam replica_programs\sdtm replica_programs\tfl replica_programs';
          end;
     otherwise;
  END;

  if SDDtoPath=:'dev/' then
      do; alltype='sas7bdat'; 
      awepath='data\eds';
      end;

  cmd='"c:\Program Files\7-Zip\7z.exe" a -tzip '||"&zippath\LBI_P"||proj||"&tpo._.zip " ; 
  do i=1 to 6;
  if not missing(scan(awepath ,i)) then 
    do j=1 to 15;
    if   not missing(scan(alltype,j,' ')) then cmd=trim(cmd)||" &awepath\"||trim(scan(awepath,i,' '))||"\*."||scan(alltype,j,' ');
    end;
  end;
  ;cmd='/* zip to '||TRIM(SDDTOPATH)||"    */  x ' "||trim(cmd)||"';";
cards;
data/shared/custom                            AC56    LBI_PAC56A56_    data/custom
data/shared/sdtm                              AD56    LBI_PAD56A56_    data/sdtm
data/shared/adam                              AAD1    LBI_PAAD1A56_    data/adam
dev/…/data/shared/custom                      AE56    LBI_PAE56A56_    data/eds
program_nonsdd                                PP56    LBI_PPP56A56_    setup.sas
program_nonsdd/author_component_modules       AA56    LBI_PAA56A56_    sdtm/author_component_module, adam/author_component_module, tfl/author_component_module
programs_nonsdd/sdtm                          AP56    LBI_PAP56A56_    sdtm
programs_nonsdd/system_files                  AS56    LBI_PAS56A56_    sdtm/system_file, adam/system_files, tfl/system_files
programs_nonsdd/adam                          AAP1    LBI_PAAP1A56_    adam
programs_nonsdd/tfl                           SP56    LBI_PSP56A56_    tfl
programs_nonsdd/tfl_output                    ATO1    LBI_PATO1A56_    tfl_output
replica_programs_nonsdd                       IP56    LBI_PIP56A56_    sdtm, adam, tfl, irsetup.sas
replica_programs_nonsdd/system_files          IS56    LBI_PIS56A56_    sdtm/system_files, adam/system_files, tfl/system_files
;
run;


data _null_;
  file "&zippath\IB&sysuserid..sas";
  set all;
  put cmd;
  put ' ';
run;

dm "FILEOPEN  ""&zippath\IB&sysuserid..sas""  ";
