forest plot macro;


%macro ForestMacro (
       Data=,           /*--Data Set Name (Required)--*/
       Study=,          /*--Variable name for Study (Required)--*/ 
       OddsRatio=,      /*--Variable name for Odds Ratio (Required)--*/ 
       LCL=,            /*--Variable name for Lower Confidence Limit (Required)--*/ 
       UCL=,            /*--Variable name for Upper Confidence Limit (Required)--*/ 
       Group=,          /*--Variable name for Study Type--*/ 
       Weight=,         /*--Variable name for Study Weight in %--*/
       StatCol1=,       /*--Variable name for Stat Column 1--*/
       StatCol2=,       /*--Variable name for Stat Column 2--*/
       StatCol3=,       /*--Variable name for Stat Column 3--*/
       StatCol4=,       /*--Variable name for Stat Column 4--*/
       DisplayCols=YES, /*--Display the columns for OR, LCL, UCL & Weight--*/
       WtFactor=,       /*--Multiplier factor for Study Weights--*/
                        /*--If not provided WtFactor is computed internally--*/
       Bands=YES,       /*--Draw Horizontal Alternating Bands--*/
       Borders=NO,      /*--Draw Borders--*/
       GraphWalls=NO,   /*--Draw Filled Walls behind the Graph--*/
       StatWalls=NO,    /*--Draw Filled Walls behind the Statistics Tables--*/
       Width=6.4in,     /*--Default width of the graph in pixels--*/
       Height=,         /*--Default height of the graph is computed based on number of observations--*/
       LabelColWidth=0.2,                /*--Fractional width for Label Column--*/
       Label1=Favors Treatment,          /*--Favorable Label--*/
       Label2=Favors Control,            /*--Unfavorable Label--*/
       PlotTitle=Odds Ratio and 95% CL,  /*--Plot Title--*/
       FootNote=,                        /*--Graph Footnote--*/
       Title2=,                          /*--Graph title2--*/
       Title=Impact of Treatment on Mortality by Study  /*--Graph Title--*/ 
);

%local  WeightVar MarkerSize GraphColWidth StatColWidth Border DisplaySecondary GraphWallDisplay StatWallDisplay;
%local  OddsLabel LowerLabel UpperLabel WeightLabel SLabel1 SLabel2 SLabel3 SLabel4;
%local  GraphHeight Ratio RowHeight HeaderHeight Nobs;

/*--Data, Study, OddsRatio, LCL and UCL are required   --*/
/*--Group is optional                                  --*/
/*--Terminatethese required parameters are not supplied--*/
%if %length(&Data) eq 0 %then %do;
%put The parameter 'Data' is required - Forest Macro Terminated.;
%goto finished;
%end;
%else %if %length(&Study) eq 0 %then %do;
%put The parameter 'Study' is required - Forest Macro Terminated.;
%goto finished;
%end;
%else %if %length(&LCL) eq 0 %then %do;
%put The parameter 'LCL' is required - Forest Macro Terminated.;
%goto finished;
%end;
%else %if %length(&UCL) eq 0 %then %do;
%put The parameter 'UCL' is required - Forest Macro Terminated.;
%goto finished;
%end;
%else %if %length(&OddsRatio) eq 0 %then %do;
%put The parameter 'OddsRatio' is required - Forest Macro Terminated.;
%goto finished;
%end;

/*--Initialize GraphHeight, Height per row and Height for other graph items--*/
%let GraphHeight=&Height;
%let RowHeight=22;
%let HeaderHeight=100;
%if %length(&Footnote) ne 0 %then %do;
  %let HeaderHeight=115;
%end;

/*--If the Weight column is not provided, use equal weights, and suppress display of Weight stat--*/
%if &Weight eq %then %do;
  %let WeightVar = _Weight;
  %let MarkerSize = 7;
%end; 
%else %do;
  %let WeightVar=&Weight;
  %let MarkerSize = 0;
%end;

/*--Set up GTL options for borders--*/
%let DisplaySecondary = displaysecondary=none;
%let Borders=%upcase(&Borders);
%if &Borders eq YES or &Borders eq Y %then %do;
  %let Border = line;
  %let DisplaySecondary = displaysecondary=(line);
%end;

/*--Set up GTL options for GraphWall Display--*/
%let GraphWallDisplay = walldisplay=none;
%let GraphWalls=%upcase(&GraphWalls);
%if &GraphWalls eq YES or &GraphWalls eq Y %then %do;
  %let GraphWallDisplay = walldisplay=(fill);
%end; 

/*--Set up GTL options for StatWall Display--*/
%let StatWallDisplay = walldisplay=none;
%let StatWalls=%upcase(&StatWalls);
%if &StatWalls eq YES or &StatWalls eq Y %then %do;
  %let StatWallDisplay = walldisplay=(fill);
%end;

