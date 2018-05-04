proc iml;
submit / R;
        coplot(lat ~ long|depth,
                data = quakes)
    endsubmit;
run;
