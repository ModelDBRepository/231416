
/******************************************************************************************************
***ref: Biophysical Properties and Slow Voltage-dependent Inactivation of a
Sustained Sodium Current in Entorhinal Cortex Layer-II Principal Neurons
A Whole-Cell and Single-Channel Study. Magistretti,et.al. 1999
kai.du@ki.se
**********************************************************************************************************/
function make_NaP_channel
float Erev       = 0.05      // V

    
    str path = "NaP_channel" 

    float xmin  = -0.10  /* minimum voltage we will see in the simulation */     // V
    float xmax  = 0.05  /* maximum voltage we will see in the simulation */      // V
    int xdivsFiner = 3000
    int c = 0


 	 /****** Begin vars used to enable genesis calculations ********/
   float increment = (xmax - xmin)*1e3/xdivsFiner  // mV
   echo "NaP: increment" {increment} "mV"
   float x = -100.00             // mV
   float minf       = 0
   float hinf       = 0
   float mvhalf     = -52.6      // mV, Magistretti,et.al. 1999
   float mshift     =  0.0      //  mV
   float mslope     =  4.6      // mV,  
   float hvhalf     =  -48.8     // mV, Magistretti,et.al. 1999
   float hslope     =  10.0       //
   float hshift     = 0.0        // mV
   float taum       = 0         // ms
   float tauh       = 0         //  ms
  	 /****** End vars used to enable genesis calculations **********/ 	 

  	  
    create tabchannel {path} 
    call {path} TABCREATE X {xdivsFiner} {xmin} {xmax}  // activation   gate
    call {path} TABCREATE Y {xdivsFiner} {xmin} {xmax}  // inactivation gate

// set tau_m table
 float qfactor = 3.0    // 1.0,   
 create table  NaP_tauh                    // ms
 call  NaP_tauh  TABCREATE 15 {xmin} {xmax}
 create table  NaP_taum                    // ms
 call  NaP_taum  TABCREATE 3000 {xmin} {xmax}
//the table corresponds to -100 mV to 50 mV

  
setfield NaP_tauh table->table[0] 4500   \
                    table->table[1] 4750    \
                    table->table[2] 5200   \
                    table->table[3] 6100    \
                    table->table[4] 6300    \
                    table->table[5] 5000   \
                    table->table[6] 4250   \
                    table->table[7] 3500  \
                    table->table[8] 3000 \
                    table->table[9] 2700 \
                    table->table[10] 2500 \
                    table->table[11] 2100 \
                    table->table[12] 2100 \
                    table->table[13] 2100  \
                    table->table[14] 2100 \
                    table->table[15] 2100   

call  NaP_tauh  TABFILL  {xdivsFiner} 2


 for(c = 0; c < {xdivsFiner} + 1; c = c + 1) 
         minf  = 1/(1 + {exp {-(x - mvhalf + mshift)/mslope}})
         hinf  = 1/(1 + {exp {(x - hvhalf + hshift)/hslope}})	
// taum was taken from Traub,et.al. 2003
// the same as in Wolf, et.al. 2005's model, which has been corrected for qfactor 
         if ({x<-40})		
         taum  = 0.025 + 0.14* {exp {( (x + 40 )/10)}}
         else
         taum = 0.02 + 0.145* {exp {( (-x - 40)/10)}}
         end

         tauh  = {getfield NaP_tauh  table->table[{c}]}/qfactor

         setfield {path} X_A->table[{c}] {taum*1e-3}
         setfield {path} X_B->table[{c}] {minf}
         setfield {path} Y_A->table[{c}] {tauh*1e-3}
         setfield {path} Y_B->table[{c}] {hinf}         
         x = x + increment
        
    end


/* Defines the powers of m Hodgkin-Huxley equation*/
    setfield {path} Ek {Erev} Xpower 1 Ypower 1


    /* fill the tables with the values of tau and minf/hinf
     * calculated from tau and minf/hinf
     */
   tweaktau {path} X
   tweaktau {path} Y   

// write channel tables to the files
    tab2file ./MScell/tables/NaPXtable.txt {path} X_A -table2 X_B -overwrite
    tab2file ./MScell/tables/NaPYtable.txt {path} Y_A -table2 Y_B -overwrite
end
