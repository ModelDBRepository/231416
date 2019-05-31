//genesis



function addNMDAchannel(compPath, chanpath,caBuffer, gbar, ghk)

  str compPath, chanpath
  float gbar
  str caBuffer 

  copy /library/{chanpath} {compPath}/{chanpath}
  addmsg {compPath} {compPath}/{chanpath}/block VOLTAGE Vm
  addmsg {compPath} {compPath}/{chanpath} VOLTAGE Vm
  if (ghk==0)
    addmsg {compPath}/{chanpath}/block {compPath} CHANNEL Gk Ek
  end

  if (ghk==1)
    addmsg {compPath} {compPath}/{chanName}/GHK VOLTAGE Vm
    addmsg {compPath}/{chanName}/GHK {compPath} CHANNEL Gk Ek
  end

  // Set the new conductance
  float len = {getfield {compPath} len}
  float dia = {getfield {compPath} dia}
  float pi = 3.141592653589793
  float surf = {len*dia*pi}

/*	//echo "XXXXXXXXXXXXXXX addNMDAchannel XXXXXXXXXXXXXXXX"
	//echo "compPath = "{compPath}
	//echo "chanpath = "{chanpath}
	//echo "caBuffer = "{caBuffer}
	//echo "gbar = "{gbar}
	//echo "XXXXXXXXXXXXXXX addNMDAchannel XXXXXXXXXXXXXXXX"
*/
//  setfield {compPath}/{chanName} gmax {surf*gbar}
  setfield {compPath}/{chanpath} gmax {gbar}

  // WE NEED TO ADD CA DYNAMICS, use 10% of current to CaL buffer


 if ({isa dif_shell  {compPath}/{caBuffer}} )         // dif_shell 
  //    //echo spine calcium model is dif_shell
 addmsg {compPath}/{chanpath}/block {compPath}/{caBuffer} FINFLUX Ik 0.1
 
  elif ({isa Ca_concen {compPath}/{caBuffer}})      // Ca_conc
 //     //echo spine calcium model is Ca_conc
 addmsg {compPath}/{chanpath}/block {compPath}/{caBuffer} fI_Ca Ik 0.1
  end


end


function addSynChannel (compPath, chanpath, gbar)

  str compPath, chanpath
  float gbar

  copy /library/{chanpath} {compPath}/{chanpath}

  addmsg {compPath} {compPath}/{chanpath} VOLTAGE Vm
  addmsg {compPath}/{chanpath} {compPath} CHANNEL Gk Ek

  // Set the new conductance
  float len = {getfield {compPath} len}
  float dia = {getfield {compPath} dia}
  float pi = 3.141592653589793
  float surf = {len*dia*pi}

/*	//echo "XXXXXXXXXXXXXXX addSynChannel XXXXXXXXXXXXXXXX"
	//echo "compPath = "{compPath}
	//echo "chanpath = "{chanpath}
	//echo "gbar = "{gbar}
	//echo "XXXXXXXXXXXXXXX addSynchannel XXXXXXXXXXXXXXXX"
*/

//  setfield {compPath}/{chanName} gmax {surf*gbar}
  setfield {compPath}/{chanpath} gmax {gbar}
end
 
function add_Rand_exSynapse_evenly(cellpath,a,b,spine_density,exSyn_name,filepath)
// number: num of AMPA/NMDA per compartment
// spiketrain: name for all spike generators 
str cellpath,compt,compt2,NMDAname,AMPAname,spikegen,spiketrain,new_spiketrain,NMDA,AMPA,filepath,fname,exSyn_name
float a,b,position,len,spine_density,delaytime
int number,i,method,j,k  // 

float maxtime = 5.0   // maxim time of the duration for the input spike train

str NMDAname  =  "NMDA_channel_GHKCa"
str AMPAname  =  "AMPA_channel_GHKCa"


//float AMPAcond = 80e-12
//float NMDAcond = 220e-12
//float AMPAcond = 470e-12
//float NMDAcond = 170e-12


str buffer1 = "Ca_difshell_1"           // name of the calcium pool in the spine
str buffer2   = "Ca_difshell_2" 
str buffer3 = "Ca_difshell_3"          // only to record NMDA-dependent [Ca]

if (!{ exists /spikes})
	create neutral /spikes
end

spiketrain = "/spikes/"@{exSyn_name}

if (!{ exists {spiketrain}})
	create neutral {spiketrain}
end


j = 21 // spike train

k=1

