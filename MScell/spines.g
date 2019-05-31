//spines.g for including spines in the MSN model.

include MScell/AddCaSpines.g

//****************make the spines************************************

function make_spines

float surf_neck, vol_neck, len_neck, dia_neck,dia_head,len_head,dia_head, surf_head,vol_head, shell_thick, dia_shell, shell_head, Ca_tau, kB, kE,r,Ca_base  

//int shellmode                                      
str buffer1 = "spineCa"          // name of the calcium pool in the spine
str buffer2   = "spineCaL"
str buffer3 = "buffer_NMDA"         // only to record NMDA-dependent [Ca]

// parameters:
       // for spine neck:
       len_neck=1e-6                               //0.16-2.13
       dia_neck=0.1e-6                             //(0.038-0.46)e-6
       // for spine head:
       dia_head=0.5e-6                              //adopt common size, no exact data are available now
       len_head=0.5e-6
       surf_head=dia_head*len_head*{PI}
       surf_neck=len_neck*dia_neck*{PI}
       // for calcium shells:
       shell_thick=0.1e-6
       dia_shell= dia_head - shell_thick*2
       shell_head={PI}*(dia_head*dia_head-dia_shell*dia_shell)/4


       kE =86.0                                   // Cater and Sabatini, 2004
       Ca_tau = 25.0e-3                            
       r= (1+kE)/Ca_tau
       Ca_base = 50e-6                            // baseline: 50 nM

//  vol_neck={len_neck*dia_neck*dia_neck*PI/4.0}
  if (!{exists spine})
     create compartment spine
  end

 addfield  spine position
 setfield  spine  \
           Cm     {{CM}*surf_neck} \
           Ra    { 4.0*len_neck*{RA}/(dia_neck*dia_neck*{PI})}  \
           Em     {ELEAK}     \
           initVm {EREST_ACT} \
           Rm     {{RM}/surf_neck} \
           inject  0.0         \
           dia     {dia_neck}       \
           len     {len_neck}    \
           position 0.0   




 create compartment spine/head
 addfield spine/head position
 setfield spine/head          \
         Cm     {{CM}*surf_head} \
         Ra    { 4.0*{RA}*len_head/(dia_head*dia_head*{PI})}  \
         Em     {ELEAK}           \
         initVm {EREST_ACT}       \
         Rm     {{RM}/surf_head} \
         inject  0.0              \
         dia     {dia_head}         \
         len     {len_head}       \
         position 0.0
/*combine neck-head of CA1 CA1_spine */
 addmsg spine/head spine RAXIAL Ra Vm 
 addmsg spine spine/head AXIAL Vm


// make calcium buffers 


str buffer1 = "spineCa"                         // calcium pool for the other calcium channels
str buffer2 = "spineCaL"                        // calcium pool for L-type Ca2+ channels
str buffer3 = "buffer_NMDA"                     // only to record NMDA-dependent [Ca]
	
 if ({shellMode}==0)
         makeCaBuffer {buffer1} spine/head        // to create detailed calcium shells
         copy   spine/head/{buffer1} spine/head/{buffer2}
         copy   spine/head/{buffer1} spine/head/{buffer3} 
     elif ({shellMode}==1)  // Sabatini's model.       Sabatini, 2001,2004
          create Ca_concen  spine/head/{buffer1}  // to create simplified Ca_pool here! 
        if ({CaDyeFlag}==2)
           kB = 220                     // Fluo-4, taken from Yasuda,et,al. 2004,STEK
           Ca_tau = (1+kE+kB)/r         // re-calculate time constant because of application of the new calcium-dye
        elif({CaDyeFlag}==3)
           kB = 70                      // Fluo-5F
           Ca_tau = (1+kE+kB)/r
        end

       
         float  shell_dia= dia_head - shell_thick*2
         float  shell_vol= {PI}*(dia_head*dia_head/4-shell_dia*shell_dia/4)*len_head
          setfield spine/head/{buffer1} \
                                 B          {1.0/(2.0*96494*shell_vol*(1+kE+kB))} \
                                 tau        {Ca_tau}                         \
                                 Ca_base    {Ca_base}   \
                                 thick      {shell_thick} 

        copy   spine/head/{buffer1} spine/head/{buffer2}
        copy   spine/head/{buffer1} spine/head/{buffer3}
        setfield   spine/head/{buffer2}  Ca_base  50e-6
  end 
 
 
	create neutral spine/presyn_ext
	create neutral spine/presyn_inh
 
pushe spine/head

