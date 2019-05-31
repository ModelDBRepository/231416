function __CHECKSATURATION__(action)
        float   gk,gmax_satur
        //echo {pwe}
        //call . INIT -parent    //IMPORTANT! chained actions!!
        call . PROCESS -parent    //IMPORTANT! chained actions!!
         
        // don't have to name the element since mycompt is cwe
        
        gk   = {getfield Gk}
        gmax_satur = {getfield gmax_satur}
        if (gk>gmax_satur)
         //echo now gk is {gk} and gmax is {gmax}
            setfield Gk {gmax_satur}
        end        
        return 1

 end
