//genesis

/***************************MS Model, Version 6	*********************
****************************   naF_chan.g 	*********************
						Rebekah Evans rcolema2@gmu.edu	
		Tom Sheehan tsheeha2@gmu.edu	thsheeha@vt.edu	703-538-8361
******************************************************************************
******************************************************************************/

/* Na Fast channel
 * This is a tab channel created from NaF channel data in Martina and Jonas 1997.
 * They are using hippocmpal pyramidal cells and are recording at 22-24 degrees C.
 * there is data from hamster striatal neurons that closely matches, but is slightly less complete (Sieb et al., 2002) 20-21 degrees.
 * Our data matching process showed that the original model from Johanes Hjorth via Kai Du and Tom Sheehan matched closely with the
 * activation and inactivation inf curves, but did not match the tau curves very well. This new tab channel uses Alphas and Betas obtained by
 * matching both the inf (cubed) and tau curves.  
 * Note that to distinguish these updated channels from the old, the file is now called NaF_chan.g (instead of NaF_channel.g) and the
 * function is called make_NaF_chan.  
 * *************** Rebekah Evans 01/23/10 rcolema2@gmu.edu ********************************/

/**********************************************************************************
*******************************Naf channel of MSN**********************************
**ref: Nobukuni Ogata, et.al. 1990
**implemented by Kai Du, kai.du@ki.se
***********************************************************************************/
function make_NaF_channel
float Erev       = 0.05      // V

    
    str path = "NaF_channel" 

    float xmin  = -0.10  /* minimum voltage we will see in the simulation */     // V
    float xmax  = 0.05  /* maximum voltage we will see in the simulation */      // V
    int xdivsFiner = 3000
    int c = 0


 	 /****** Begin vars used to enable genesis calculations ********/
   float increment = (xmax - xmin)*1e3/xdivsFiner  // mV
   echo "naF: increment" {increment} "mV"
   float x = -100.00             // mV
   float minf       = 0
   float hinf       = 0
   float mvhalf     = -25.0      // mV, Nobukuni Ogata, et.al. 1990
   float mshift     =  0.0      //  mV
   float mslope     =  9.2      // mV,  Nobukuni Ogata, et.al. 1990
   float hvhalf     =  -62.0     // mV, Nobukuni Ogata, et.al. 1990
   float hslope     =  6.0       // 6mV, Nobukuni Ogata, et.al. 1990
   float hshift     = 0.0        // mV
   float taum       = 0         // ms
   float tauh       = 0         //  ms
  	 /****** End vars used to enable genesis calculations **********/ 	 

  	  
    create tabchannel {path} 
    call {path} TABCREATE X {xdivsFiner} {xmin} {xmax}  // activation   gate
    call {path} TABCREATE Y {xdivsFiner} {xmin} {xmax}  // inactivation gate

// set tau_m table
 float qfactor = 2  // 1.2, Ogata's experiment was done in room temperature 
 create table  naf_taum                    // ms
 call  naf_taum  TABCREATE 15 {xmin} {xmax}
//the table corresponds to -100 mV to 50 mV
 setfield naf_taum table->table[0] 0.3162    \
                    table->table[1] 0.3162    \
                    table->table[2] 0.3162    \
                    table->table[3] 0.4074    \
                    table->table[4] 0.6166    \
                    table->table[5] 0.3548   \
                    table->table[6] 0.2399   \
                    table->table[7] 0.1585  \
                    table->table[8] 0.1047 \
                    table->table[9] 0.0871 \
                    table->table[10] 0.0851 \
                    table->table[11] 0.0813 \
                    table->table[12] 0.0832 \
                    table->table[13] 0.0832  \
                    table->table[14] 0.0832 \
                    table->table[15] 0.0832   

 create table  naf_tauh                    // ms
 call  naf_tauh  TABCREATE 15 {xmin} {xmax}
//the table corresponds to -100 mV to 50 mV
  
setfield naf_tauh table->table[0] 1.5   \
                    table->table[1] 1.5    \
                    table->table[2] 1.5   \
                    table->table[3] 1.5    \
                    table->table[4] 1.5    \
                    table->table[5] 1.5   \
                    table->table[6] 1.5136   \
                    table->table[7] 0.6761  \
                    table->table[8] 0.5129 \
                    table->table[9] 0.4365 \
                    table->table[10] 0.3715 \
                    table->table[11] 0.3388 \
                    table->table[12] 0.2951 \
                    table->table[13] 0.2884  \
                    table->table[14] 0.2754 \
                    table->table[15] 0.2754   

call  naf_taum  TABFILL  {xdivsFiner} 2
call  naf_tauh  TABFILL  {xdivsFiner} 2


 for(c = 0; c < {xdivsFiner} + 1; c = c + 1) 
         minf  = 1/(1 + {exp {-(x - mvhalf + mshift)/mslope}})
         hinf  = 1/(1 + {exp {(x - hvhalf + hshift)/hslope}})			
         taum  = {getfield naf_taum  table->table[{c}]}/qfactor
         tauh  = {getfield naf_tauh  table->table[{c}]}/qfactor

         setfield {path} X_A->table[{c}] {taum*1e-3}
         setfield {path} X_B->table[{c}] {minf}
         setfield {path} Y_A->table[{c}] {tauh*1e-3}
         setfield {path} Y_B->table[{c}] {hinf}         
         x = x + increment
        
    end


/* Defines the powers of m Hodgkin-Huxley equation*/
    setfield {path} Ek {Erev} Xpower 3 Ypower 1


    /* fill the tables with the values of tau and minf/hinf
     * calculated from tau and minf/hinf
     */
   tweaktau {path} X
   tweaktau {path} Y   

// write channel tables to the files
    //tab2file ./MScell/tables/naFXtable.txt {path} X_A -table2 X_B -overwrite
   // tab2file ./MScell/tables/naFYtable.txt {path} Y_A -table2 Y_B -overwrite
end
