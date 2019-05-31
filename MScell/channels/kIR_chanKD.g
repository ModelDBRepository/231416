//genesis

function make_KIR_channel

 float Erev       = -0.09      // V

    
    str path = "KIR_channel" 

    float xmin  = -0.15  /* minimum voltage we will see in the simulation */     // V
    float xmax  = 0.05  /* maximum voltage we will see in the simulation */      // V
    int xdivsFiner = 4000
    int c = 0


 	 /****** Begin vars used to enable genesis calculations ********/
   float increment = (xmax - xmin)*1e3/xdivsFiner  // mV
   echo "KIR increment:" {increment} "mV"
   float x = -150.00 
   float minf       = 0
   float hinf       = 0
   float mvhalf     = -52.0      // mV
   float mshift     = 50.0      // 30, mV  Shen, et,al. 2007 Nat. Neurosci. supplementary table 1
   float mslope     = 13.0      // mV
   float taum       = 0         // ms
   float tauh       = 0         //  ms
  	 /****** End vars used to enable genesis calculations **********/ 	 
  	 
  	  
    create tabchannel {path} 
    call {path} TABCREATE X {xdivsFiner} {xmin} {xmax}  // activation   gate
//    call {path} TABCREATE Y {xdivsFiner} {xmin} {xmax}  // inactivation gate, no longer used


 float qfactor = 3    // to match in vitro data, Wolf,et.al.2005
 create table  kir_taum                    // ms
 call  kir_taum  TABCREATE 20 {xmin} {xmax}
//the table corresponds to -150 mV to 50 mV, digitally extracted from JE Steephen,et.al. 2009, fig1
 setfield kir_taum table->table[0] 0.2    \
                    table->table[1] 0.2    \
                    table->table[2] 0.2    \
                    table->table[3] 0.2    \
                    table->table[4] 0.2    \
                    table->table[5] 0.38   \
                    table->table[6] 0.97   \
                    table->table[7] 1.486  \
                    table->table[8] 5.3763 \
                    table->table[9] 6.0606 \
                    table->table[10] 6.8966 \
                    table->table[11] 7.6923 \
                    table->table[12] 7.1429 \
                    table->table[13] 5.8824 \
                    table->table[14] 4.4444 \
                    table->table[15] 4.0   \
                    table->table[16] 4.0   \
                    table->table[17] 4.0   \
                    table->table[18] 4.0   \
                    table->table[19] 4.0   \
                    table->table[20] 4.0
  call  kir_taum  TABFILL  {xdivsFiner} 2

 // table for hinf 
 // In  Steephen's paper, there are only three hinf values, corresponding to -120,-90 and -50 mV.
// to expand table from -150 mV to +50 mV, I set hinf(<-120mV) = hinf(-120mV), hinf(-50 mV) = hinf(>-50mV)

/*  We might not need inactivation gate now
 create table kir_hinf 
 call  kir_hinf  TABCREATE 20 {xmin} {xmax}
 setfield kir_hinf table->table[0] 0.53    \
                    table->table[1] 0.53    \
                    table->table[2] 0.53    \
                    table->table[3] 0.53    \
                    table->table[4] 0.55    \
                    table->table[5] 0.57   \
                    table->table[6] 0.59   \
                    table->table[7] 0.6925  \
                    table->table[8] 0.7950 \
                    table->table[9] 0.8975 \
                    table->table[10] 1.0 \
                    table->table[11] 1.0 \
                    table->table[12] 1.0 \
                    table->table[13] 1.0 \
                    table->table[14] 1.0 \
                    table->table[15] 1.0   \
                    table->table[16] 1.0   \
                    table->table[17] 1.0   \
                    table->table[18] 1.0   \
                    table->table[19] 1.0   \
                    table->table[20] 1.0
  call  kir_hinf  TABFILL {xdivsFiner} 2

  //table for tauh
 create table kir_tauh 
 call  kir_tauh  TABCREATE 20 {xmin} {xmax}
 setfield kir_tauh table->table[0] 7.8    \
                    table->table[1] 7.8    \
                    table->table[2] 7.8    \
                    table->table[3] 7.8    \
                    table->table[4] 10.2    \
                    table->table[5] 12.6   \
                    table->table[6] 15.0   \
                    table->table[7] 17.575  \
                    table->table[8] 20.15 \
                    table->table[9] 22.725 \
                    table->table[10] 25.3 \
                    table->table[11] 25.3 \
                    table->table[12] 25.3 \
                    table->table[13] 25.3 \
                    table->table[14] 25.3 \
                    table->table[15] 25.3   \
                    table->table[16] 25.3   \
                    table->table[17] 25.3   \
                    table->table[18] 25.3   \
                    table->table[19] 25.3   \
                    table->table[20] 25.3
  call  kir_tauh  TABFILL {xdivsFiner} 2

*/
                   
    /*fills the tabchannel with values for KIR_alpha & KIR_beta*/

    for(c = 0; c < {xdivsFiner} + 1; c = c + 1) 
         minf  = 1/(1 + {exp {(x - mvhalf + mshift)/mslope}})	
       //  hinf  = {getfield kir_hinf  table->table[{c}]}  		
         taum  = {getfield kir_taum  table->table[{c}]}/qfactor
       //  tauh  = {getfield kir_tauh  table->table[{c}]}
         setfield {path} X_A->table[{c}] {taum*1e-3}
         setfield {path} X_B->table[{c}] {minf}
       //  setfield {path} Y_A->table[{c}] {tauh*1e-3}
       //  setfield {path} Y_B->table[{c}] {hinf}         
         x = x + increment
        
    end

     /* Defines the powers of m Hodgkin-Huxley equation*/
    setfield {path} Ek {Erev} Xpower 1 Ypower 0

    /* fill the tables with the values of tau and minf/hinf
     * calculated from tau and minf/hinf
     */
    tweaktau {path} X
 //   tweaktau {path} Y       
end
