//genesis


function create_CaT
    
    str path = "CaT_channel" 

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
/*************************a1G*********************************************************/
  float mvhalf     = -59.0      // mV,  McRory JE,   et,al. 2001, Note: fixed with m^2 
  float mslope     =  7.74      // mV,  McRory JE,   et,al. 2001
   float hvhalf     =  -87.6     // mV, Hoehn,et,al 1993 
  float hslope     =  6.1       // 6mV, Hoehn,et,al 1993 
/*****************************************************************************************************/
/*******************************a1I*****************************************************/
 //float mvhalf     = -70.02    // mV,  McRory JE,   et,al. 2001, Note: fixed with m^2 
 //  float mslope     =  9.98      // mV,  McRory JE,   et,al. 2001
 //  float hvhalf     =  -93.2     // mV, 
 //  float hslope     =  4.7      // 6mV, 
/******************************************************************************************************/
/************************************a1H************************************************/
// float mvhalf     = -49.7      // mV,  McRory JE,   et,al. 2001, Note: fixed with m^2 
//  float mslope     =  6.35     // mV,  McRory JE,   et,al. 2001
//  float hvhalf     =  -73.6     // mV, a1H
//  float hslope     =  2.76       // a1H
/*********************************************************************************************************/




   float mshift     =  0.0      //  mV
   float hshift     = 0.0        // mV
   float taum       = 0         // ms
   float tauh       = 0         //  ms
  	 /****** End vars used to enable genesis calculations **********/ 	 

   pushe /library	  
    create tabchannel {path} 
    call {path} TABCREATE X {xdivsFiner} {xmin} {xmax}  // activation   gate
    call {path} TABCREATE Y {xdivsFiner} {xmin} {xmax}  // inactivation gate
/* Defines the powers of m Hodgkin-Huxley equationref: Katja Hoehn, et,al. 1993  */
    setfield {path} Ek {Erev} Xpower 2 Ypower 1

/********************* taken from Wolf's model************************************/
// set tau_m table
 float qfactor = 3.0    // experiment was done in room temperature 
 create table  CaT_taum                    // ms
 call  CaT_taum  TABCREATE 30 {xmin} {xmax}
//the table corresponds to -100 mV to 50 mV
 setfield CaT_taum table->table[0] 24.1   \
                    table->table[1] 24.1    \
                    table->table[2] 24.1    \
                    table->table[3] 24.1    \
                    table->table[4] 24.1    \
                    table->table[5] 24.1   \
                    table->table[6] 24.1   \
                    table->table[7] 24.1  \
                    table->table[8] 24.1  \
                    table->table[9] 13.1 \
                    table->table[10] 8.7 \
                    table->table[11] 6.8 \
                    table->table[12] 5.6 \
                    table->table[13] 4.4  \
                    table->table[14] 3.8  \
                    table->table[15] 3.6  \ 
                    table->table[16] 3.3 \
                    table->table[17] 3.6 \
                    table->table[18] 3.6 \
                    table->table[19] 3.3 \
                    table->table[20] 3.3 \
                    table->table[21] 3.3 \
                    table->table[22] 3.3 \
                    table->table[23] 3.3 \
                    table->table[24] 3.3 \
                    table->table[25] 3.3 \
                    table->table[26] 3.3 \
                    table->table[27] 3.3 \
                    table->table[28] 3.3 \
                    table->table[29] 3.3 \
                    table->table[30] 3.3
  
 create table  CaT_tauh 
 call  CaT_tauh  TABCREATE 30 {xmin} {xmax}
//the table corresponds to -100 mV to 50 mV
 setfield CaT_tauh  table->table[0] 382   \
                    table->table[1] 382    \
                    table->table[2] 382    \
                    table->table[3] 382    \
                    table->table[4] 382    \
                    table->table[5] 382   \
                    table->table[6] 382   \
                    table->table[7] 382  \
                    table->table[8] 208  \
                    table->table[9] 162 \
                    table->table[10] 129 \
                    table->table[11] 119 \
                    table->table[12] 107 \
                    table->table[13] 107  \
                    table->table[14] 107  \
                    table->table[15] 108  \ 
                    table->table[16] 109 \
                    table->table[17] 109 \
                    table->table[18] 110 \
                    table->table[19] 110 \
                    table->table[20] 110 \
                    table->table[21] 110 \
                    table->table[22] 110 \
                    table->table[23] 110 \
                    table->table[24] 110 \
                    table->table[25] 110 \
                    table->table[26] 110 \
                    table->table[27] 110 \
                    table->table[28] 110 \
                    table->table[29] 110 \
                    table->table[30] 110

