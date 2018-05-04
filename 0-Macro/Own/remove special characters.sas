data a;
    set b;
    array char{*} _character_;
    do i = 1 to dim(char);
        char[i]=prxchange("s/[\x7F-\xFF|\x00-\x19]//io", -1, char[i]);
    end;
run;