/*--Create Label Columns for standard and additional columns--*/

/*--Load Stat Column Label or name into macro for label column value--*/
%let dsid=%sysfunc(open(&Data));
%if &dsid %then %do;
    
    %let Nobs=%sysfunc(attrn(&dsid, nlobs));
    %if &Nobs eq 0 %then %do;
      %put The Data Set &Data has no observations - Forest Macro Terminated.;
      %let rc=%sysfunc(close(&dsid)); 
      %goto finished;
    %end;

    %if &Nobs gt 100 %then %do;
      %put The Data Set &Data has over 100 observations - Forest Macro Terminated.;
      %let rc=%sysfunc(close(&dsid)); 
      %goto finished;
    %end;

    /*--Count the number of stat columns--*/
    %let idx=0;
    
    /*--Column display information for the OddsRatio column--*/
    %let DisplayCols=%upcase(&DisplayCols);

    %if &DisplayCols eq YES or &DisplayCols eq Y %then %do;
      %let OddsLabel=%sysfunc(varlabel(&dsid, %sysfunc(varnum(&dsid,&OddsRatio))));
      %if %length(&OddsLabel) eq 0 %then %let OddsLabel=&OddsRatio;
      %let idx= %eval(&idx+1);

      %let LowerLabel=%sysfunc(varlabel(&dsid, %sysfunc(varnum(&dsid,&LCL))));
      %if %length(&LowerLabel) eq 0 %then %let LowerLabel=&LCL;
      %let idx= %eval(&idx+1);

      %let UpperLabel=%sysfunc(varlabel(&dsid, %sysfunc(varnum(&dsid,&UCL))));
      %if %length(&UpperLabel) eq 0 %then %let UpperLabel=&UCL;
      %let idx= %eval(&idx+1);

      %if &Weight ne %then %do;
        %let WeightLabel=%sysfunc(varlabel(&dsid, %sysfunc(varnum(&dsid,&Weight))));
        %if %length(&WeightLabel) eq 0 %then %let WeightLabel=&Weight;
        %let idx= %eval(&idx+1);
      %end;
    %end;

    /*--Additional columns to be displayed--*/
    %if %length(&StatCol1) ne 0 %then %do;
      %let SLabel1=%sysfunc(varlabel(&dsid, %sysfunc(varnum(&dsid,&StatCol1))));
      %if %length(&SLabel1) eq 0 %then %let SLabel1=&StatCol1;
      %let idx= %eval(&idx+1);
    %end;

    %if %length(&StatCol2) ne 0 %then %do;
      %let SLabel2=%sysfunc(varlabel(&dsid, %sysfunc(varnum(&dsid,&StatCol2))));
      %if %length(&SLabel2) eq 0 %then %let SLabel2=&StatCol2;
      %let idx= %eval(&idx+1);
    %end;

    %if %length(&StatCol3) ne 0 %then %do;
      %let SLabel3=%sysfunc(varlabel(&dsid, %sysfunc(varnum(&dsid,&StatCol3))));
      %if %length(&SLabel3) eq 0 %then %let SLabel3=&StatCol3;
      %let idx= %eval(&idx+1);
    %end;

    %if %length(&StatCol4) ne 0 %then %do;
      %let SLabel4=%sysfunc(varlabel(&dsid, %sysfunc(varnum(&dsid,&StatCol4))));
      %if %length(&SLabel4) eq 0 %then %let SLabel4=&StatCol4;
      %let idx= %eval(&idx+1);
    %end;

    %let rc=%sysfunc(close(&dsid)); 

    /*--Set column weights based on number of stat columns--*/
    %let StatColWidth=%sysevalf(&idx * 0.075);
    %let GraphColWidth= %sysevalf(1.0 - &LabelColWidth - &StatColWidth);
%end;
%else %do;
    %put The data set &Data does not exist - Forest Macro Terminated.;
    %goto finished;
%end;

/*--Compute Weight Factor if not provided   --*/
/*--Estimate height of graph if not provided--*/
data _null_;
  set &Data end=last;
  retain totalweight 0;
  totalweight+wt;

  if last then do;
    %if &wtFactor eq %then %do;
      if totalweight <= 0 then totalweight=1;
      call symput ('wtFactor', 1 / totalweight);
    %end;
    /*--Estimate Ratio of Plot height by Graph Height--*/
    call symput ('Ratio', (_N_* &RowHeight)/(_N_* &RowHeight + &HeaderHeight));

    /*--Estimate the optimal height of the graph based on obs count--*/
    %if &Height eq %then %do;
      call symput ('GraphHeight', _N_ * &RowHeight + &HeaderHeight);
    %end;
  end;
run;

/*--Append a PX only if this internally estimated--*/
%if &Height eq %then %do;
%let GraphHeight=&GraphHeight.px;
%end;