foreach compt ({el {cellpath}/##[TYPE=compartment]})
    position={getfield {compt} position}
    len      ={getfield {compt} len}  
    number   = len*1e6*spine_density 
     compt2 = {getpath {compt} -tail}
    //if({number<1})
    //   number = 1 
    // end                 // make sure at least one synapse per compartment 

 
    if ({position>=a} && {position<b} ) 
    
   for(i=1;i<=number;i=i+1)


  new_spiketrain = {spiketrain}@"/"@{i}@"_"@{compt2}
  //  //echo the spiketrain is {new_spiketrain} and the existence is { exists {new_spiketrain}}
  //new_spiketrain = {spiketrain}@"/"@{k}

 fname = {filepath}@"-"@{j}
 // it is a bit complicated here: 
 // we need to check the existence of the spikegen first
   if (!{ exists {new_spiketrain}})
      create timetable {new_spiketrain}
       k=k+1
     ////echo create {new_spiketrain}
      setfield {new_spiketrain} maxtime {maxtime} method 4 act_val 1.0 fname {fname}
      // setfield {new_spiketrain} maxtime 1.0 method 1 meth_desc1 0.02  /*test only*/
      call {new_spiketrain} TABFILL
     spikegen = {new_spiketrain}@"/spike"
     create spikegen {spikegen}
     setfield {spikegen} output_amp 1 thresh 0.5 abs_refract 0.0001
        addmsg {new_spiketrain} {spikegen} INPUT activation
     NMDA   = {exSyn_name}@"_"@{NMDAname}@"_"@{i}
     AMPA   = {exSyn_name}@"_"@{AMPAname}@"_"@{i}
     if({!{ exists {compt}/{AMPA}}})
     addAMPAchannelGHKCa  {compt} {AMPAname} {AMPA} {buffer1} {AMPAcond}
     end
      if({!{ exists {compt}/{NMDA}}})
     addNMDAchannelGHKCa  {compt}  {NMDAname} {NMDA} {buffer1} {NMDAcond}
      end
        addmsg {spikegen} {compt}/{NMDA} SPIKE
        addmsg {spikegen} {compt}/{AMPA} SPIKE
 else 
   ////echo the {new_spiketrain} already existed!
   ////echo {showfield {new_spiketrain} fname} and new file is {fname} 
   setfield {new_spiketrain} method 4   // need to change it back
   setfield {new_spiketrain} fname {fname}
   call {new_spiketrain} TABFILL
  end 
  //setfield {new_spiketrain} method 1  // we "cheat" here :-)
  //call {new_spiketrain} TUPDATE 2 0.0 {delaytime} 10000.0   // this means from 0-0.5, there would be NO synaptic inputs since the isi is very big
    j=j+1
   end    // end of for...

   end // end of if({position>=a} && {position<b} ) 

end    // end of foreach...

//echo the sum of all exsyn {exSyn_name} is {k}

end 



/******** add clustered random synapses to the compartments of interest*************************/
function add_Rand_ClusterExSynapse(cellpath,compt_list,spine_density,filepath, exSyn_name , mode, maxnum,j)
// number: num of AMPA/NMDA per compartment
// mode: "0", all synapses receiving the same random input; "1", receiving different random inputs
str cellpath,compt,NMDAname,AMPAname,spikegen,spiketrain,new_spiketrain,NMDA,AMPA,filepath,fname,compt_list,exSyn_name,compt2
float a,b,position,len,spine_density
int number,i,method,j, mode,maxnum,k  // 

str NMDAname  =  "NMDA_channel_GHKCa"
str AMPAname  =  "AMPA_channel_GHKCa"

//float AMPAcond = 170e-12
//float NMDAcond = 470e-12

//float AMPAcond = 80e-12
//float NMDAcond = 220e-12

str buffer1 = "Ca_difshell_1"           // name of the calcium pool in the spine


if (!{ exists /spikes})
	create neutral /spikes
end

spiketrain = "/spikes/"@{exSyn_name}

if (!{ exists {spiketrain}})
	create neutral {spiketrain}
end






//j = 20 // spike train
k=1

int k2 = 1

int all_num = 0 

foreach compt ({arglist {compt_list}})
    compt    = {cellpath}@"/"@{compt}                           
    position ={getfield {compt} position} 
    len      ={getfield {compt} len}  
    number   = len*1e6*spine_density 
    compt2 = {getpath {compt} -tail}
    
   for(i=1;i<=number;i=i+1)
   new_spiketrain = {spiketrain}@"/"@{i}@"_"@{compt2}   // note: there is a bug in  the GENESIS
                                                       // the command "exists" can not compare two strings like" a[3]_1" and "a[3]_2" 
                                                       // so we have to name two strings like "1_a[3]" and "2_a[3]" to make them distinguished by "exists"
   //new_spiketrain = {spiketrain}@"/"@{k}
  //  //echo the spiketrain is {new_spiketrain} and the existence is { exists {new_spiketrain}}
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
 ////echo create {new_spiketrain}
 setfield {new_spiketrain} maxtime 5.0  method 4 act_val 1.0 fname {fname}
 ////echo the file name is {fname}
//setfield {new_spiketrain} maxtime 10.0 method 1 act_val 1.0 meth_desc1 0.2

// note: we need to set a delay here
 call {new_spiketrain} TABFILL
 spikegen = {new_spiketrain}@"/spike"
 create spikegen {spikegen}
 setfield {spikegen} output_amp 1 thresh 0.5 abs_refract 0.0001
 addmsg {new_spiketrain} {spikegen} INPUT activation
     NMDA   = {exSyn_name}@"_"@{NMDAname}@"_"@{i}
     AMPA   = {exSyn_name}@"_"@{AMPAname}@"_"@{i}
     if({!{ exists {compt}/{AMPA}}})
     addAMPAchannelGHKCa  {compt} {AMPAname} {AMPA} {buffer1} {AMPAcond3}
     end
      if({!{ exists {compt}/{NMDA}}})
     addNMDAchannelGHKCa  {compt}  {NMDAname} {NMDA} {buffer1} {NMDAcond3}
      end
        addmsg {spikegen} {compt}/{NMDA} SPIKE
        addmsg {spikegen} {compt}/{AMPA} SPIKE
     
  else           // if (!{ exists {new_spiketrain}}).....
   k2=k2+1
   ////echo {new_spiketrain} has existed!
   setfield {new_spiketrain} method 4   // need to change it back
   setfield {new_spiketrain} fname {fname}                     
   call {new_spiketrain} TABFILL
  end // end for if (!{ exists...

  all_num = all_num+1
 end   // end of "if all_num....
   end    // end of "for...

end    // end of "foreach...

//echo the sum of the clustered exsyn {exSyn_name} is {k}
//echo the sum of existed clustered exsyn {exSyn_name} is {k2}

end 









/******** add clustered random synapses to the compartments of interest*************************/
function add_Rand_NewClusterExSynapse(cellpath,compt_list,spine_density,filepath, exSyn_name , NMDAcond, AMPAcond, mode, maxnum,j)
// number: num of AMPA/NMDA per compartment
// mode: "0", all synapses receiving the same random input; "1", receiving different random inputs
str cellpath,compt,NMDAname,AMPAname,spikegen,spiketrain,new_spiketrain,NMDA,AMPA,filepath,fname,compt_list,exSyn_name,compt2
float a,b,position,len,spine_density
int number,i,method,j, mode,maxnum,k  // 

str NMDAname  =  "NMDA_channel_GHKCa"
str AMPAname  =  "AMPA_channel_GHKCa"

//float AMPAcond = 170e-12
//float NMDAcond = 470e-12

//float AMPAcond = 80e-12
//float NMDAcond = 220e-12

str buffer1 = "Ca_difshell_1"           // name of the calcium pool in the spine


if (!{ exists /spikes})
	create neutral /spikes
end

spiketrain = "/spikes/"@{exSyn_name}

if (!{ exists {spiketrain}})
	create neutral {spiketrain}
end






//j = 20 // spike train
k=1

int k2 = 1

int all_num = 0 

foreach compt ({arglist {compt_list}})
    compt    = {cellpath}@"/"@{compt}                           
    position ={getfield {compt} position} 
    len      ={getfield {compt} len}  
    //number   = len*1e6*spine_density 
    number = spine_density
    compt2 = {getpath {compt} -tail}
    
   for(i=1;i<=number;i=i+1)
   new_spiketrain = {spiketrain}@"/"@{i}@"_"@{compt2}   // note: there is a bug in  the GENESIS
                                                       // the command "exists" can not compare two strings like" a[3]_1" and "a[3]_2" 
                                                       // so we have to name two strings like "1_a[3]" and "2_a[3]" to make them distinguished by "exists"
   //new_spiketrain = {spiketrain}@"/"@{k}
  //  //echo the spiketrain is {new_spiketrain} and the existence is { exists {new_spiketrain}}
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
 ////echo create {new_spiketrain}
 setfield {new_spiketrain} maxtime 5.0  method 4 act_val 1.0 fname {fname}
 //echo the file name is {fname}
//setfield {new_spiketrain} maxtime 10.0 method 1 act_val 1.0 meth_desc1 0.2

// note: we need to set a delay here
 call {new_spiketrain} TABFILL
 spikegen = {new_spiketrain}@"/spike"
 create spikegen {spikegen}
 setfield {spikegen} output_amp 1 thresh 0.5 abs_refract 0.0001
 addmsg {new_spiketrain} {spikegen} INPUT activation
     NMDA   = {exSyn_name}@"_"@{NMDAname}@"_"@{i}
     AMPA   = {exSyn_name}@"_"@{AMPAname}@"_"@{i}
     if({!{ exists {compt}/{AMPA}}})
     addAMPAchannelGHKCa  {compt} {AMPAname} {AMPA} {buffer1} {AMPAcond}
     end
      if({!{ exists {compt}/{NMDA}}})
     addNMDAchannelGHKCa  {compt}  {NMDAname} {NMDA} {buffer1} {NMDAcond}
      end
        addmsg {spikegen} {compt}/{NMDA} SPIKE
        addmsg {spikegen} {compt}/{AMPA} SPIKE
     
  else           // if (!{ exists {new_spiketrain}}).....
   k2=k2+1
   ////echo {new_spiketrain} has existed!
   setfield {new_spiketrain} method 4   // need to change it back
   setfield {new_spiketrain} fname {fname}                     
   call {new_spiketrain} TABFILL
  end // end for if (!{ exists...

  all_num = all_num+1
 end   // end of "if all_num....
   end    // end of "for...

end    // end of "foreach...

//echo the sum of the clustered exsyn {exSyn_name} is {k}
//echo the sum of existed clustered exsyn {exSyn_name} is {k2}

end 















/******** add clustered random synapses to the compartments of interest*************************/
function add_Rand_ClusterAMPA(cellpath,compt_list,spine_density,filepath, exSyn_name , mode, maxnum,j)
// number: num of AMPA  per compartment
// mode: "0", all synapses receiving the same random input; "1", receiving different random inputs
str cellpath,compt,NMDAname,AMPAname,spikegen,spiketrain,new_spiketrain,NMDA,AMPA,filepath,fname,compt_list,exSyn_name,compt2
float a,b,position,len,spine_density
int number,i,method,j, mode,maxnum,k  // 

str AMPAname  =  "AMPA2_channel_GHKCa"


str buffer1 = "Ca_difshell_1"           // name of the calcium pool in the spine


float tau1_AMPA2 = 1e-3
float tau2_AMPA2 = 5e-3

if (!{ exists /spikes})
	create neutral /spikes
end

spiketrain = "/spikes/"@{exSyn_name}

if (!{ exists {spiketrain}})
	create neutral {spiketrain}
end


//j = 20 // spike train
k=1

int all_num = 0 

foreach compt ({arglist {compt_list}})
    compt    = {cellpath}@"/"@{compt}                           
    position ={getfield {compt} position} 
    len      ={getfield {compt} len}  
    number   = len*1e6*spine_density 
    compt2 = {getpath {compt} -tail}
    
   for(i=1;i<=number;i=i+1)
   new_spiketrain = {spiketrain}@"/"@{i}@"_"@{compt2}   // note: there is a bug in  the GENESIS
                                                       // the command "exists" can not compare two strings like" a[3]_1" and "a[3]_2" 
                                                       // so we have to name two strings like "1_a[3]" and "2_a[3]" to make them distinguished by "exists"
  //new_spiketrain = {spiketrain}@"/"@{k}
  //  //echo the spiketrain is {new_spiketrain} and the existence is { exists {new_spiketrain}}
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
 //echo create {new_spiketrain}
 setfield {new_spiketrain} maxtime 5.0  method 4 act_val 1.0 fname {fname}
 //echo the file name is {fname}
//setfield {new_spiketrain} maxtime 10.0 method 1 act_val 1.0 meth_desc1 0.2






// note: we need to set a delay here
 call {new_spiketrain} TABFILL
 spikegen = {new_spiketrain}@"/spike"
 create spikegen {spikegen}
 setfield {spikegen} output_amp 1 thresh 0.5 abs_refract 0.0001
 addmsg {new_spiketrain} {spikegen} INPUT activation
     AMPA   = {exSyn_name}@"_"@{AMPAname}@"_"@{i}
     if({!{ exists {compt}/{AMPA}}})
     addAMPAchannelGHKCa  {compt}  {AMPAname} {AMPA} {buffer1} {AMPAcond3}
     end
        addmsg {spikegen} {compt}/{AMPA} SPIKE
        setfield {compt}/{AMPA} tau1 {tau1_AMPA2} tau2 {tau2_AMPA2}
     
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



















function add_tonicGABA_evenly(cellpath,a,b,number,filepath)
// number: num of AMPA/NMDA per compartment
str cellpath,compt,spikegen,spikegen,spiketrain,new_spiketrain,filepath,filename,tGABA
float a,b,position
int number,i,method,j  // 


float GABAcond = 90e-12 // single gaba channel recording, Ade,et.al 2008
str GABAname = "tGABA"

if ({exists /spikes})
 delete /spikes
 reclaim
end

  create neutral /spikes


if (!{ exists /tGABAs})
	create neutral /tGABAs
else
       delete /tGABAs
       reclaim
       create neutral /tGABAs

end


spiketrain = "/spikes/input_train"

j = 20 // spike train

foreach compt ({el {cellpath}/##[TYPE=compartment]})
    position={getfield {compt} position} 
    if ({position>=a} && {position<b} ) 
    
   for(i=1;i<=number;i=i+1)
 new_spiketrain = {spiketrain}@"_"@{j}
 filename = {filepath}@"-"@{j}
 j=j+1
 create timetable {new_spiketrain}
 ////echo create {new_spiketrain}
// setfield {new_spiketrain} maxtime 10.0 method {method} act_val 1.0 meth_desc1 {interval}
 setfield {new_spiketrain} maxtime 10.0 method 4 act_val 1.0 fname {filename}
 call {new_spiketrain} TABFILL
 spikegen = {new_spiketrain}@"/spike"
 create spikegen {spikegen}
 setfield {spikegen} output_amp 1 thresh 0.5 abs_refract 0.0001
 addmsg {new_spiketrain} {spikegen} INPUT activation
/*****************************************************************************************/
  tGABA   = {GABAname}@"_"@{j}
  copy /library/MSsynaptic/GABA_channel /tGABAs/{tGABA}

  setfield /tGABAs/{tGABA} gmax {GABAcond}
     addmsg {compt} /tGABAs/{tGABA} VOLTAGE Vm
     addmsg /tGABAs/{tGABA} {compt} CHANNEL Gk Ek 
   if({exists {spikegen}  })
        addmsg {spikegen} /tGABAs/{tGABA} SPIKE
   end  // end of if ({exists {spikegen}  }) 
   end    // end of for...

   end // end of if({position>=a} && {position<b} ) 

 end    // end of foreach...

end



function add_Rand_ClusterGABA(cellpath,list,syn_density,filepath,GABAtype,GABAname,GABAcond, j)
// number: num of AMPA/NMDA per compartment
str cellpath,compt,spikegen,spikegen,spiketrain,new_spiketrain,filepath,filename,GABA,GABAname,list,GABAtype,compt2
float GABAcond,position,syn_density,len
int number,i,method,j,num  // 

if (!{exists /spikes})
 create neutral /spikes
end



if (!{ exists /GABAs})
	create neutral /GABAs

end

spiketrain = "/spikes/"@{GABAname}
//spiketrain = "/spikes/GABA_input_train"

if (!{ exists {spiketrain}})
	create neutral {spiketrain}
end



num = 1


//j = 20 // spike train

foreach compt ({arglist {list}})
    compt    = {cellpath}@"/"@{compt}
    position={getfield {compt} position} 
    len      ={getfield {compt} len}  
    number = syn_density
    compt2 = {getpath {compt} -tail}
    //number   = len*1e6*syn_density 
    //if ({position>=a} && {position<b} ) 
    
   for(i=1;i<=number;i=i+1)
 //new_spiketrain = {spiketrain}@"_"@{num}
 new_spiketrain = {spiketrain}@"/"@{i}@"_"@{compt2}
 filename = {filepath}@"-"@{j}
 j=j+1
 num = num+1

  if (!{ exists {new_spiketrain}})

 create timetable {new_spiketrain}
 //echo create {new_spiketrain}
// setfield {new_spiketrain} maxtime 10.0 method {method} act_val 1.0 meth_desc1 {interval}
 setfield {new_spiketrain} maxtime 10.0 method 4 act_val 1.0 fname {filename}
 call {new_spiketrain} TABFILL
 spikegen = {new_spiketrain}@"/spike"
 create spikegen {spikegen}
 setfield {spikegen} output_amp 1 thresh 0.5 abs_refract 0.0001
 addmsg {new_spiketrain} {spikegen} INPUT activation
/*****************************************************************************************/
  GABA   = {GABAname}@"_"@{i}
  if(!{exists {compt}/{GABA}} )
  copy /library/MSsynaptic/{GABAtype} {compt}/{GABA}
  end

  setfield {compt}/{GABA} gmax {GABAcond}

    // to get a fixed driving force, "pseudoGABA_channel" does not communicate to its parent compartment 
     if (!{{strcmp "pseudoGABA_channel" {GABAtype}} == 0 } )
     addmsg {compt} {compt}/{GABA} VOLTAGE Vm
     addmsg {compt}/{GABA} {compt} CHANNEL Gk Ek 
     else 
     addmsg {compt}/{GABA} {compt} INJECT Ik 

    end 

     
   if({exists {spikegen}  })
        addmsg {spikegen} {compt}/{GABA} SPIKE
   end// end of if ({exists {spikegen}  }) 

    else //  (!{ exists {new_spiketrain}}).....
   //echo {new_spiketrain} has existed!!
   setfield {new_spiketrain} method 4  
    setfield {new_spiketrain} fname {filename}                     
     call {new_spiketrain} TABFILL
    end   // end of if (!{ exists .....



   end    // end of for...

 //  end // end of if({position>=a} && {position<b} ) 

 end    // end of foreach...

end




function add_RandGABA_evenly(cellpath,a,b,density,filepath,GABAname,GABAcond, j)
// number: num of AMPA/NMDA per compartment
str cellpath,compt,spikegen,spikegen,spiketrain,new_spiketrain,filepath,filename,GABA,GABAname,compt2
float a,b,GABAcond,position,number ,density,len
int i,method,j,num  // 

if (!{exists /spikes})
 create neutral /spikes
end


if (!{ exists /GABAs})
	create neutral /GABAs
else
       delete /GABAs
       reclaim
       create neutral /GABAs

end


spiketrain = "/spikes/GABA_input_train"

if (!{ exists {spiketrain}})
	create neutral {spiketrain}
end

//j = 20 // spike train

foreach compt ({el {cellpath}/##[TYPE=compartment]})
   // //echo compt is {compt}
    position={getfield {compt} position} 
    len      ={getfield {compt} len}  
    number   = len*1e6*density 
    compt2 = {getpath {compt} -tail}
    if ({position>=a} && {position<b} ) 
    
   for(i=1;i<=number;i=i+1)
// new_spiketrain = {spiketrain}@"_"@{num}
new_spiketrain = {spiketrain}@"/"@{i}@"_"@{compt2}

 filename = {filepath}@"-"@{j}
 j=j+1
 num = num+1
 if (!{ exists {new_spiketrain}})
 create timetable {new_spiketrain}
 ////echo create {new_spiketrain}
// setfield {new_spiketrain} maxtime 10.0 method {method} act_val 1.0 meth_desc1 {interval}
 setfield {new_spiketrain} maxtime 10.0 method 4 act_val 1.0 fname {filename}
 call {new_spiketrain} TABFILL
 spikegen = {new_spiketrain}@"/spike"
 create spikegen {spikegen}
 setfield {spikegen} output_amp 1 thresh 0.5 abs_refract 0.0001
 addmsg {new_spiketrain} {spikegen} INPUT activation
/*****************************************************************************************/
  GABA   = {GABAname}@"_"@{j}
  copy /library/MSsynaptic/GABA_channel {compt}/{GABA}

  setfield {compt}/{GABA} gmax {GABAcond}
     addmsg {compt} {compt}/{GABA} VOLTAGE Vm
     addmsg {compt}/{GABA} {compt} CHANNEL Gk Ek 
   if({exists {spikegen}  })
        addmsg {spikegen} {compt}/{GABA} SPIKE
   end  // end of if ({exists {spikegen}  }) 
   else 
   ////echo {new_spiketrain} has existed!!
   setfield {new_spiketrain} method 4  
    setfield {new_spiketrain} fname {filename}                     
     call {new_spiketrain} TABFILL
   end   // end of  if (!{ exists.....


   end    // end of for...

  end // end of if({position>=a} && {position<b} ) 

 end    // end of foreach...

end






function addAMPA2channel(compPath, gbar,num)

  str compPath, chanName,preSyn
  float gbar
  int i,num

 for(i=1;i<=num;i=i+1)
       preSyn   = "presyn"@{i}@"_ext2"
       chanName = "AMPA2"@"_"@{i}
       create neutral {compPath}/{preSyn}
       copy /library/MSsynaptic/AMPA2_channel {compPath}/{chanName}  // AMPA2-channel is a "mutant" version of GABA channel
                                                                     // i.e. only varied in Ek. 
       setfield {compPath}/{chanName} gmax {gbar}
       addmsg {compPath} {compPath}/{chanName} VOLTAGE Vm
       addmsg {compPath}/{chanName} {compPath} CHANNEL Gk Ek
       addmsg {compPath}/{preSyn}   {compPath}/{chanName} ACTIVATION z
      //echo Add  {compPath}/{preSyn} and  {compPath}/{chanName}
  end

end









function addGABAchannel(cellpath, list,GABAchanType,chanName,gbar,num)

  str compPath, chanName,preSyn,GABAchanType,cellpath,list,compt
  float gbar
  int i,num

foreach compt ({arglist {list}})
compPath = {cellpath}@"/"@{compt}
 for(i=1;i<=num;i=i+1)
       preSyn   = "presyn"@{i}@"_inh"
       create neutral {compPath}/{preSyn}
       copy /library/MSsynaptic/{GABAchanType} {compPath}/{chanName}"_"{i}
       setfield {compPath}/{chanName}"_"{i} gmax {gbar}
       // note!!!
       // for "pseudoGABA_channel", the driving force is *FIXED* 

     if (!{{strcmp "pseudoGABA_channel" {GABAchanType}} == 0 } )
    // echo this is NOT pseudoGABA 
     addmsg {compPath} {compPath}/{chanName}"_"{i} VOLTAGE Vm
      addmsg {compPath}/{chanName}"_"{i} {compPath} CHANNEL Gk Ek
     else 
     //echo This is pseudoGABA 
     addmsg {compPath}/{chanName}"_"{i} {compPath} INJECT Ik 

    end 

       addmsg {compPath}/{preSyn}   {compPath}/{chanName}"_"{i} ACTIVATION z
      //echo Add  {compPath}/{preSyn} and  {compPath}/{chanName}"_"{i}
  end
end   // end of foreach....
end


function addGABAchannel_NoPreSyn(cellpath, list,GABAchanType,chanName,gbar,num)

  str compPath, chanName,preSyn,GABAchanType,cellpath,list,compt
  float gbar
  int i,num

foreach compt ({arglist {list}})
compPath = {cellpath}@"/"@{compt}
 for(i=1;i<=num;i=i+1)
       //preSyn   = "presyn"@{i}@"_inh"
       //create neutral {compPath}/{preSyn}
       copy /library/MSsynaptic/{GABAchanType} {compPath}/{chanName}"_"{i}
       setfield {compPath}/{chanName}"_"{i} gmax {gbar}
       // note!!!
       // for "pseudoGABA_channel", the driving force is *FIXED* 

     if (!{{strcmp "pseudoGABA_channel" {GABAchanType}} == 0 } )
    // echo this is NOT pseudoGABA 
     addmsg {compPath} {compPath}/{chanName}"_"{i} VOLTAGE Vm
      addmsg {compPath}/{chanName}"_"{i} {compPath} CHANNEL Gk Ek
     else 
     //echo This is pseudoGABA 
     addmsg {compPath}/{chanName}"_"{i} {compPath} INJECT Ik 

    end 

      // addmsg {compPath}/{preSyn}   {compPath}/{chanName}"_"{i} ACTIVATION z
      //echo Add  {compPath}/{preSyn} and  {compPath}/{chanName}"_"{i}
  end
end   // end of foreach....
end



function activateGABAchannels(cellpath,list,num,ISI) 
str compPath, chanName,preSyn,GABAchanType,cellpath,list,compt
float ISI
int i,num
foreach compt ({arglist {list}})
   compPath = {cellpath}@"/"@{compt}
   for(i=1;i<=num;i=i+1)
       preSyn   = "presyn"@{i}@"_inh"
       setfield {compPath}/{preSyn} z {1/{getclock 0}}
       step 1 
       setfield {compPath}/{preSyn} z 0
       step {ISI} -time
       //echo Activating {compPath}/{preSyn} now!  
   end
end  // end of foreach....
end




function addExtSynapses(cellpath, list,chanName,gbar_NMDA,gbar_AMPA,num)

  str compPath, chanName,preSyn,AMPAchanType,cellpath,list,compt
  float gbar_NMDA,gbar_AMPA
  int i,num

str NMDAname  =  "NMDA_channel_GHKCa"
str AMPAname  =  "AMPA_channel_GHKCa"

str buffer1 = "Ca_difshell_1"           // name of the calcium pool in the spine
str buffer2   = "Ca_difshell_2" 
str buffer3 = "Ca_difshell_3"          // only to record NMDA-dependent [Ca]


foreach compt ({arglist {list}})
compPath = {cellpath}@"/"@{compt}
 for(i=1;i<=num;i=i+1)
       preSyn   = "presyn"@{i}@"_ext"
       create neutral {compPath}/{preSyn}
     if({!{ exists {compPath}/{chanName}"_AMPA_"{i}}})
        addAMPAchannelGHKCa  {compPath} {AMPAname} {chanName}"_AMPA_"{i} {buffer1} {gbar_AMPA}
     end
      if({!{ exists {compPath}/{chanName}"_NMDA_"{i}}})
         addNMDAchannelGHKCa  {compPath}  {NMDAname} {chanName}"_NMDA_"{i} {buffer1} {gbar_NMDA}
      end
       addmsg {compPath}/{preSyn}   {compPath}/{chanName}"_AMPA_"{i} ACTIVATION z
       addmsg {compPath}/{preSyn}   {compPath}/{chanName}"_NMDA_"{i} ACTIVATION z
      //echo Add  {compPath}/{preSyn} 
  end
end   // end of foreach....
end


function addExtSynapses_0Mg(cellpath, list,chanName,gbar_NMDA,gbar_AMPA,num)

  str compPath, chanName,preSyn,AMPAchanType,cellpath,list,compt
  float gbar_NMDA,gbar_AMPA
  int i,num

str NMDAname  =  "NMDA_channel_GHKCa"
str AMPAname  =  "AMPA_channel_GHKCa"

str buffer1 = "Ca_difshell_1"           // name of the calcium pool in the spine
str buffer2   = "Ca_difshell_2" 
str buffer3 = "Ca_difshell_3"          // only to record NMDA-dependent [Ca]


foreach compt ({arglist {list}})
compPath = {cellpath}@"/"@{compt}
 for(i=1;i<=num;i=i+1)
       preSyn   = "presyn"@{i}@"_ext"
       create neutral {compPath}/{preSyn}
     if({!{ exists {compPath}/{chanName}"_AMPA_"{i}}})
        addAMPAchannelGHKCa  {compPath} {AMPAname} {chanName}"_AMPA_"{i} {buffer1} {gbar_AMPA}
     end
      if({!{ exists {compPath}/{chanName}"_NMDA_"{i}}})
         addNMDAchannelGHKCa  {compPath}  {NMDAname} {chanName}"_NMDA_"{i} {buffer1} {gbar_NMDA}
         setfield {compPath}/{chanName}"_NMDA_"{i}/Mg_block_NMDA  CMg 0 
      end
       addmsg {compPath}/{preSyn}   {compPath}/{chanName}"_AMPA_"{i} ACTIVATION z
       addmsg {compPath}/{preSyn}   {compPath}/{chanName}"_NMDA_"{i} ACTIVATION z
      //echo Add  {compPath}/{preSyn} 
  end
end   // end of foreach....
end

function addExtSynapses_Mg(cellpath, list,chanName,gbar_NMDA,gbar_AMPA,num,CMg)

  str compPath, chanName,preSyn,AMPAchanType,cellpath,list,compt
  float gbar_NMDA,gbar_AMPA,CMg
  int i,num

str NMDAname  =  "NMDA_channel_GHKCa"
str AMPAname  =  "AMPA_channel_GHKCa"

str buffer1 = "Ca_difshell_1"           // name of the calcium pool in the spine
str buffer2   = "Ca_difshell_2" 
str buffer3 = "Ca_difshell_3"          // only to record NMDA-dependent [Ca]


foreach compt ({arglist {list}})
compPath = {cellpath}@"/"@{compt}
 for(i=1;i<=num;i=i+1)
       preSyn   = "presyn"@{i}@"_ext"
       create neutral {compPath}/{preSyn}
     if({!{ exists {compPath}/{chanName}"_AMPA_"{i}}})
        addAMPAchannelGHKCa  {compPath} {AMPAname} {chanName}"_AMPA_"{i} {buffer1} {gbar_AMPA}
     end
      if({!{ exists {compPath}/{chanName}"_NMDA_"{i}}})
         addNMDAchannelGHKCa  {compPath}  {NMDAname} {chanName}"_NMDA_"{i} {buffer1} {gbar_NMDA}
         setfield {compPath}/{chanName}"_NMDA_"{i}/Mg_block_NMDA  CMg {CMg}
      end
       addmsg {compPath}/{preSyn}   {compPath}/{chanName}"_AMPA_"{i} ACTIVATION z
       addmsg {compPath}/{preSyn}   {compPath}/{chanName}"_NMDA_"{i} ACTIVATION z
      //echo Add  {compPath}/{preSyn} 
  end
end   // end of foreach....
end

function activateExtSynchannels(cellpath,list,num,ISI) 
str compPath, chanName,preSyn,GABAchanType,cellpath,list,compt
float ISI
int i,num
foreach compt ({arglist {list}})
   compPath = {cellpath}@"/"@{compt}
   for(i=1;i<=num;i=i+1)
       preSyn   = "presyn"@{i}@"_ext"
       setfield {compPath}/{preSyn} z {1/{getclock 0}}
       step 1 
       setfield {compPath}/{preSyn} z 0
       step {ISI} -time
//echo Activating {compPath}/{preSyn} now!
   end
end  // end of foreach....
end



function findCompt(cellpath,a, b ,minLen)
float a,b,position,len, minLen
str cellpath, compt, list, temp

list = ""

foreach compt ({el {cellpath}/##[TYPE=compartment]})
  position = {getfield {compt} position} 
  len   = {getfield {compt} len}
  if ({{position >= a} && {position < b} && len>={minLen}}) 
      compt = {getpath {compt} -tail}
      list = {list}@" "@{compt}
  ////echo ""
 // //echo {compt}
 // //echo position: {position}  length: {len}

  end // end of if
 end  // end of foreach

////echo the compartments between {a} and {b} are 
////echo {list}
 
  return {list}

end




function findComptAtTheBranch( cellpath ,branch_name, a, b , minLen )
float a,b,position,len, minLen
str cellpath, compt, list, temp, branch_name, tmp

list = ""

int num = {strlen {branch_name} } 

foreach compt ({el {cellpath}/##[TYPE=compartment]})
  position = {getfield {compt} position} 
  len   = {getfield {compt} len} 
  compt = {getpath {compt} -tail}
  tmp = { substring {compt} 0 {{num}-1} }
  int indx = {{strcmp {branch_name} {tmp}} == 0}
 // //echo    {branch_name} {tmp}  {indx}  
  if ({{position >= a} && {position < b} && len>={minLen} && {strcmp {branch_name} {tmp}}==0}) 
      list = {list}@" "@{compt}
  ////echo ""
  // //echo {compt}
  // //echo position: {position}  length: {len}

  end // end of if
 end  // end of foreach

////echo the compartments between {a} and {b} are 
////echo {list}
 
  return {list}

end



function findComptAtTheBranch2(filepath,compt_initial, compt_end)
// compt_initial is the first compt in the branch  
int flag = 1 
int flag2 = 0
int num
str compt_initial, filepath, compt_1,compt_2,list,lines,compt_end

list =""
lines = ""

openfile {filepath} r

while (flag == 1 )
 lines = {readfile {filepath} -l}
 num = {getarg {arglist {lines}} -count}

 
 if (num>2)
 ////echo the current line is {lines}
 ////echo the num is {num}
 compt_1 = {getarg {arglist {lines}} -arg 1}  // the first collumn 
 compt_2 = {getarg {arglist {lines}} -arg 2}  // the second collumn 
 ////echo compt_1 is {compt_1} and compt_2 is {compt_2} 
 end

 if ({{strcmp {compt_1} {compt_initial}}==0} && {flag2 ==0} )           // find the first compartment in the branch 
  flag2 = 1
  //echo ============================
  //echo now start to add to list! 
  //echo ============================
 end  // end of if 

 //if({flag2 == 1} && {num==0} )  // this is another branch, so ends to read lines

 if ({{strcmp {compt_1} {compt_end}}==0})
 flag2 = 0
 flag = 0
 //echo ""
 //echo =====================
 //echo ends here!!
 //echo ======================
 end 

 if (flag2 == 1)
 list = {list}@" "@{compt_1}
 //echo add {compt_1} to the list
 end
 end // end of while

 
return {list}


closefile {filepath}

end



function makeRandList ( list, number) 
str list, list2, tmp
int number,num,num2,randnum

/*
str tt
float isi,x1,x2,x3
int x4
int new_seed
tt = { getarg {arglist {getdate}} -arg 4}  // using time for the random seeds
x1 = {substring {tt} 0 1}                  // hour;
x2 = {substring {tt} 3 4}                  // minute;
x3 = {substring {tt} 6 7}                  // second;
x4 = x1*x2*x3+ {pow {x1} 4} + {pow {x2} 4} + {pow {x3} 4}    // this formula is arbitrarily set to make a big but random number
new_seed = {rand 1 {x4}}
randseed {new_seed}
*/

list2 = ""

num = {getarg {arglist {list}}-count}

     while ({num>0} && {num2<number})
       randnum = {rand 1 {num}}  // generate a random (int) number
         tmp = {getarg {arglist {list}} -arg {randnum}}
        list2  = {list2}@" "@{tmp}
          ////echo the list2 is {list2} 
          list = {strsub {list} {tmp} ""}  // delete the one we used
           ////echo the list is {list}
          num = {getarg {arglist {list}} -count}    // update "num"
            num2 = {getarg {arglist {list2}}   -count} 
            //  //echo the num2 is {num2}
      end   // end of while

  return {list2}


end // end of function


// romove list2 from list1
function rmList(list1,list2)
str list1,list2,tmp
int i,num1,num2
num2 = {getarg {arglist {list2}}-count}

for(i=1;i<=num2;i=i+1)
tmp = {getarg {arglist {list2}} -arg {i}}
list1 = {strsub {list1} {tmp} ""}       // delete the same string from "list2"

end
return {list1}
end







/*********************************************************************************/
// taken from Alex's code
function Make_integr_syn (compart, synchannel, ek, gmax, tau1, tau2, dur,delay1)
   str compart, synchannel
   float ek, gmax, tau1, tau2, dur,delay1
   float xmin, xmax
   int   xdivs 
   float rho={1/tau2}, sig={1/tau1}
   float x,dx,y,z 
   int   i 

   // Strob signal of duration {dur} for each incoming spike event
   create pulsegen {compart}/{synchannel}
   setfield {compart}/{synchannel} width1 {dur} level1 1 trig_mode 0  delay1 {delay1}

   // Integration of synaptic inputs
   pushe {compart}/{synchannel}
      create tabchannel integr
      setfield           ^          \
         Ek              0          \
         Gbar            1          \
         Xpower          0          \
         Ypower          0          \
         Zpower          1  

      xmin  = -.1
      xmax  = 1.1
      xdivs = 10 

      call integr TABCREATE Z {xdivs} {xmin} {xmax}

      dx = (xmax - xmin)/xdivs 
      x = xmin 
      for (i = 0 ; i <= {xdivs} ; i = i + 1) 
         y = rho*x
         z = (rho-sig)*x+sig
         setfield integr Z_A->table[{i}] {y}
         setfield integr Z_B->table[{i}] {z}
         x = x + dx 
      end 
   pope

   // Synaptic channel
   pushe {compart}/{synchannel}
      create vdep_channel out 
      setfield out Ek {ek} gbar {gmax} 
   pope

   // Linking synapse to postsynaptic compartment
   addmsg {compart} {compart}/{synchannel}/integr VOLTAGE Vm

   addmsg {compart} {compart}/{synchannel}/out VOLTAGE Vm
   addmsg {compart}/{synchannel}/out {compart} CHANNEL Gk Ek

   pushe {compart}/{synchannel}
      addmsg ./ integr CONCEN output
      addmsg integr out MULTGATE Gk 1
   pope
end

// ---
// --- NMDA Synapse: input integration, Mg block, [Ca], K(Ca) channel
// ---



// function makeDynamicSyn(path,spikegen,syn,syn_type,num_syn,filepath,j0)
// str path,syn_type,filepath,syn,spikegen,new_spikegen
// int num,num_syn,i,j0,num2,k,nn
// float activation,tt,tmin,tmax,tt1,dt
// tmin =0;tmax=1
// dt = {getclock 0}
// int num = (tmax-tmin)/dt

// //pushe {path}

// if({!{exists /FSsyn }})
//  create neutral /FSsyn
// end

// for(i=1;i<=num_syn;i=i+1)
// new_spikegen = "/FSsyn/"@{spikegen}@"_"@{i}
// //echo spigen is {new_spikegen}
// if({!{exists {new_spikegen} }})
// //echo j0 is {j0} and creat the spikegen {new_spikegen} now!!
// create table {new_spikegen}
// else
// //echo j0 is {j0} and the spikegen {new_spikegen} has existed!!
// call {new_spikegen} TABCREATE 1 0 0   // to *clear* existed table
// end

// setfield {new_spikegen} step_mode 2 stepsize 0        // we use simulation time for lookup
// call {new_spikegen} TABCREATE {num} {tmin} {tmax}
// deletemsg {path}/{syn}"_"{i}  0 -in     // NOTE:should delete the previous "activation" msg first!!
// addmsg {new_spikegen} {path}/{syn}"_"{i} ACTIVATION output

// openfile {filepath}/"noise-gate-totalnumber-"{(j0+i)} r       // number of spikes
// openfile {filepath}/"noise-gate-"{syn_type}"-"{(j0+i)} r      // spike modulation
// openfile {filepath}/"noise-gate-"{(j0+i)} r                   // spike timings
// //echo gaba {path}/{syn}"_"{i} is now using the file "noise-gate-"{(j0+i)}
 
// num2 = {readfile {filepath}/"noise-gate-totalnumber-"{(j0+i)} } 
// closefile  {filepath}/"noise-gate-totalnumber-"{(j0+i)}
// for(k=1;k<=num2;k=k+1)
// tt1 = {readfile {filepath}/"noise-gate-"{(j0+i)} }
// activation =  {readfile {filepath}/"noise-gate-"{syn_type}"-"{(j0+i)} }      

// nn = tt1/dt
// setfield {new_spikegen} table->table[{nn}] {activation/{getclock 0}}
// end 
// closefile {filepath}/"noise-gate-"{syn_type}"-"{(j0+i)}
// closefile {filepath}/"noise-gate-"{(j0+i)} 
// end

// //pope

// end



function findActivatedRandSyn(spikePath,tmin,tmax)
str spikePath,path1,line1,fname,spkgen,compt,list
float t1,t2,tt,dt1,dt2,tmin,tmax
int len
 list =""
foreach path1 ({el {spikePath}/#})
 fname = {getfield {path1} fname}
 ////echo {fname}
 openfile {fname} r
 line1="0"    // non-empty
 while({strlen {line1}}>0)
  line1 = {readfile {fname} }
  ////echo {line1}
  if({strlen {line1}}>0)
   tt = {arglist {line1}} 
  if (tt>=tmin && tt<=tmax)
   spkgen = {getpath {path1} -tail }
   compt = {substring {spkgen} 2}    // the spkgen is always like this "1_739"; "739" is the compartment we want.
   ////echo compt is {compt}
   ////echo the old list is {list}
   list = {list}@" "@{compt}
   ////echo the new list is {list}
   end    // end of if...
  end     // end of if...
  end    // end of while
  closefile {fname}
 end    // end of foreach
 return {list}
end



function makeDynamicSyn(path,spikegen,syn,syn_type,num_syn,filepath,j0)
str path,syn_type,filepath,syn,spikegen,new_spikegen
int num,num_syn,i,j0,num2,k,nn
float activation,tt,tmin,tmax,tt1,dt
tmin =0.4;tmax=1
dt = {getclock 0}
int num = (tmax-tmin)/dt

//pushe {path}

if({!{exists /FSsyn }})
 create neutral /FSsyn
end

for(i=1;i<=num_syn;i=i+1)
new_spikegen = "/FSsyn/"@{spikegen}@"_"@{i}
//echo spigen is {new_spikegen}
if({!{exists {new_spikegen} }})
//echo j0 is {j0} and creat the spikegen {new_spikegen} now!!
create table {new_spikegen}
else
//echo j0 is {j0} and the spikegen {new_spikegen} has existed!!
call {new_spikegen} TABCREATE 1 0 0   // to *clear* existed table
end

setfield {new_spikegen} step_mode 2 stepsize 0        // we use simulation time for lookup
call {new_spikegen} TABCREATE {num} {tmin} {tmax}
deletemsg {path}/{syn}"_"{i}  0 -in     // NOTE:should delete the previous "activation" msg first!!
addmsg {new_spikegen} {path}/{syn}"_"{i} ACTIVATION output

openfile {filepath}/"noise-gate-totalnumber-"{(j0+i)} r       // number of spikes
openfile {filepath}/"noise-gate-"{syn_type}"-"{(j0+i)} r      // spike modulation
openfile {filepath}/"noise-gate-"{(j0+i)} r                   // spike timings
// //echo gaba {path}/{syn}"_"{i} is now using the file "noise-gate-"{(j0+i)}
 
 num2 = {readfile {filepath}/"noise-gate-totalnumber-"{(j0+i)} } 
 closefile  {filepath}/"noise-gate-totalnumber-"{(j0+i)}

for(k=1;k<=num2;k=k+1)
tt1 = {readfile {filepath}/"noise-gate-"{(j0+i)} }
tt1 = tt1 - tmin
activation =  {readfile {filepath}/"noise-gate-"{syn_type}"-"{(j0+i)} }      
nn = tt1/dt
//echo@0 set table  at {mynode} and nn is {nn}
setfield {new_spikegen} table->table[{nn}] {activation/{getclock 0}}


end

closefile {filepath}/"noise-gate-"{syn_type}"-"{(j0+i)}
closefile {filepath}/"noise-gate-"{(j0+i)}

end

//pope

end