call  CaT_taum  TABFILL  {xdivsFiner} 2
call  CaT_tauh  TABFILL  {xdivsFiner} 2


 for(c = 0; c < {xdivsFiner} + 1; c = c + 1) 
         minf  = 1/(1 + {exp {-(x - mvhalf + mshift)/mslope}})
         hinf  = 1/(1 + {exp {(x - hvhalf + hshift)/hslope}})			
         taum  = {getfield CaT_taum  table->table[{c}]}/qfactor
         tauh  = {getfield CaT_tauh  table->table[{c}]}/qfactor

         setfield {path} X_A->table[{c}] {2*taum*1e-3}    // use m^2, the taum should X2, ref:  Katja Hoehn, et,al. 1993
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

  	setfield {path}GHK Cout 2 // Carter & Sabatini 2004 uses 2mM, 
											// Wolf 5mM
  	setfield {path}GHK valency 2.0
  	setfield {path}GHK T {TEMPERATURE}
	
  	setfield {path} Gbar {gMax}
  	addmsg {path} {path}GHK PERMEABILITY Gk	
end


/**************************************************************************************************
******************************* a1I subnuit******************************************
***************************************************************************************************
 Ref: Molecular and Functional Characterization of a Family of Rat Brain T-type Calcium Channels
****************************************************by Kai DU, kaidu828@gmail.com****
***************************************************************************************************/

function create_CaV33
    
    str path = "CaT33_channel"
    
   int usingSingleGate = 0

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
   float qfactor    = 1        // experiment was done in room temperature
 if({TEMPERATURE}>30)
    qfactor = 3
 end
/*******************************a1I*****************************************************/
  if ({usingSingleGate}==1)
 float mvhalf     = -72.9   // mV,  IFTINCA,   et,al. 2006
  float mslope     =  4.6      // mV,  
  else
  float mvhalf     = -78.01    // mV, IFTINCA,   et,al. 2006, Note: fixed with m^2 
  float mslope     =  5.472      // mV, 
 end
 float hvhalf     =  -78.3     // mV, IFTINCA,   et,al. 2006
 float hslope     =  6.5      // 6mV, 
/******************************************************************************************************/

// set tau_m table
 create table CaV33_taum                    // ms
 call CaV33_taum  TABCREATE 15 {xmin} {xmax}
//the table corresponds to -100 mV to 50 mV
/*****************************************************/
// Mcrory,et,al.2001
 // setfield CaV33_taum table->table[0] 24.1   \
 //                    table->table[1] 24.1    \
 //                    table->table[2] 24.1    \
 //                    table->table[3] 24.1    \
 //                    table->table[4] 24.1    \
 //                    table->table[5] 24.1   \
 //                    table->table[6] 24.1   \
 //                    table->table[7] 24.1  \
 //                    table->table[8] 24.1  \
 //                    table->table[9] 13.1 \
 //                    table->table[10] 8.7 \
 //                    table->table[11] 6.8 \
 //                    table->table[12] 5.6 \
 //                    table->table[13] 4.4  \
 //                    table->table[14] 3.8  \
 //                    table->table[15] 3.6  \ 
 //                    table->table[16] 3.3 \
 //                    table->table[17] 3.6 \
 //                    table->table[18] 3.6 \
 //                    table->table[19] 3.3 \
 //                    table->table[20] 3.3 \
 //                    table->table[21] 3.3 \
 //                    table->table[22] 3.3 \
 //                    table->table[23] 3.3 \
 //                    table->table[24] 3.3 \
 //                    table->table[25] 3.3 \
 //                    table->table[26] 3.3 \
 //                    table->table[27] 3.3 \
 //                    table->table[28] 3.3 \
 //                    table->table[29] 3.3 \
 //                    table->table[30] 3.3
 setfield CaV33_taum table->table[0] 19.8   \
                    table->table[1] 19.8    \
                    table->table[2] 19.8    \
                    table->table[3] 19.8    \
                    table->table[4] 10.3    \
                    table->table[5] 7.66   \
                    table->table[6] 5.42   \
                    table->table[7] 4.36  \
                    table->table[8] 3.83  \
                    table->table[9] 3.4  \
                    table->table[10] 2.98  \
                    table->table[11] 2.13  \
                    table->table[12] 2.65  \
                    table->table[13] 2.65  \
                    table->table[14] 2.65  \
                    table->table[15] 2.65  
  
 create table CaV33_tauh 
 call CaV33_tauh  TABCREATE 15 {xmin} {xmax}
