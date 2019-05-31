//genesis

/***************************		MS Model, Version 5.12	**********************
**************************** 	      	proto.g 				**********************
Tom Sheehan tsheeha2@gmu.edu	thsheeha@vt.edu	703-538-8361
*******************************************************************************
	proto.g contains one primary routine:  
		make_prototypes
 	and two local routines 
		make_cylind_compartment
		make_spines - this one needs much work
	these are used by the primary and are not intended for external calls
	The primary function, make_prototypes is called exactly once by MSsim.g
AB: removed CaNNOINACT_channel and CaL12NOINACT_channel by combining with inactivating channels
AB: deleted CaQ because no evidence for such in SP, and doesn't contribute much anyway
AB: no longer making naP in the library since it is not used, and has been moved to a different directory
******************************************************************************/
include MScell/make_SaturateSyns.g
include MScell/include_channels.g		// required for calls in make_protypes
include MScell/ampa_channel_ghkCa.g             // taken from the old MS model
include MScell/nmda_channel_ghkCa.g             // taken from the old MS model
include MScell/spines


//************************ Begin Local Subroutines ****************************

	//********************* Begin function make_cylind_compartment *************
	function make_cylind_compartment
		if (!{exists compartment})
			echo "COMPARTMENT DID NOT EXIST PRIOR TO CALL TO:"
			echo 			"make_cylind_compartment"
			create	compartment compartment
		end

   	addfield compartment position   // add a new field "postion" to store distance to soma
        addfield compartment color      // add a new field "color" to help visualizing compartments 
	setfield compartment 		\ 
     		Em         {ELEAK} 	\
      	        initVm     {EREST_ACT} 	\
		inject		0.0 	\
      	        position    0.0         \
                color       0.0       
	end
	//************************ End function make_cylind_compartment ************

	//**************************************************************************

//************************ End Local Subroutines ******************************
//*****************************************************************************

//************** Begin function make_prototypes (primary routine) *************
function make_prototypes

  	create neutral /library
  	disable /library
	pushe /library

        make_cylind_compartment

	//********************* create non-synaptic channels in library ************************
       //voltage dependent Na and K channels
 	make_NaF_channel	
 	make_NaP_channel	
	make_KAf_channel
        make_KaF_channel // new one from Bardoni,et.al.1993		
	make_KAs_channel	
	make_KIR_channel	
	make_K_DR_channel  

       //voltage dependent Ca channels
 	create_CaL12 
	create_CaL13	
	create_CaN
//	create_CaQ
	create_CaR
 	create_CaT
      create_CaV33   
      create_CaV32
       //Ca dependent K channels
	make_BKK_channel
	make_SK_channel
 
create neutral MSsynaptic
ce MSsynaptic
 make_GABA_channel
 make_GABA2_channel  // NPY_NGF_GABAA
 make_GABA3_channel  // MSN_GABAA
 make_pseudoGABA_channel {tau1_pseudoGABA} {tau2_pseudoGABA} {Ek_pseudoGABA} 
 make_AMPA2_channel              
 make_AMPA_channel_GHKCa  "AMPA_channel_GHKCa"        // old MS model
 //make_AMPA_channel_GHKCa  "AMPA2_channel_GHKCa"        // old MS model
 make_NMDA_channel_GHKCa   "NMDA_channel_GHKCa"       // old MS model
ce ..
 make2_spines                     // taken from the old MS model
 make3_spines "big_spine" {AMPAcond4} {NMDAcond4}
	//********************* End channels in library ************************

end
//************************ End function make_prototypes ***********************