/**************************************************************************************
******************to add NMDA/AMPA channels*******************************************
**************************************************************************************/

addSynChannel . {AMPAname} {AMPAgmax}
addNMDAchannel . {NMDAname} {buffer3} {NMDAgmax} 0 

 	setfield ../presyn_ext z 0
	addmsg   ../presyn_ext  ./{NMDAname} ACTIVATION z
	addmsg   ../presyn_ext  ./{AMPAname} ACTIVATION z
 
 
/**********************************end**********************************************

/// now to add GABA
 setfield ../presyn_inh z 0

 if({GABA2Spine}==1)
       addGABAchannel .  GABA_1  {GABAcond}         // added to spine head 
       addmsg   ../presyn_inh   ./GABA_1 ACTIVATION z 
       addGABAchannel .  GABA_2  {GABAcond}         // added to spine head 
       addmsg   ../presyn_inh   ./GABA_2 ACTIVATION z
 elif({GABA2Spine}==2)
       addGABAchannel  .. GABA_1      {GABAcond}         // added to spine neck
       addmsg   ../presyn_inh   ../GABA_1      ACTIVATION z
       addGABAchannel  .. GABA_2      {GABAcond}         // added to spine neck
       addmsg   ../presyn_inh   ../GABA_2      ACTIVATION z
 end

*/

if({addCa2Spine}==1)
/*************************************************************************************
****************** to add Calcium Channels********************************************
******************* L-type, R-type, and T-type
**************************************************************************************/
//  addCaChannel {obj} {compt} {Gchan} {CalciumBuffer}
float Pbar_CaL12, Pbar_CaL13, Pbar_CaR, Pbar_CaT

 Pbar_CaL12       =      3.35e-7
 Pbar_CaL13       =      4.25e-7
 Pbar_CaR         =     13e-7
 Pbar_CaT         =     0.235e-7

addCaChannelspines CaL12_channel      .  {Pbar_CaL12}    {buffer2}         // HVA CaL
addCaChannelspines CaL13_channel      .  {Pbar_CaL13}    {buffer2}      // LVA CaL
addCaChannelspines CaR_channel        .  {Pbar_CaR}      {buffer1}
addCaChannelspines CaT_channel        .  {Pbar_CaT}      {buffer1}

end


/***************************************************************************************
*********************** to add Na+ channels*********************************************
****************************************************************************************/



pope

end
//******************done making spines*********************************

//*****************begin function to add spines*********************************

function add_spines_evenly(cellpath,spine,a,b,density)
/* "spine"   :   spine prototype
** "density" :   1/um,  spine density; The number of spines in one compartment = density * compartment length. 
*/
 str cellpath,compt,spine,thespine,path
 int number,i
 float dia,len,surf_head,k,dia_dend,len_dend,surf_dend,a,b,density,position

 if(!{exists /library/{spine}})
   echo The spine protomodel has not been made! 
    return
 end

