//genesis


// by Kai DU, kai.du@ki.se
function create_CaR
    
    str path = "CaR_channel" 

    float xmin  = -0.10  /* minimum voltage we will see in the simulation */     // V
    float xmax  = 0.05  /* maximum voltage we will see in the simulation */      // V
    int xdivsFiner = 3000
    int c = 0
    float gMax = 1.0  // random number, but to be modified later

 	 /****** Begin vars used to enable genesis calculations ********/
   float increment = (xmax - xmin)*1e3/xdivsFiner  // mV
   echo "naF: increment" {increment} "mV"
   float x = -100.00             // mV
   float minf       = 0
   float hinf       = 0
   float mvhalf     = -8.46      // mV,  ROBERT C. FOEHRING,et.al. 2000 fixed with 3 gates!
   float mslope     = 25.98       // mV, 25.98, 17.98
   float hvhalf     =  -33.3   // mV, used in wolf's model,also from ROBERT C. FOEHRING,et.al. 2000
   float hslope     =  17       // wolf's model


// float hvhalf     =  -76   // mV, 
// float hslope     =  11       // 
   float mshift     =  0.0      //  mV
   float hshift     = 0.0        // mV
   float taum       = 0         // ms
   float tauh       = 0         //  ms
   float qfactor    = 1        // experiment was done in room temperature
 if({TEMPERATURE}>30)
    qfactor = 3
 end
  	 /****** End vars used to enable genesis calculations **********/ 	 

   pushe /library	  
    create tabchannel {path} 
    call {path} TABCREATE X {xdivsFiner} {xmin} {xmax}  // activation   gate
    call {path} TABCREATE Y {xdivsFiner} {xmin} {xmax}  // inactivation gate
/* Defines the powers of m Hodgkin-Huxley equationref: ROBERT C. FOEHRING,et.al. 2000  */
    setfield {path} Ek {Erev} Xpower 3 Ypower 1

/********************* taken from Wolf's model************************************/
// set tau_m table
 create table  CaR_taum                    // ms
 call  CaR_taum  TABCREATE 1 {xmin} {xmax}
//the table corresponds to -100 mV to 50 mV
/********ROBERT C. FOEHRING,et.al. 2000 **************/
// taum ( 0mV ) = 1.7 was taken from FOEHRING,et.al. 2000
// taums are almost "constant" from -50mV to 10 mV according to Brevi 2001 (fig 11-D)
 setfield CaR_taum table->table[0] 1.7  \
                    table->table[1] 1.7  
 
create table  CaR_tauh 
 call  CaR_tauh  TABCREATE 15 {xmin} {xmax}
//the table corresponds to -100 mV to 50 mV
 setfield CaR_tauh  table->table[0] 100   \
                    table->table[1] 100    \
                    table->table[2] 100    \
                    table->table[3] 100    \
                    table->table[4] 100    \
                    table->table[5] 100   \
                    table->table[6] 100   \
                    table->table[7] 100  \
                    table->table[8] 65 \
                    table->table[9] 35\
                    table->table[10] 30 \
                    table->table[11] 20 \
                    table->table[12] 20 \
                    table->table[13] 20  \
                    table->table[14] 20  \
                    table->table[15] 20 


call  CaR_taum  TABFILL  {xdivsFiner} 2
call  CaR_tauh  TABFILL  {xdivsFiner} 2


 for(c = 0; c < {xdivsFiner} + 1; c = c + 1) 
         minf  = 1/(1 + {exp {-(x - mvhalf + mshift)/mslope}})
         hinf  = 1/(1 + {exp {(x - hvhalf + hshift)/hslope}})			
         taum  = {getfield CaR_taum  table->table[{c}]}        //no need to use qfactor; it has been corrected
         tauh  = {getfield CaR_tauh  table->table[{c}]}/qfactor

         setfield {path} X_A->table[{c}] {taum*1e-3}    // in the ROBERT C. FOEHRING,et.al. 2000, the tau was already fixed for m^3
         setfield {path} X_B->table[{c}] {minf}
         setfield {path} Y_A->table[{c}] {tauh*1e-3}
         setfield {path} Y_B->table[{c}] {hinf}         
         x = x + increment
        
    end



    /* fill the tables with the values of tau and minf/hinf
     * calculated from tau and minf/hinf
     */
   tweaktau {path} X
   tweaktau {path} Y   


  	create ghk {path}GHK

  	setfield {path}GHK Cout {Cout} // Carter & Sabatini 2004 uses 2mM, 
											// Wolf 5mM
  	setfield {path}GHK valency 2.0
  	setfield {path}GHK T {TEMPERATURE}
	
  	setfield {path} Gbar {gMax}
  	addmsg {path} {path}GHK PERMEABILITY Gk	
end