//the table corresponds to -100 mV to 50 mV
 // setfield CaV33_tauh  table->table[0] 382   \
 //                    table->table[1] 382    \
 //                    table->table[2] 382    \
 //                    table->table[3] 382    \
 //                    table->table[4] 382    \
 //                    table->table[5] 382   \
 //                    table->table[6] 382   \
 //                    table->table[7] 382  \
 //                    table->table[8] 208  \
 //                    table->table[9] 162 \
 //                    table->table[10] 129 \
 //                    table->table[11] 119 \
 //                    table->table[12] 107 \
 //                    table->table[13] 107  \
 //                    table->table[14] 107  \
 //                    table->table[15] 108  \ 
 //                    table->table[16] 109 \
 //                    table->table[17] 109 \
 //                    table->table[18] 110 \
 //                    table->table[19] 110 \
 //                    table->table[20] 110 \
 //                    table->table[21] 110 \
 //                    table->table[22] 110 \
 //                    table->table[23] 110 \
 //                    table->table[24] 110 \
 //                    table->table[25] 110 \
 //                    table->table[26] 110 \
 //                    table->table[27] 110 \
 //                    table->table[28] 110 \
 //                    table->table[29] 110 \
 //                    table->table[30] 110

 setfield CaV33_tauh table->table[0] 268.4   \
                    table->table[1]  268.4    \
                    table->table[2] 268.4    \
                    table->table[3] 268.4   \
                    table->table[4] 188.9    \
                    table->table[5] 145.6   \
                    table->table[6] 147.4   \
                    table->table[7] 141.8  \
                    table->table[8] 139.1  \
                    table->table[9] 142.27  \
                    table->table[10] 129.48  \
                    table->table[11] 119.57  \
                    table->table[12] 115.46  \
                    table->table[13] 115.46  \
                    table->table[14] 115.46  \
                    table->table[15] 115.46  

call CaV33_taum  TABFILL  {xdivsFiner} 2
call CaV33_tauh  TABFILL  {xdivsFiner} 2


   float mshift     =  0     //  mV
   float hshift     =  0        // mV
   float taum       = 0         // ms
   float tauh       = 0         //  ms
  	 /****** End vars used to enable genesis calculations **********/ 	 

   pushe /library	  
    create tabchannel {path} 
    call {path} TABCREATE X {xdivsFiner} {xmin} {xmax}  // activation   gate
    call {path} TABCREATE Y {xdivsFiner} {xmin} {xmax}  // inactivation gate
/* Defines the powers of m Hodgkin-Huxley equationref: Katja Hoehn, et,al. 1993  */
  if ({usingSingleGate}==1)
    setfield {path}  Xpower 1 Ypower 1
  else 
     setfield {path}  Xpower 2  Ypower 1
  end

/********************* taken from Wolf's model************************************/
// set tau_m table
 for(c = 0; c < {xdivsFiner} + 1; c = c + 1) 
         minf  = 1/(1 + {exp {-(x - mvhalf + mshift)/mslope}})
         hinf  = 1/(1 + {exp {(x - hvhalf + hshift)/hslope}})			
         taum  = {getfield CaV33_taum  table->table[{c}]}/qfactor 
         tauh  = {getfield CaV33_tauh  table->table[{c}]}/qfactor
       if ({usingSingleGate}==1)
         setfield {path} X_A->table[{c}] {taum*1e-3}   
       else
        setfield {path} X_A->table[{c}] {2*taum*1e-3}   // use m^2, the taum should X2, ref:  Katja Hoehn, et,al. 1993
       end
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

  	setfield {path}GHK Cin 0 Cout {Cout} // Carter & Sabatini 2004 uses 2mM, 
											// Wolf 5mM
  	setfield {path}GHK valency 2.0
  	setfield {path}GHK T {TEMPERATURE}
	
  	setfield {path} Gbar {gMax}
  	addmsg {path} {path}GHK PERMEABILITY Gk	
end



