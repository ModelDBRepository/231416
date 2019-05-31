

function make_AMPA_channel_GHKCa(chanPath)

   str chanPath 

   // Values from Wolfs model, original data Gotz et al 1997 (from NA),
   // Chapman et al 2003
   //float tau1 = 1.1e-3
   //float tau2 = 5.75e-3 

  
   // Ding, Peterson, Surmeier 2008
    if ({TEMPERATURE} == 35)
   float tau1 = 1.9e-3
   float tau2 = 4.8e-3 
    else
         float tau1 = 1.9e-3*2
         float tau2 = 4.8e-3*2
    end
   

   float gmax = 80e-12 // Calculated from Ding et al 2008, Wolf Old: 593e-12
   float Ek = 0.0

   create synchan {chanPath}
   addfield {chanPath} gmax_satur
   setfield {chanPath} tau1 {tau1} tau2 {tau2} gmax {gmax} Gk 0 Ek {Ek} z {setSynBoundary}   // NOTE!!! I have modified the source code 
                                                                              // z = 1 , single synapse model


   // Modification to account for AMPA Ca's reversal potential
   echo "Using separate Erev (from GHK) for Ca-part of AMPA current"

   create ghk {chanPath}/GHK
   
   // Using lower Ca conc, when replicating experiment:
   // BurnashevZhouNeherSakmann1995.pdf (Fig 9A)
   // Fraction of AMPA current in range 0.58 - 5.8 %

   setfield {chanPath}/GHK Cout 2 // Carter & Sabatini 2004 uses 2mM, wolf 5mM
                                  // Kerr & Plenz 2004 uses 1.6mM
   setfield {chanPath}/GHK valency 2.0
   setfield {chanPath}/GHK T {temperature}

end


function addAMPAchannelGHKCa(compPath, chanType,chanName,caBuffer,gbar)
 // chanType: proto type in the /library 
 // chanName: new Name
  str compPath, chanName, caBuffer,chanType
  float gbar
  //str caBuffer = "CaTbuf"

  // Use the following info to tune the fraction of Ca-current
  // Carter and Sabatini 2004 (p 488) 
  // Ca_AMPA/Ca_NMDA = 2.4 +/- 0.6 (at 10 ms) for -80mV
  // Ca_AMPA/Ca_NMDA = 0.4 +/- 0.2 (at 200ms) for -80mV
  // Ca_AMPA/Ca_NMDA = 0.3 +/- 0.1 (at 10 ms) for -60mV
  // Ca_AMPA/Ca_NMDA = 0.02 +/- 0.03 (at 200ms) for -60mV
  //
  // Also:
  // BurnashevZhouNeherSakmann1995.pdf (Fig 9A)
  // Fraction of AMPA current in range 0.58 - 5.8 %

//  float fracCaAMPA = 0.016 //0.0035 //0.005
  float fracCaAMPA = 0.032             // suggested by Johannes :-)

  copy /library/MSsynaptic/{chanType} {compPath}/{chanName}

  addmsg {compPath} {compPath}/{chanName} VOLTAGE Vm
  addmsg {compPath}/{chanName} {compPath} CHANNEL Gk Ek

  // Set the new conductance
  float len = {getfield {compPath} len}
  float dia = {getfield {compPath} dia}
  float pi = 3.141592653589793
  float surf = {len*dia*pi}

  setfield {compPath}/{chanName} gmax {gbar*(1-fracCaAMPA)}

  // GHK object needs conductance times surface area in Gk message
  create table {compPath}/{chanName}/surfMultiplication

  // Set up the table with one element, that contains surface area / 9
  call {compPath}/{chanName}/surfMultiplication TABCREATE 1 1 1

 // float magicFactorY = 3.78e-8 //47
 float magicFactorY = 1.2e-8          // Fig 4-C,Cater and Sabatini, 2004. [Ca]_ampa = [Ca]_nmda at Vm = -80 mV  
  // GHK wants permeability scaled by surface area
  setfield {compPath}/{chanName}/surfMultiplication \
           table->table[0] {fracCaAMPA/(1-fracCaAMPA)*magicFactorY} \
           step_mode TAB_IO 

// We tuned it to soma-sized compartments, but made an error...
//
//  // GHK wants permeability scaled by surface area
//  setfield {compPath}/{chanName}/surfMultiplication \
//           table->table[0] {surf*fracCaAMPA/(1-fracCaAMPA)*magicFactorY} \
//           step_mode TAB_IO 

  addmsg {compPath}/{chanName} \
         {compPath}/{chanName}/surfMultiplication PRD Gk

  addmsg {compPath}/{chanName}/surfMultiplication \
         {compPath}/{chanName}/GHK PERMEABILITY output

//  addmsg {compPath}/{caBuffer} {compPath}/{chanName}/GHK CIN C
  addmsg {compPath} {compPath}/{chanName}/GHK VOLTAGE Vm

//  addmsg {compPath}/{chanName}/GHK {compPath}/{caBuffer} FINFLUX Ik 1
  addmsg {compPath}/{chanName}/GHK {compPath} CHANNEL Gk Ek

 if ({isa dif_shell  {compPath}/{caBuffer}} )         // dif_shell 
      //echo spine calcium model is dif_shell
      addmsg {compPath}/{chanName}/GHK {compPath}/{caBuffer} FINFLUX Ik 1
      addmsg {compPath}/{caBuffer} {compPath}/{chanName}/GHK CIN C
  elif ({isa Ca_concen  {compPath}/{caBuffer}})      // Ca_conc
      //echo spine calcium model is Ca_conc
      addmsg {compPath}/{chanName}/GHK {compPath}/{caBuffer} fI_Ca Ik 1
      addmsg {compPath}/{caBuffer} {compPath}/{chanName}/GHK CIN Ca
  end

  // If we decide to use hsolver then we need to add fix code here
  // see nmda_channel_ghkCa.g for example.

end















