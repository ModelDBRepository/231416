//genesis

/***************************		MS Model, Version 5.0	*********************
**************************** 	    	SKchannelCaDep.g 		*********************
		Tom Sheehan tsheeha2@gmu.edu	thsheeha@vt.edu	703-538-8361
******************************************************************************
******************************************************************************/


/*************************** SKchannelCaDep.g *************************************
 *	In the original program written by Johanes Hjorth a MatLab routines in 
 * striatum/mspn/table/CaDepCurrents/makeSKCaDepTables.m opened two text (data)
 * files {SKgate.txt & Skinfo.txt and used those to create a set of of text (data)
 * files in striatum/mspn/channels/table/CaDepCurrents"
 * The product of this sequence was then opened by this genesis routine to populate 
 * a set of tabchannels.
 *
 * In the rework by Kai_Du the MatLab files are removed but their product (the data 
 * files) are retained.
 *
 * This revision moves the MatLab calculations to the .g file that is creating
 * the tabchannel and removes the data files. 
 * The comments below are from Hjorth 
		// This is a simplified implementation of the SK channel without voltage
		// dependence. Reference: MaylieBondHersonLeeAdelman2004
		// Fast component has tau=4 ms, slow tau = 70 ms (rough ranges)
 * End Hjorth comments
 
 *************** Tom Sheehan 2/8/09	703-538-8361********************************/

function make_SK_channel

  	int i	= 5
  	int nStep = 1000
  	float SKact = 0.0
  	float CaMax = 0.002
	float theta = 0.0
	float theta_pow = 0.0	
  	float CaMax = 0.002
  	int nStep = 1000
  	float Kd = 0.57e-003
  	float delta = 0.0001
   int y = 1
   float x = 0.0
    		
  	str chanpath = "SK_channel" 
  	
  	pushe /library

  	if (({exists {chanpath}}))
    	return
  	end

  	create  tabchannel {chanpath}
  	setfield	^		Ek  		{-90e-3}		\
					Gbar		0.145e4		\
					Ik			0			\
					Gk			0			\
					Xpower  	0			\
					Ypower  	0			\
					Zpower  	1			

  	call {chanpath} TABCREATE Z {nStep-1} 0 {CaMax} // Creates nCaSteps entries
	
	while(i > 0)
		i = 0
	end
	
	for (i = 0; i < {nStep}; i = i + 1)		 		
  		//let x = Ca; set the value for x 		
  		if(i < 26)
  			x = 0.0
  		else
  			if(y < 51)
  				x = delta
  				y = y + 1
  			else
  				y = 1
  				delta = delta + 0.0001
  			end
  		end 
  		theta = {x/Kd}
  		theta_pow = { pow {theta} 5.4}
  		SKact = theta_pow/{1 + theta_pow}
     	setfield {chanpath} Z_B->table[{i}] {SKact}
		setfield {chanpath} Z_A->table[{i}] {4e-3} // Fast component, tau=4ms
	end		   	  		 			 
  	tweaktau {chanpath} Z
  	pope
end





