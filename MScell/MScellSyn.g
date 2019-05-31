//genesis
//MScellSyn.g
//This routine takes the MScell without synapses, and adds synapses

include MScell/MScell.g                 //MScell without synapses
include MScell/SynParams.g               //parameters on synaptic channels
include MScell/channels/nmda_channel.g   //function to make nmda channel, either GHK or not, in library
include MScell/channels/synaptic_channel.g // function to make non nmda synaptic channels in library
include MScell/AddSynapticChannels.g	// contains functions to add channels to compartments

function makeMScellSyn (cellname,pfile)
   str cellname,pfile

   str CompName

   make_MS_cell {cellname} {pfile}

	//************* create synaptic channels in library *********
	pushe /library

  	make_synaptic_channel  {AMPAname} {AMPAtau1} {AMPAtau2} {AMPAgmax} {EkAMPA}
  	make_NMDA_channel    {NMDAname} {EkNMDA} {Kmg} {NMDAtau2} {NMDAgmax} {ghk_yesno}
	make_synaptic_channel  {GABAname} {GABAtau1} {GABAtau2} {GABAgmax} {EkGABA}

        pope {cellname}
	
   //********************* end synaptic channels in library **************

      foreach CompName ({el {cellname}/##[TYPE=compartment]}) 
        addNMDAchannel {CompName} {NMDAname} {CA_BUFF_3} {NMDAgmax} {ghk_yesno}
        addSynChannel  {CompName} {AMPAname} {AMPAgmax}
        addSynChannel  {CompName} {GABAname} {GABAgmax}
      end


end