foreach compt ({el {cellpath}/##[TYPE=compartment]}) 
 if (!{{compt}=={{cellpath}@"/axIS"} || {compt}=={{cellpath}@"/ax"}}) 
    dia={getfield {compt} dia}
    position={getfield {compt} position}
     len={getfield {compt} len}
    if ({{getpath {compt} -tail}=="soma"})
              len = dia
    end
  //if the compartment is not a spine ,
  // and its position is between [a,b]
   if ({position>=a} && {position<b} ) 
     number = density * len * 1e6

   // make sure that one compartment has at least one spine
    if (number == 0)
       number = number + 1
    end

  for(i=1;i<=number;i=i+1)
       thespine = "spine"@"_"@{i}
       copy /library/{spine} {compt}/{thespine}
       addmsg {compt}/{thespine} {compt} RAXIAL Ra Vm
       addmsg {compt} {compt}/{thespine} AXIAL Vm
  end

 end // end of if position...

 end // end of if ... axIS



end // end of "foreach" loop

end


function add_spines(cellpath,compt_list,spine,number)
 str cellpath,compt,spine,thespine,path,compt_list
 int number,i
 float dia,len,surf_head,k,dia_dend,len_dend,surf_dend
 
  dia= 0.5e-6
  len= 0.5e-6
 if(!{exists /library/{spine}})
   echo The spine protomodel has not been made! 
    return
 end

foreach compt ({arglist {compt_list}}) 
  for(i=1;i<=number;i=i+1)
       thespine = "spine"@"_"@{i}
      if ({exists {cellpath}/{compt}/{thespine}})
       delete {cellpath}/{compt}/{thespine}
       reclaim
      end
       
       copy /library/{spine} {cellpath}/{compt}/{thespine}
       addmsg {cellpath}/{compt}/{thespine} {cellpath}/{compt} RAXIAL Ra Vm
       addmsg {cellpath}/{compt} {cellpath}/{compt}/{thespine} AXIAL Vm
  end  // end of for

end   // end of foreach


end


/******** add clustered random spines to the compartments of interest*************************/
function add_Rand_ClusterSpines(cellpath,compt_list,spine_density,filepath, spine_name , mode, maxnum,maxtime,j)
// number: num of AMPA/NMDA per compartment
// mode: "0", all synapses receiving the same random input; "1", receiving different random inputs
str cellpath,compt,NMDAname,AMPAname,spikegen,spiketrain,new_spiketrain,NMDA,AMPA,filepath,fname,compt_list,spine_name,compt2, thespine
float a,b,position,len,spine_density,position,maxtime
int number,i,method,j, mode,maxnum,k  // 

str NMDAname  =  "NMDA_ghk"
str AMPAname  =  "AMPA_ghk"


if (!{ exists /spikes})
	create neutral /spikes
end

spiketrain = "/spikes/"@{spine_name}

if (!{ exists {spiketrain}})
	create neutral {spiketrain}
end


 if(!{exists /library/spine})
   echo The spine protomodel "spine"  has not been made! 
    return
 end



//j = 20 // spike train
k=1

int all_num = 0 

foreach compt ({arglist {compt_list}})
    compt    = {cellpath}@"/"@{compt}                           
    position ={getfield {compt} position} 
   // len      ={getfield {compt} len}  
  //  number   = len*1e6*spine_density 
    number = spine_density
    compt2 = {getpath {compt} -tail}
    
   for(i=1;i<=number;i=i+1)
  // new_spiketrain = {spiketrain}@"/"@{i}@"_"@{compt2}   // note: there is a bug in  the GENESIS
                                                       // the command "exists" can not compare two strings like" a[3]_1" and "a[3]_2" 
                                                       // so we have to name two strings like "1_a[3]" and "2_a[3]" to make them distinguished by "exists"
  new_spiketrain = {spiketrain}@"/"@{k}
  //  echo the spiketrain is {new_spiketrain} and the existence is { exists {new_spiketrain}}

   // name each spine in the same compartment
   thespine = "spine"@"_"@{i}
      if (!{exists  {compt}/{thespine}})
       copy /library/spine  {compt}/{thespine}
       addmsg {compt}/{thespine} {compt} RAXIAL Ra Vm
       addmsg {compt}  {compt}/{thespine} AXIAL Vm
       position = {getfield {compt}/{thespine} position}
       // just for drawing spines in the cell
       setfield {compt}/{thespine} position {position}
       setfield {compt}/{thespine}/head position {position}
      end
       


if({mode}==1)
 fname = {filepath}@"-"@{j}
else
 fname = filepath
end
 j=j+1

 if ({all_num<maxnum})
 if (!{ exists {new_spiketrain}})
 create timetable {new_spiketrain}
 k=k+1
 echo create {new_spiketrain}
 setfield {new_spiketrain} maxtime {maxtime}  method 4 act_val 1.0 fname {fname}
 echo the file name is {fname}
//setfield {new_spiketrain} maxtime 10.0 method 1 act_val 1.0 meth_desc1 0.2
// note: we need to set a delay here
 call {new_spiketrain} TABFILL
 spikegen = {new_spiketrain}@"/spike"
 create spikegen {spikegen}
 setfield {spikegen} output_amp 1 thresh 0.5 abs_refract 0.0001
 addmsg {new_spiketrain} {spikegen} INPUT activation
 
        addmsg {spikegen} {compt}/{thespine}/head/{NMDAname} SPIKE
        addmsg {spikegen} {compt}/{thespine}/head/{AMPAname} SPIKE
     
  else           // if (!{ exists {new_spiketrain}}).....
   setfield {new_spiketrain} method 4   // need to change it back
   setfield {new_spiketrain} fname {fname}                   
   call {new_spiketrain} TABFILL
  end // end for if (!{ exists...

  all_num = all_num+1
 end   // end of "if all_num....
   end    // end of "for...

end    // end of "foreach...

end 
















function activate_spines(cellpath,compt_list,spine,number, interval ,j0)
// j0: the number of first spine to be activated 
 str cellpath,compt,spine,thespine,path,compt_list
 int number,i,j0,j
 float interval 

 if(!{exists /library/{spine}})
   echo The spine protomodel has not been made! 
    return
 end
 

foreach compt ({arglist {compt_list}}) 
  for(i=1;i<=number;i=i+1)
       j=j0+(i-1)
       thespine = "spine"@"_"@{j}
      if (!{exists {cellpath}/{compt}/{thespine}})
       echo No {cellpath}/{compt}/{thespine} !
       return
      end
       
setfield {cellpath}/{compt}/{thespine}/presyn_ext z {1/{getclock 0}}
step 1
setfield {cellpath}/{compt}/{thespine}/presyn_ext z 0
step {interval} -time
echo activate {compt}/{thespine} now!
  end  // end of for

end   // end of foreach




end

/***********************************************************************************************
************************** MSN Spines***********************************************************
************************************************************************************************/


function make2_spines

float surf_neck, vol_neck, len_neck, dia_neck,dia_head,len_head,dia_head, surf_head,vol_head, shell_thick, dia_shell, shell_head, Ca_tau, kB, kE,r,Ca_base  
//int shellmode                                      
str buffer1 = "spineCa"          // name of the calcium pool in the spine
str buffer2   = "spineCaL"
str buffer3 = "buffer_NMDA"         // only to record NMDA-dependent [Ca]
str NMDAname   = "NMDA_channel"
str AMPAname   = "AMPA_channel"

// float AMPAcond = 80e-12
// float NMDAcond = 220e-12

//float AMPAcond = 170e-12
//float NMDAcond = 470e-12

//float AMPAcond = {170e-12}*2.5    //2.5 when generating plateau
//float NMDAcond = {470e-12}*2.5    


float GABAcond = 1500e-12  // phasic GABA = 40-80 pA according Valence's data

// parameters:
       // for spine neck:
       len_neck=1e-6                               //0.16-2.13
       dia_neck=0.1e-6                             //(0.038-0.46)e-6
       // for spine head:
       dia_head=0.5e-6                              //adopt common size, no exact data are available now
       len_head=0.5e-6
       surf_head=dia_head*len_head*{PI}
       surf_neck=len_neck*dia_neck*{PI}
       // for calcium shells:
       shell_thick=0.1e-6
       dia_shell= dia_head - shell_thick*2
       shell_head={PI}*(dia_head*dia_head-dia_shell*dia_shell)/4


       kE =86.0                                   // Cater and Sabatini, 2004
       Ca_tau = 25.0e-3                            
       r= (1+kE)/Ca_tau
       Ca_base = 50e-6                            // baseline: 50 nM

//  vol_neck={len_neck*dia_neck*dia_neck*PI/4.0}
  if (!{exists spine})
     create compartment spine
  end

 addfield  spine position
 setfield  spine  \
           Cm     {{CM}*surf_neck} \
           Ra    { 4.0*len_neck*{RA}/(dia_neck*dia_neck*{PI})}  \
           Em     {ELEAK}     \
           initVm {EREST_ACT} \
           Rm     {{RM}/surf_neck} \
           inject  0.0         \
           dia     {dia_neck}       \
           len     {len_neck}    \
           position 0.0   




 create compartment spine/head
 addfield spine/head position
 setfield spine/head          \
         Cm     {{CM}*surf_head} \
         Ra    { 4.0*{RA}*len_head/(dia_head*dia_head*{PI})}  \
         Em     {ELEAK}           \
         initVm {EREST_ACT}       \
         Rm     {{RM}/surf_head} \
         inject  0.0              \
         dia     {dia_head}         \
         len     {len_head}       \
         position 0.0
/*combine neck-head of CA1 CA1_spine */

 addmsg spine/head spine RAXIAL Ra Vm 
 addmsg spine spine/head AXIAL Vm


// // make calcium buffers 

//  if ({shellMode}==0)
//          makeCaBuffer {buffername} spine/head        // to create detailed calcium shells
//          copy   spine/head/{buffername} spine/head/{buffer2} 
//      elif ({shellMode}==1)  // Sabatini's model.       Sabatini, 2001,2004
//           create Ca_concen  spine/head/{buffername}  // to create simplified Ca_pool here! 
//         if ({CaDyeFlag}==2)
//            kB = 220                     // Fluo-4, taken from Yasuda,et,al. 2004,STEK
//            Ca_tau = (1+kE+kB)/r         // re-calculate time constant because of application of indicators
//         elif({CaDyeFlag}==3)
//            kB = 70                      // Fluo-5F
//            Ca_tau = (1+kE+kB)/r
//         end

       
//          float  shell_dia= dia_head - shell_thick*2
//          float  shell_vol= {PI}*(dia_head*dia_head/4-shell_dia*shell_dia/4)*len_head
//           setfield spine/head/{buffername} \
//                                  B          {1.0/(2.0*96494*shell_vol*(1+kE+kB))} \
//                                  tau        {Ca_tau}                         \
//                                  Ca_base    {Ca_base}   \
//                                  thick      {shell_thick} 

//         copy   spine/head/{buffername} spine/head/{buffer2}
//         setfield   spine/head/{buffer2}  Ca_base  50e-6
//   end

// make calcium buffers 

 if ({shellMode}==0)
         makeCaBuffer {buffer1} spine/head        // to create detailed calcium shells
         copy   spine/head/{buffer1} spine/head/{buffer2}
         copy   spine/head/{buffer1} spine/head/{buffer3} 
     elif ({shellMode}==1)  // Sabatini's model.       Sabatini, 2001,2004
          create Ca_concen  spine/head/{buffer1}  // to create simplified Ca_pool here! 
        if ({CaDyeFlag}==2)
           kB = 220                     // Fluo-4, taken from Yasuda,et,al. 2004,STEK
           Ca_tau = (1+kE+kB)/r         // re-calculate time constant because of application of the new calcium-dye
        elif({CaDyeFlag}==3)
           kB = 70                      // Fluo-5F
           Ca_tau = (1+kE+kB)/r
        end

       
         float  shell_dia= dia_head - shell_thick*2
         float  shell_vol= {PI}*(dia_head*dia_head/4-shell_dia*shell_dia/4)*len_head
          setfield spine/head/{buffer1} \
                                 B          {1.0/(2.0*96494*shell_vol*(1+kE+kB))} \
                                 tau        {Ca_tau}                         \
                                 Ca_base    {Ca_base}   \
                                 thick      {shell_thick} 

        copy   spine/head/{buffer1} spine/head/{buffer2}
        copy   spine/head/{buffer1} spine/head/{buffer3}
        setfield   spine/head/{buffer2}  Ca_base  50e-6
  end 
 
create neutral spine/presyn_ext
create neutral spine/presyn_inh

pushe spine/head

/**************************************************************************************
******************to add NMDA/AMPA channels*******************************************
**************************************************************************************
*/

int NMDABufferMode = 0               // 1, connect both NMDA and AMPA calcium to NMDA_buffer
                                     // 0, connect only NMDA currents to NMDA_buffer

addAMPAchannelGHKCa . "AMPA_channel_GHKCa" {AMPAname} {buffer3} {AMPAcond2}
addNMDAchannelGHKCa . "NMDA_channel_GHKCa" {NMDAname} {buffer3} {NMDAcond2}
setfield ./{NMDAname}/Mg_block_NMDA CMg {CMg_spine}

 // if ({isa dif_shell  ./buffer_NMDA} )         // dif_shell 
 //  //    echo spine calcium model is dif_shell
 //      addmsg ./{NMDAname}/GHK ./buffer_NMDA FINFLUX Ik 1
 //      if({NMDABufferMode}==1)
 //         addmsg ./{AMPAname}/GHK ./buffer_NMDA FINFLUX Ik 1
 //      end
 //  elif ({isa Ca_concen  ./buffer_NMDA})      // Ca_conc
 // //     echo spine calcium model is Ca_conc
 //      addmsg ./{NMDAname}/GHK ./buffer_NMDA fI_Ca Ik 1
 //      if({NMDABufferMode}==1)
 //         addmsg ./{AMPAname}/GHK ./buffer_NMDA fI_Ca Ik 1
 //      end
 //  end

 if ({isa dif_shell  ./{buffer3}} )         // dif_shell 
      echo spine calcium model is dif_shell
      addmsg ./{NMDAname}/GHK ./{buffer3} FINFLUX Ik 1
      if({NMDABufferMode}==1)
         addmsg ./{AMPAname}/GHK ./{buffer3} FINFLUX Ik 1
      end
  elif ({isa Ca_concen  ./{buffer3}})      // Ca_conc
      echo spine calcium model is Ca_conc
      addmsg ./{NMDAname}/GHK ./{buffer3} fI_Ca Ik 1
      if({NMDABufferMode}==1)
         addmsg ./{AMPAname}/GHK ./{buffer3} fI_Ca Ik 1
      end
  end

 setfield ../presyn_ext z 0
 addmsg   ../presyn_ext  ./{NMDAname} ACTIVATION z
 addmsg   ../presyn_ext  ./{AMPAname} ACTIVATION z

/**********************************end**********************************************/

/// now to add GABA

/*
 setfield ../presyn_inh z 0

 if({GABA2Spine}==1)
       addGABAchannel .  GABA_1  {GABAcond}         // added to spine head 
       addmsg   ../presyn_inh   ./GABA_1 ACTIVATION z 
      // addGABAchannel .  GABA_2  {GABAcond}         // added to spine head 
     //  addmsg   ../presyn_inh   ./GABA_2 ACTIVATION z
 elif({GABA2Spine}==2)
       addGABAchannel  .. GABA_1      {GABAcond}         // added to spine neck
       addmsg   ../presyn_inh   ../GABA_1      ACTIVATION z
     //  addGABAchannel  .. GABA_2      {GABAcond}         // added to spine neck
     //  addmsg   ../presyn_inh   ../GABA_2      ACTIVATION z
 end

*/

if({addCa2Spine}==1)
/*************************************************************************************
****************** to add Calcium Channels********************************************
******************* L-type, R-type, and T-type
**************************************************************************************/
//  addCaChannel {obj} {compt} {Gchan} {CalciumBuffer}

float k_CaT, k_CaR
float Pbar_CaL12, Pbar_CaL13,Pbar_CaT
k_CaT = 1
k_CaR = 1
 Pbar_CaL12       =      3.35e-7
 Pbar_CaL13       =      4.25e-7



addCaChannelspines CaL12_channel      .  {Pbar_CaL12}    {buffer2}         // HVA CaL
addCaChannelspines CaL13_channel      .  {Pbar_CaL13}    {buffer2}      // LVA CaL
if ({usingCaR}==1)	
addCaChannelspines CaR_channel        .  {Pbar_CaR*k_CaR}      {buffer1}
end
if ({usingCaT}==1)
//addCaChannelspines CaT_channel        .  {Pbar_CaT*k_CaT}      {buffer1}
addCaChannelspines CaT33_channel        .  {Pbar_CaV33*k_CaT}      {buffer1}
addCaChannelspines CaT32_channel        .  {Pbar_CaV32*k_CaT}      {buffer1}
end

//copy /library/KIR_channel . 
//setfield ./KIR_channel Gbar {2*gKIRdist*surf_head}
//addmsg   .             ./KIR_channel  VOLTAGE Vm
//addmsg ./KIR_channel    .             CHANNEL Gk Ek
end


/***************************************************************************************
*********************** to add Na+ channels*********************************************
****************************************************************************************/



pope

end


function make3_spines(spine_name,AMPAcond,NMDAcond)

float surf_neck, vol_neck, len_neck, dia_neck,dia_head,len_head,dia_head, surf_head,vol_head, shell_thick, dia_shell, shell_head, Ca_tau, kB, kE,r,Ca_base,AMPAcond,NMDAcond  
str spine_name
//int shellmode                                      
str buffer1 = "spineCa"          // name of the calcium pool in the spine
str buffer2   = "spineCaL"
str buffer3 = "buffer_NMDA"         // only to record NMDA-dependent [Ca]
str NMDAname   = "NMDA_channel"
str AMPAname   = "AMPA_channel"

float GABAcond = 1500e-12  // phasic GABA = 40-80 pA according Valence's data

// parameters:
       // for spine neck:
       len_neck=1e-6                               //0.16-2.13
       dia_neck=0.1e-6                             //(0.038-0.46)e-6
       // for spine head:
       dia_head=0.5e-6                              //adopt common size, no exact data are available now
       len_head=0.5e-6
       surf_head=dia_head*len_head*{PI}
       surf_neck=len_neck*dia_neck*{PI}
       // for calcium shells:
       shell_thick=0.1e-6
       dia_shell= dia_head - shell_thick*2
       shell_head={PI}*(dia_head*dia_head-dia_shell*dia_shell)/4


       kE =86.0                                   // Cater and Sabatini, 2004
       Ca_tau = 25.0e-3                            
       r= (1+kE)/Ca_tau
       Ca_base = 50e-6                            // baseline: 50 nM

//  vol_neck={len_neck*dia_neck*dia_neck*PI/4.0}
  if (!{exists {spine_name}})
     create compartment {spine_name}
  end

 addfield  {spine_name} position
 setfield  {spine_name}  \
           Cm     {{CM}*surf_neck} \
           Ra    { 4.0*len_neck*{RA}/(dia_neck*dia_neck*{PI})}  \
           Em     {ELEAK}     \
           initVm {EREST_ACT} \
           Rm     {{RM}/surf_neck} \
           inject  0.0         \
           dia     {dia_neck}       \
           len     {len_neck}    \
           position 0.0   




 create compartment {spine_name}/head
 addfield {spine_name}/head position
 setfield {spine_name}/head          \
         Cm     {{CM}*surf_head} \
         Ra    { 4.0*{RA}*len_head/(dia_head*dia_head*{PI})}  \
         Em     {ELEAK}           \
         initVm {EREST_ACT}       \
         Rm     {{RM}/surf_head} \
         inject  0.0              \
         dia     {dia_head}         \
         len     {len_head}       \
         position 0.0
/*combine neck-head of CA1 CA1_spine */

 addmsg {spine_name}/head {spine_name} RAXIAL Ra Vm 
 addmsg {spine_name} {spine_name}/head AXIAL Vm


// // make calcium buffers 

//  if ({shellMode}==0)
//          makeCaBuffer {buffername} spine/head        // to create detailed calcium shells
//          copy   spine/head/{buffername} spine/head/{buffer2} 
//      elif ({shellMode}==1)  // Sabatini's model.       Sabatini, 2001,2004
//           create Ca_concen  spine/head/{buffername}  // to create simplified Ca_pool here! 
//         if ({CaDyeFlag}==2)
//            kB = 220                     // Fluo-4, taken from Yasuda,et,al. 2004,STEK
//            Ca_tau = (1+kE+kB)/r         // re-calculate time constant because of application of indicators
//         elif({CaDyeFlag}==3)
//            kB = 70                      // Fluo-5F
//            Ca_tau = (1+kE+kB)/r
//         end

       
//          float  shell_dia= dia_head - shell_thick*2
//          float  shell_vol= {PI}*(dia_head*dia_head/4-shell_dia*shell_dia/4)*len_head
//           setfield spine/head/{buffername} \
//                                  B          {1.0/(2.0*96494*shell_vol*(1+kE+kB))} \
//                                  tau        {Ca_tau}                         \
//                                  Ca_base    {Ca_base}   \
//                                  thick      {shell_thick} 

//         copy   spine/head/{buffername} spine/head/{buffer2}
//         setfield   spine/head/{buffer2}  Ca_base  50e-6
//   end

// make calcium buffers 

 if ({shellMode}==0)
         makeCaBuffer {buffer1} {spine_name}/head        // to create detailed calcium shells
         copy   {spine_name}/head/{buffer1} {spine_name}/head/{buffer2}
         copy   {spine_name}/head/{buffer1} {spine_name}/head/{buffer3} 
     elif ({shellMode}==1)  // Sabatini's model.       Sabatini, 2001,2004
          create Ca_concen  {spine_name}/head/{buffer1}  // to create simplified Ca_pool here! 
        if ({CaDyeFlag}==2)
           kB = 220                     // Fluo-4, taken from Yasuda,et,al. 2004,STEK
           Ca_tau = (1+kE+kB)/r         // re-calculate time constant because of application of the new calcium-dye
        elif({CaDyeFlag}==3)
           kB = 70                      // Fluo-5F
           Ca_tau = (1+kE+kB)/r
        end

       
         float  shell_dia= dia_head - shell_thick*2
         float  shell_vol= {PI}*(dia_head*dia_head/4-shell_dia*shell_dia/4)*len_head
          setfield {spine_name}/head/{buffer1} \
                                 B          {1.0/(2.0*96494*shell_vol*(1+kE+kB))} \
                                 tau        {Ca_tau}                         \
                                 Ca_base    {Ca_base}   \
                                 thick      {shell_thick} 

        copy   {spine_name}/head/{buffer1} {spine_name}/head/{buffer2}
        copy   {spine_name}/head/{buffer1} {spine_name}/head/{buffer3}
        setfield   {spine_name}/head/{buffer2}  Ca_base  50e-6
  end 
 
create neutral {spine_name}/presyn_ext
create neutral {spine_name}/presyn_inh

pushe {spine_name}/head

/**************************************************************************************
******************to add NMDA/AMPA channels*******************************************
**************************************************************************************
*/

int NMDABufferMode = 0               // 1, connect both NMDA and AMPA calcium to NMDA_buffer
                                     // 0, connect only NMDA currents to NMDA_buffer

addAMPAchannelGHKCa . "AMPA_channel_GHKCa" {AMPAname} {buffer3} {AMPAcond2}
addNMDAchannelGHKCa . "NMDA_channel_GHKCa" {NMDAname} {buffer3} {NMDAcond2}


 // if ({isa dif_shell  ./buffer_NMDA} )         // dif_shell 
 //  //    echo {spine_name} calcium model is dif_shell
 //      addmsg ./{NMDAname}/GHK ./buffer_NMDA FINFLUX Ik 1
 //      if({NMDABufferMode}==1)
 //         addmsg ./{AMPAname}/GHK ./buffer_NMDA FINFLUX Ik 1
 //      end
 //  elif ({isa Ca_concen  ./buffer_NMDA})      // Ca_conc
 // //     echo {spine_name} calcium model is Ca_conc
 //      addmsg ./{NMDAname}/GHK ./buffer_NMDA fI_Ca Ik 1
 //      if({NMDABufferMode}==1)
 //         addmsg ./{AMPAname}/GHK ./buffer_NMDA fI_Ca Ik 1
 //      end
 //  end

 if ({isa dif_shell  ./{buffer3}} )         // dif_shell 
      echo {spine_name} calcium model is dif_shell
      addmsg ./{NMDAname}/GHK ./{buffer3} FINFLUX Ik 1
      if({NMDABufferMode}==1)
         addmsg ./{AMPAname}/GHK ./{buffer3} FINFLUX Ik 1
      end
  elif ({isa Ca_concen  ./{buffer3}})      // Ca_conc
      echo {spine_name} calcium model is Ca_conc
      addmsg ./{NMDAname}/GHK ./{buffer3} fI_Ca Ik 1
      if({NMDABufferMode}==1)
         addmsg ./{AMPAname}/GHK ./{buffer3} fI_Ca Ik 1
      end
  end

 setfield ../presyn_ext z 0
 addmsg   ../presyn_ext  ./{NMDAname} ACTIVATION z
 addmsg   ../presyn_ext  ./{AMPAname} ACTIVATION z

/**********************************end**********************************************/

/// now to add GABA

/*
 setfield ../presyn_inh z 0

 if({GABA2Spine}==1)
       addGABAchannel .  GABA_1  {GABAcond}         // added to spine head 
       addmsg   ../presyn_inh   ./GABA_1 ACTIVATION z 
      // addGABAchannel .  GABA_2  {GABAcond}         // added to spine head 
     //  addmsg   ../presyn_inh   ./GABA_2 ACTIVATION z
 elif({GABA2Spine}==2)
       addGABAchannel  .. GABA_1      {GABAcond}         // added to spine neck
       addmsg   ../presyn_inh   ../GABA_1      ACTIVATION z
     //  addGABAchannel  .. GABA_2      {GABAcond}         // added to spine neck
     //  addmsg   ../presyn_inh   ../GABA_2      ACTIVATION z
 end

*/

if({addCa2Spine}==1)
/*************************************************************************************
****************** to add Calcium Channels********************************************
******************* L-type, R-type, and T-type
**************************************************************************************/
//  addCaChannel {obj} {compt} {Gchan} {CalciumBuffer}

float k_CaT, k_CaR
float Pbar_CaL12, Pbar_CaL13,Pbar_CaT
k_CaT = 1
k_CaR = 1
 Pbar_CaL12       =      3.35e-7
 Pbar_CaL13       =      4.25e-7



addCaChannelspines CaL12_channel      .  {Pbar_CaL12}    {buffer2}         // HVA CaL
addCaChannelspines CaL13_channel      .  {Pbar_CaL13}    {buffer2}      // LVA CaL
if ({usingCaR}==1)	
addCaChannelspines CaR_channel        .  {Pbar_CaR*k_CaR}      {buffer1}
end
if ({usingCaT}==1)
//addCaChannelspines CaT_channel        .  {Pbar_CaT*k_CaT}      {buffer1}
addCaChannelspines CaT33_channel        .  {Pbar_CaV33*k_CaT}      {buffer1}
addCaChannelspines CaT32_channel        .  {Pbar_CaV32*k_CaT}      {buffer1}
end

//copy /library/KIR_channel . 
//setfield ./KIR_channel Gbar {2*gKIRdist*surf_head}
//addmsg   .             ./KIR_channel  VOLTAGE Vm
//addmsg ./KIR_channel    .             CHANNEL Gk Ek
end


/***************************************************************************************
*********************** to add Na+ channels*********************************************
****************************************************************************************/



pope

end