/*--Process Data--*/
data _forest;
  set &Data;
  format _wt PERCENT6.1;

  _ObsId=_N_;

  %if &Weight eq %then %do;
    &WeightVar=0;
  %end;

  label _wt=&WeightLabel;

  /*--If Group column is provided--*/
  %if %length(&Group) ne 0 %then %do;
    /*--Group=1 (Study) values will be drawn without a group role--*/
    if &group=1 then do;
      _wt=&WeightVar / 100;
      _grp=10;
      _or1 = &OddsRatio;
      _lcl1=&LCL; 
      _ucl1=&UCL;
      /*--Compute marker width--*/
      _x1=&OddsRatio / (10 ** (&WeightVar*&WtFactor/2));
      _x2=&OddsRatio * (10 ** (&WeightVar*&WtFactor/2));
    end;
  /*--Group=2 & 3 (SubGroup and Overall) values will be drawn with groupindex=2 & 3--*/
    else if &group > 1 then do;
      _grp=&group;
      _or2 = &OddsRatio;
    end;
  %end;
  %else %do;
    _wt=&WeightVar / 100;
    _grp=10;
    _or1 = &OddsRatio;
    _lcl1=&LCL; 
    _ucl1=&UCL;
    /*--Compute marker width--*/
    _x1=&OddsRatio / (10 ** (&WeightVar*&WtFactor/2));
    _x2=&OddsRatio * (10 ** (&WeightVar*&WtFactor/2));
  %end;

  /*--Create label columns for standard and additional statistic--*/
  %if %length(&OddsRatio) ne 0 %then %do;
    _OddsRatioLabel = symget('OddsLabel');
  %end;

  %if %length(&LCL) ne 0 %then %do;
    _LowerLabel = symget('LowerLabel');
  %end;

  %if %length(&UCL) ne 0 %then %do;
    _UpperLabel = symget('UpperLabel');
  %end;

  %if %length(&Weight) ne 0 %then %do;
    _WeightLabel = symget('WeightLabel');
  %end;

  %if %length(&StatCol1) ne 0 %then %do;
    _StatColLabel1 = symget('SLabel1');
    _StatCol1 = &StatCol1;
  %end;

  %if %length(&StatCol2) ne 0 %then %do;
    _StatColLabel2 = symget('SLabel2');
    _StatCol2 = &StatCol2;
  %end;

  %if %length(&StatCol3) ne 0 %then %do;
    _StatColLabel3 = symget('SLabel3');
    _StatCol3 = &StatCol3;
  %end;

  %if %length(&StatCol4) ne 0 %then %do;
    _StatColLabel4 = symget('SLabel4');
    _StatCol4 = &StatCol4;
  %end;
 
  run;

/*--Reverse the order to avoid putting axis reverse--*/
proc sort data=_forest out=_forest;
  by descending _ObsId;
  run;

/*--Add sequence numbers to each observation--*/
data _forest;
  set _forest;
  studyvalue=_n_;
run;

/*--Output values and formatted strings to data set--*/
data _forestFormat;
  set _forest end=last;
  keep label start end fmtname type hlo;
  retain fmtname '_Study' type 'n';
  label=&Study;
  start=studyvalue;
  end=studyvalue;
  output;
  if last then do;
    hlo='O';
    label='Other';
    output;
  end;
  run;

/*--Create Format from data set--*/
proc format library=work cntlin=_forestFormat;
  run;

/*--Apply format to study values--*/
/*--Compute width of box proportional to weight in log scale--*/
data _forest;
  format studyvalue _study.;
  set _forest;
  %let Bands=%upcase(&Bands);
  %if &Bands eq YES or &Bands eq Y %then %do;
    if mod(studyvalue, 2) = 0 then _StudyRef=StudyValue;
  %end;
  run;

/*--Compute top and bottom offsets--*/
data _null_;
  pct=&Ratio/nobs;
  thk=pct* 0.9 *100;
  call symputx("pct", pct);
  call symputx("pct2", 2*pct);
  call symputx("RefThickness", thk);
  call symputx("count", nobs);
  set _forest nobs=nobs;
run;

/*title;*/
/*options nodate nonumber;*/

