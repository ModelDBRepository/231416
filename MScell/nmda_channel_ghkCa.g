// This channel is modified from the normal NMDA channel to take into 
// account the separate reversal potential for the Ca-current as compared
// to the average reversal potential for the full NMDA-current.
// This is done by using a GHK-object. The NMDA-synchan object is coupled 
// to a GHK object, which is then coupled to its own Mg_block object
// (ie, we have two Mg_block objects, one for the Ca-current, and one
// for the rest.
//
//
// Todo: 
// * Add desensitisation of NMDA
// * Add saturation of NMDA

function make_NMDA_channel_GHKCa(chanPath)

  str chanPath

  float CMg = {CMg}   //1 [Mg] in mM

  // Equation 1 from Vargas-Caballero Robinson 2003
  // Fitted using optimizeMgBlockVCR.m
  float KMgA = 2.992
  float KMgB = 0.01369

  // echo "!!! Using Wolf's parameters temporarilly for comparison"
  // Same values as Wolf 2005, for comparison
  // float KMgA = 3.57
  // float KMgB = 1/62.0

  float Ek = 0.0

// ventral striatum
//  float tau1 = (5.63e-3)/2 // DE Chapman et al 2003, table 1 (15.31/e=5.63ms)
//  float tau2 = (320e-3)/2  // DE Chapman et al 2003, figure 2B, 320ms

// dorsal striatum

  // DE Chapman et al 2003, table 1  gives 10-90 % rise time to 12.13 ms
  // Assume that there is a decay term which is 231 ms (as per the article)
  // We then see what tau_rise is needed to get the rise time.
  // NMDAtauFromRiseTime.m implements this.
  //
  // This gives tau_rise = 7.1e-3 s
  // Q-factor is 2.



 if ({TEMPERATURE} == 35)
  float tau1 = 7.1e-3/2
  float tau2 = (231e-3)/2  // Dorsal striatum has 231 ms decay, same source
                           // q-factor = 2
 else 
  float tau1 = 7.1e-3
  float tau2 = (231e-3)
  echo we use room temprature
 end 
 
  echo "Changed NMDA decaytime and risetime to match dorsal striatum"

  float gmax = 220e-12 // Calculated from Ding et al 2008, Wolf old: 300e-12

  create synchan {chanPath}
  addfield {chanPath} gmax_satur
  setfield {chanPath} \
          Ek   {Ek}   \
          tau1 {tau1} \
          tau2 {tau2} \
          gmax {gmax} \
          Gk   0      \
          z    {setSynBoundary}       // NOTE!!! I have modified the source code , z =1, single synapse model

  create Mg_block {chanPath}/Mg_block_NMDA

  setfield {chanPath}/Mg_block_NMDA \
           CMg {CMg} \
           KMg_A {KMgA} \    // {1.0/eta} \
           KMg_B {KMgB}      // {1.0/gamma} 

  addmsg {chanPath} {chanPath}/Mg_block_NMDA CHANNEL Gk Ek

  // Modification to account for NMDA Ca's reversal potential
  echo "Using separate Erev (from GHK) for Ca-part of NMDA current"

  create ghk {chanPath}/GHK

  // Using lower Ca conc, when replicating experiment:
  // BurnashevZhouNeherSakmann1995.pdf (Fig 9A)
//  setfield {chanPath}/GHK Cout 1.8
//  echo "Using Cout = 1.8 for comparison with Burnashev, Zhou,"
//  echo "Neher, Sakmann 1995 (Fig 9A)"

  setfield {chanPath}/GHK Cout 2 // Carter & Sabatini 2004 uses 2mM, Wolf 5mM
  setfield {chanPath}/GHK valency 2.0
  setfield {chanPath}/GHK T {temperature}
  // Cin is set with message from Ca_concen object

  // Here we need to be careful. The GHK object wants the parent channel
  // to have conductance set to {gChannel*surfaceArea}, but we have set 
  // it to just gChannel. See surfMultiplication further down.

end



function addNMDAchannelGHKCa(compPath, chanType,chanName,caBuffer,gbar)

  str compPath, chanName,chanType
  float gbar
  str caBuffer