/**************************************************************************************************
******************************* a1G subnuit******************************************
***************************************************************************************************
 Ref: TEMPERATURE DEPENDENCE OF T-TYPE CALCIUM CHANNEL GATING, M. IFTINCA, et.al. 2006

****************************************************by Kai DU, kaidu828@gmail.com****
***************************************************************************************************/
function create_CaV32

     int usingSingleGate = 1
    str path = "CaT32_channel" 

    float xmin  = -0.10  /* minimum voltage we will see in the simulation */     // V
    float xmax  = 0.05  /* maximum voltage we will see in the simulation */      // V
    int xdivsFiner = 3000
    int c = 0
    float gMax = 0.0  // random number, but to be modified later

 	 /****** Begin vars used to enable genesis calculations ********/
   float increment = (xmax - xmin)*1e3/xdivsFiner  // mV
   echo "naF: increment" {increment} "mV"
   float x = -100.00             // mV
   float minf       = 0
   float hinf       = 0
   float qfactor    = 1        // experiment was done in room temperature
 if({TEMPERATURE}>30)
    qfactor = 3
 end

/*************************a1G*********************************************************/
if ({usingSingleGate}==1)
  float mvhalf     = -42.9      // mV, 
   float mslope     = 6.2     // mV,
else
 float mvhalf     = -59.0      // mV,  M. IFTINCA, et.al. 2006, Note: fixed with m^2 
   float mslope     = 7.74      // mV,  M. IFTINCA, et.al. 2006
end
  float hvhalf     =  -64.2     // mV,  
  float hslope     =  8.8       // 6mV,
   float mshift     =  5.0      //  mV
   float hshift     = 5.0        // mV
   float taum       = 0         // ms
   float tauh       = 0         //  ms
/*****************************************************************************************************/
/******************************************************************************************************/


   pushe /library	  
    create tabchannel {path} 
    call {path} TABCREATE X {xdivsFiner} {xmin} {xmax}  // activation   gate
    call {path} TABCREATE Y {xdivsFiner} {xmin} {xmax}  // inactivation gate
/* Defines the powers of m Hodgkin-Huxley equationref: Katja Hoehn, et,al. 1993  */
  //  setfield {path} Ek {Erev} Xpower 2 Ypower 1

// set tau_m table
 create table CaV32_taum                    // ms
 call CaV32_taum  TABCREATE 15 {xmin} {xmax}
//the table corresponds to -100 mV to 50 mV
 setfield CaV32_taum table->table[0] 24.1   \
                    table->table[1] 24.1    \
                    table->table[2] 24.1    \
                    table->table[3] 24.1    \
                    table->table[4] 12.76    \
                    table->table[5] 6.89   \
                    table->table[6] 3.95   \
                    table->table[7] 3.57  \
                    table->table[8] 2.04  \
                    table->table[9] 1.53  \
                    table->table[10] 1.53  \
                    table->table[11] 2.1  \
                    table->table[12] 2.04  \
                    table->table[13] 2.04  \
                    table->table[14] 2.04  \
                    table->table[15] 2.04  
                    
  
 create table CaV32_tauh 
 call CaV32_tauh  TABCREATE 15 {xmin} {xmax}
//the table corresponds to -100 mV to 50 mV
 setfield CaV32_tauh  table->table[0] 294   \
                    table->table[1] 294    \
                    table->table[2] 294    \
                    table->table[3] 294    \
                    table->table[4] 294    \
                    table->table[5] 104   \
                    table->table[6] 66.4   \
                    table->table[7] 60.08  \
                    table->table[8] 50.3  \
                    table->table[9] 40.4 \
                    table->table[10] 34.1 \
                    table->table[11] 32.9 \
                    table->table[12] 31.8 \
                    table->table[13] 31.8  \
                    table->table[14] 31.8  \
                    table->table[15] 31.8 


call CaV32_taum  TABFILL  {xdivsFiner} 2
call CaV32_tauh  TABFILL  {xdivsFiner} 2


if ({usingSingleGate}==1)
    setfield {path}  Xpower 1 Ypower 1
  else 
     setfield {path}  Xpower 2  Ypower 1
  end


/********************* taken from Wolf's model************************************/
// set tau_m table
 for(c = 0; c < {xdivsFiner} + 1; c = c + 1) 
         minf  = 1/(1 + {exp {-(x - mvhalf + mshift)/mslope}})
         hinf  = 1/(1 + {exp {(x - hvhalf + hshift)/hslope}})
         taum  = {getfield CaV32_taum  table->table[{c}]}/qfactor 
         tauh  = {getfield CaV32_tauh  table->table[{c}]}/qfactor
       if ({usingSingleGate}==1)
         setfield {path} X_A->table[{c}] {taum*1e-3}   
       else
        setfield {path} X_A->table[{c}] {2*taum*1e-3}   // use m^2, the taum should X2, ref:  Katja Hoehn, et,al. 1993
       end
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