/*--Define GTL template for graph--*/
proc template;
  define statgraph ForestMacro;
    begingraph / designwidth=&Width designheight=&GraphHeight;
      entrytitle "&Title";
      entryfootnote halign=left "&FootNote";
      %if %length(&title2) ne 0 %then %do;
        entrytitle "&title2" / textattrs=graphLabelText;
      %end;
      layout lattice / columns=3 columnweights=(&LabelColWidth &GraphColWidth &StatColWidth) columngutter=0
                       rowdatarange=union;
        /*--Column # 1 contains the Study Labels using Secondary Y axis--*/
        layout overlay / walldisplay=none x2axisopts=(display=none)
                         yaxisopts=(linearopts=(tickvaluesequence=(start=1 end=&count increment=1))
                                    offsetmin=&pct2 offsetmax=&pct display=none
                                    displaysecondary=(tickvalues &border));
          scatterplot y=studyvalue x=_or1 / yaxis=Y xaxis=X2 markerattrs=(size=0) includemissinggroup=true;
          scatterplot y=studyvalue x=_or1 / yaxis=Y xaxis=X2 markerattrs=(size=0) includemissinggroup=true;
        endlayout;
        /*--Column # 2 contains the graph--*/
        layout overlay / &GraphWallDisplay border=false
                         xaxisopts=(offsetmin=0  type=log logopts=(minorticks=true)
                                    label="&PlotTitle" display=(ticks tickvalues line) 
                                    displaysecondary=(label &border)) 
                         yaxisopts=(linearopts=(tickvaluesequence=(start=1 end=&count increment=1))
                                    offsetmin=&pct2 offsetmax=&pct display=none);

          /*--Draw alternating bands using referenceline--*/
          %if &Bands eq YES or &Bands eq Y %then %do;
            referenceline y=_StudyRef / lineattrs=(thickness=&RefThickness.PCT) datatransparency=0.9;
          %end;

          /*--Draw Markers for SubGroup and Overall values--*/
          %if %length(&Group) ne 0 %then %do;
            scatterplot y=studyvalue x=_or2 / markerattrs=(symbol=diamondfilled size=10) group=_grp 
                      includemissinggroup=true index=_grp;
          %end;
          /*--Draw OddsRatio and Limits for Study Values--*/
          scatterplot y=studyvalue x=_or1 / xerrorupper=_ucl1 xerrorlower=_lcl1 
                  markerattrs=graphdata1(symbol=squarefilled size=&MarkerSize);

          /*--Draw box representing the weight of the study--*/
          vectorplot y=studyvalue x=_x2 xorigin=_x1 yorigin=studyvalue / lineattrs=GraphData1(thickness=8) 
                 arrowheads=false;

          /*--Draw Reference lines and labels--*/
          referenceline x=1;
          referenceline x=0.01 /  lineattrs=(pattern=shortdash) datatransparency=0.5;
          referenceline x=0.1 /  lineattrs=(pattern=shortdash) datatransparency=0.5;
          referenceline x=10 /  lineattrs=(pattern=shortdash) datatransparency=0.5;
          referenceline x=100 /  lineattrs=(pattern=shortdash) datatransparency=0.5;
          entry halign=left  "&Label1" / valign=bottom;
          entry halign=right "&Label2" / valign=bottom;
        endlayout;

        /*--Column # 2 contains the statistics data--*/
        layout overlay / &StatWallDisplay border=false
                         x2axisopts=(display=(tickvalues &border) displaysecondary=(line))
                         yaxisopts=(linearopts=(tickvaluesequence=(start=1 end=&count increment=1))
                                    offsetmin=&pct2 offsetmax=&pct 
                                    display=none &DisplaySecondary.);
          /*--Draw alternating bands using referenceline--*/
          %if &Bands eq YES %then %do;
            referenceline y=_StudyRef / lineattrs=(thickness=&RefThickness.PCT) datatransparency=0.9;
          %end;

          /*--Draw standard statistics columns--*/
          %if &DisplayCols eq YES or &DisplayCols eq Y %then %do;
            scatterplot y=studyvalue x=_OddsRatioLabel / markercharacter=&OddsRatio xaxis=x2;
            scatterplot y=studyvalue x=_LowerLabel / markercharacter=&LCL xaxis=x2;
            scatterplot y=studyvalue x=_UpperLabel / markercharacter=&UCL xaxis=x2;
            %if &Weight ne %then %do;
              scatterplot y=studyvalue x=_WeightLabel / markercharacter=_wt xaxis=x2;
            %end;
          %end;

          /*--Draw additional statistics columns--*/
          %if %length(&StatCol1) ne 0 %then %do;
            scatterplot y=studyvalue x=_StatColLabel1 / markercharacter=&StatCol1 xaxis=x2;
          %end;

          %if %length(&StatCol2) ne 0 %then %do;
            scatterplot y=studyvalue x=_StatColLabel2 / markercharacter=&StatCol2 xaxis=x2;
          %end;

          %if %length(&StatCol3) ne 0 %then %do;
            scatterplot y=studyvalue x=_StatColLabel3 / markercharacter=&StatCol3 xaxis=x2;
          %end;

          %if %length(&StatCol4) ne 0 %then %do;
            scatterplot y=studyvalue x=_StatColLabel4 / markercharacter=&StatCol4 xaxis=x2;
          %end;

        endlayout;
      endlayout;
    endgraph;
  end;
run;

proc sgrender data=_forest template=ForestMacro description='Forest Plot';
  run;

%finished:
%mend ForestMacro;








