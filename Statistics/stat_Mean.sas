/*-----------------------------------------------------------------------------
    Program Purpose:       The macro %ut_RTFStyle define a RTF style to export

    Macro Parameters:

    Name:                MacroName
        Allowed Values:    Any valid macro name
        Default Value:     REQUIRED
        Description:       The name of a dataset (or view) that should be
                         used for reporting its number of logical observations.

-----------------------------------------------------------------------------*/
%macro mean(data=, where=1=1, tabfmt=, var=, order1=, format=statistics1_);
    proc means data = &data completetypes NWAY noprint;
        where &where;
        var &var;
        output out=_mean_&order1._1 n=n mean=mean std=std nmiss=nmiss median=median q1=q1 q3=q3 min=min max=max  ;
    run;

    data _mean_&order1._2;
        set _mean_&order1._1;
        length N_C Nmiss_C MeanStd_C MedianQ_C MinMax_C $200;
        N_C       = cats(n);
        Nmiss_C   = cats(nmiss);

        if missing(mean) then MeanStd_C = 'NA';
        else MeanStd_C = strip((put(mean,round1_.)))||' ('||ifc(missing(std),'NA',strip(put(std,round2_.)))||')';

        if missing(median) then MedianQ_C = 'NA';
        else MedianQ_C = (strip(put(median,round1_.)))||' ('||strip(put(q1,round1_.))||', '||strip(put(q3,round1_.))||')';

        if missing(min) then MinMax_C = 'NA';
        else MinMax_C  = strip(cats(min))||', '||strip(cats(max));
        keep N_C Nmiss_C MeanStd_C MedianQ_C MinMax_C;
    run;

    proc transpose data=_mean_&order1._2 out= _mean_&order1._3(rename=(col1=col1_));
        var N_C Nmiss_C MeanStd_C MedianQ_C MinMax_C;
    run;

    data mean_&order1.;
        set _mean_&order1._3;
        length item1 item2 col1 $200;

        order1 = &order1;
        order2 = input(_name_,&format..); 

        item1  = put(order1, &tabfmt..);
        item2  = put(order2, &format..);
        col1   = col1_;
        keep item1 item2 order1 order2 col1;
    run;

%mend;
