//genesis




include MScell/addchans	// provides access to add_uniform_channel & add_CaShells 
					// as required by local subroutine add_channels
include MScell/proto  // provides access to make_prototypes required by primary
					// routine make_MS_cell

include MScell/ParseCell // to (1) parse more complicated tree structure using first-depth algrism and
                         // (2) calculate positions of each compartments.
                         // this file is to replace the old set_position routings

include MScell/AddSynapticChannels 
    	
//************************ Begin Local Subroutines ****************************
//*****************************************************************************

	//************************ Begin function set_position *********************
	//**************************************************************************
	function set_position (cellpath)
		//********************* Begin Local Variables ************************
 		str compt, cellpath
 		float dist2soma,x,y,z
 		//********************* End Local Variables *****************************
 		
 		if (!{exists {cellpath}})
  			echo The current input {cellpath} does not exist (set_position) 
  			return
 		end
 
 		foreach compt ({el {cellpath}/##[TYPE=compartment]})
     		  x={getfield {compt} x}
     		  y={getfield {compt} y}
     		  z={getfield {compt} z}
     		  dist2soma={sqrt {({pow {x} 2 }) + ({pow {y} 2}) + ({pow {z} 2})} }  
     		  setfield {compt} position {dist2soma}
   	        end
	end
	//************************ End function set_position ***********************
	//**************************************************************************

	//************************ Begin function add_channels *********************
	//**************************************************************************
	function add_channels (cellpath)
         str cellpath
		/************************************************************************
		next, to add ion channels the function "add_uniform_channel" is  
		called to insert channels in to the cell with the distance to soma  
		between a(minimum) and b(max) more details can be found in the file 
		"adjust.g"
		MAGIC_NUMBERS_1
		However the question remains: where do the values of a, b, & conductance
		density come from?
		************************************************************************/

		/* add_uniform_channel (from addchans.g)
					channel_Name	a    		b 	density	  */
               
		// // Naf in the soma 
	        add_uniform_channel "NaF_channel"    0        11.8e-6	{gNaFprox} {cellpath}
		// // Naf in the dendrites
		add_uniform_channel "NaF_channel"   11.8e-6  90e-6	{gNaFmid}  {cellpath}
		add_uniform_channel "NaF_channel"   90e-6  500e-6 	{gNaFdist}  {cellpath} 
               
                if ({usingNaP}==1)
                add_uniform_channel "NaP_channel"   0        11.8e-6	{gNaPprox} {cellpath}
                add_uniform_channel "NaP_channel"   11.8e-6        1000e-6	{gNaPdist} {cellpath}
                end


                if ({usingNewKaF} == 1)
		// KaF in the soma and proximal dendrites
		add_uniform_channel "KaF_channel"   0        11.8e-6	{gKAfprox} {cellpath}
		//  KaF in the middel and distal dendrites
		add_uniform_channel "KaF_channel"   11.8e-6  90e-6	{gKAfmid}   {cellpath}
		add_uniform_channel "KaF_channel"   90e-6 1000e-6    {gKAfdist}  {cellpath}
                  else
		add_uniform_channel "KAf_channel"   0        11.8e-6	{gKAfprox} {cellpath}
		//  KaF in the middel and distal dendrites
		add_uniform_channel "KAf_channel"   11.8e-6  90e-6	{gKAfmid}   {cellpath}
		add_uniform_channel "KAf_channel"   90e-6 1000e-6    {gKAfdist}  {cellpath}
                end
		// KAs in the soma and proximal dendrites
		add_uniform_channel "KAs_channel"  0         11.8e-6	{gKAsSoma} {cellpath} 
                //  KAs in the proximal dendrites  
                add_uniform_channel "KAs_channel"  11.8e-6   90e-6	{gKAsprox} {cellpath} 
		//  KAs in the middle and distal dendrites
	 	add_uniform_channel "KAs_channel"  90e-6  1000.0e-6 	{gKAsdist} {cellpath}
    
       if ({usingKIR}==1)
		add_uniform_channel "KIR_channel"   0        11.8e-6	 {gKIRsoma}  {cellpath}  
		add_uniform_channel "KIR_channel"   11.8e-6  1000e-6	 {gKIRdist}  {cellpath}
      end
  		add_uniform_channel "K_DR"          0        11.8e-6     {gKDRsoma}  {cellpath}
		add_uniform_channel "K_DR"          11.8e-6  1000e-6     {gKDRdist}  {cellpath}
               
	//	function add_CaShells is defined in adjust.g
	//	to be coupled with N/Q/R Ca2+ channels 
		add_CaShells {CA_BUFF_1}  0 500e-6   {cellpath} 
		// to be coupled with T/L Ca2+ channels 
		add_CaShells {CA_BUFF_2}  0 500e-6  {cellpath} 
		// to be coupled with all Ca2+ channels    
		add_CaShells {CA_BUFF_3}  0 500e-6   {cellpath} 

		/************************************************************************
		the parameters for Pbar of Calcium channels are adopted from Wolf's 
		2005 model. Please note in order to transfer the units into SI unites, 
		all parameters should be multiplied by 1e-2
		************************************************************************/

//		//add_uniform_channel "CaQ_channel" 		0 	16e-6	{gCaQ}  {cellpath}
        if ({usingCaR}==1)	
		 add_uniform_channel "CaR_channel" 		0 	500e-6  {gCaR} {cellpath}
        end
 
		 add_uniform_channel "CaN_channel" 		0 	11.8e-6  	{gCaN}  {cellpath}

		 add_uniform_channel "CaL12_channel"        0 	500e-6  {gCaL12}  {cellpath}

		 add_uniform_channel "CaL13_channel" 	        0 	500e-6  {gCaL13} {cellpath}

	if ({usingCaT}==1)	
        add_uniform_channel "CaT33_channel" 		60e-6	500e-6  {gCaV33} {cellpath}  
        add_uniform_channel "CaT32_channel" 		60e-6	500e-6  {gCaV32} {cellpath}  
     end
		  add_uniform_channel "BKK_channel" 		0 	  11.8e-6	500   {cellpath}
		  add_uniform_channel "BKK_channel" 		11.8e-6   500e-6	150    {cellpath}
                  add_uniform_channel "SK_channel" 		0 	  11.8e-6          10     {cellpath}
		  add_uniform_channel "SK_channel" 		11.8e-6   500e-6        10     {cellpath}

end

 
	//************************ End function add_channels ***********************
	//**************************************************************************
//************************ End Local Subroutines ******************************
//*****************************************************************************

//************************ Begin Primary Routine ******************************
//*****************************************************************************

	//************************ Begin function make_MS_cell *********************
	//**************************************************************************
	function make_MS_cell (cellpath,pfile, a,b,F,F2)
         str cellpath,pfile
          float F,a,b,F2
         echo {cellpath}
 	// function make_MS_cell is the first call from the primary file (MSsim.g). 
	// Note that the first thing it does is to call make_protypes in proto.g. 
	// These prototypes must be made before the call to add_channels. When the
	// function add_channels is modified (as in msv4.0) to no longer add
	// certain channels (such as K13, KRPI & KRPII), then the respective 
	// make_prototypes calls (i.e. make_KRPII_channel should be deleted as 
	// dead code. That is to say that only those channels shown in add_channels 
	// (above) should have a make prototype in function make_prototypes in
	// proto.g
		make_prototypes					//	see proto.g
                readcell {pfile} {cellpath}
                writecell ../"newMSN.p" {cellpath} -absolute 

      //set_position  {cellpath} 
    SetPosition  {cellpath}/soma            // new method of calculating-distance






        add_channels {cellpath}					// local call
        adjustCellForSpines {cellpath} {a} {b} {F} {F2}        // see ParseCell.g
    
	
	end	
	//************************ End function make_MS_cell ***********************
	//**************************************************************************			
//************************ End Primary Routine ********************************
//*****************************************************************************