//  str caBuffer = "CaTbuf"

  copy /library/MSsynaptic/{chanType} {compPath}/{chanName}

  addmsg {compPath}/{chanName}/Mg_block_NMDA {compPath} CHANNEL Gk Ek
  addmsg {compPath} {compPath}/{chanName}/Mg_block_NMDA VOLTAGE Vm
  addmsg {compPath} {compPath}/{chanName} VOLTAGE Vm

  // Set the new conductance
  float len = {getfield {compPath} len}
  float dia = {getfield {compPath} dia}
  float pi = 3.141592653589793
  float surf = {len*dia*pi}

  // This is a bit tricky:
  // synchan wants gmax = gbar for calculation of normal nmda current
  // ghk object wants gmax = gbar*surfacearea
  // further, we want normal NMDA current to be 90% and Ca-component 10%

  float fracCaNMDA = 0.1


  setfield {compPath}/{chanName} gmax {gbar*(1-fracCaNMDA)} 

  // GHK object needs conductance times surface area in Gk message
  create table {compPath}/{chanName}/surfMultiplication

  // Set up the table with one element, that contains surface area / 9
  call {compPath}/{chanName}/surfMultiplication TABCREATE 1 1 1

  // Dont ask... tune to get 10% Ca current when GHK is used
  // Burnashev/Sakmann J Phys 1995 485 403-418
  // /home/hjorth/artiklar/NMDA/BurnashevZhouNeherSakmann1995.pdf (Fig 9A)
  // Use -60mV and 1.8mM externa Ca when tuneing
  float magicFactorX = 3.46e-8                   // 3.46e-8 //43//3.1e-8

  // Reason for 0.1/0.9 is that Ca-component is 10% only, rest was 90%
  // GHK wants permeability scaled by surface area
  setfield {compPath}/{chanName}/surfMultiplication \
           table->table[0] {fracCaNMDA/(1-fracCaNMDA)*magicFactorX} \
           step_mode TAB_IO 

// We tuned it to soma-sized compartments, but made an error...
//
//  // Reason for 0.1/0.9 is that Ca-component is 10% only, rest was 90%
//  // GHK wants permeability scaled by surface area
//  setfield {compPath}/{chanName}/surfMultiplication \
//           table->table[0] {surf*fracCaNMDA/(1-fracCaNMDA)*magicFactorX} \
//           step_mode TAB_IO 
            
  addmsg {compPath}/{chanName}/Mg_block_NMDA \
         {compPath}/{chanName}/surfMultiplication PRD Gk

  addmsg {compPath}/{chanName}/surfMultiplication \
         {compPath}/{chanName}/GHK PERMEABILITY output

  // Send compartments Ca-conc and voltage to GHK object
 // addmsg {compPath}/{caBuffer} {compPath}/{chanName}/GHK CIN C
  addmsg {compPath} {compPath}/{chanName}/GHK VOLTAGE Vm

  if ({isa dif_shell  {compPath}/{caBuffer}} )         // dif_shell 
      //echo spine calcium model is dif_shell
      addmsg {compPath}/{chanName}/GHK {compPath}/{caBuffer} FINFLUX Ik 1
      addmsg {compPath}/{caBuffer} {compPath}/{chanName}/GHK CIN C
  elif ({isa Ca_concen  {compPath}/{caBuffer}})      // Ca_conc
      //echo spine calcium model is Ca_conc
      addmsg {compPath}/{chanName}/GHK {compPath}/{caBuffer} fI_Ca Ik 1
      addmsg {compPath}/{caBuffer} {compPath}/{chanName}/GHK CIN Ca
  end

  addmsg {compPath}/{chanName}/GHK {compPath} CHANNEL Gk Ek

  // Ugly fix for hsolver to work
 //  if({useHsolve})
//     echo "nmda_channel_ghkCa: This has not been updated to account for Ca-block"
//     echo "as required by hsolver, see source code nmda_channel_ghkCa.g"
//     quit

//     int blockNum = {substring {chanName} {{findchar {chanName} _}+8}}

//     move {compPath}/{chanName}/Mg_block_NMDA \
//          {compPath}/{chanName}/Mg_block{blockNum}

//     move {compPath}/{chanName}/GHK {compPath}/{chanName}/GHK{blockNum}

//     move {compPath}/{chanName}/surfMultiplication \
//          {compPath}/{chanName}/surfMultiplication{blockNum}

//   end


end
