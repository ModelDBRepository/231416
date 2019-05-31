//genesis



//************************ Begin Primary Routine ******************************
//*****************************************************************************
function make_K_DR_channel
	//********************* Begin Local Variables ******************************
   float xmin = -0.1
   float xmax = 0.05
   int xdivs = 3000
   float x,dx,alpha_m,beta_m,tau_m,m_inf
   int i
   float  qfactor = 3    // 0.5   
   float Erev = -0.09    
	//********************* End Local Variables ********************************

 	if ({exists K_DR})
		echo "K_DR tabchannel exists"
   	return
 	end
 
 	create tabchannel K_DR 
  	setfield ^ Ek {Erev} 	\
             Gbar 100.0 	\ 
             Ik 0        	\
             Gk 0        	\
             Xpower 1    	\
             Ypower 0    	\
             Zpower 0 

  	call K_DR TABCREATE X {xdivs} {xmin} {xmax}
        dx = (xmax-xmin)/xdivs
        x = xmin
	echo "K_DR increment:" {dx} "V"
   for (i=0;i<={xdivs};i=i+1)

		/*migliore, et,al 1999 */
      alpha_m =1000.0*({exp {-110*(x+0.013)}} )
      beta_m  =1000.0*({exp {-80*(x+0.013)}}) 
      tau_m = {{0.001*50*beta_m/(1e3+alpha_m)}/qfactor}
      m_inf = 1000.0/(1000.0+alpha_m)
      setfield K_DR X_A->table[{i}] {tau_m}
      setfield K_DR X_B->table[{i}] {m_inf}
      x = x+dx
   end

   tweaktau K_DR X 
 
   setfield K_DR X_A->calc_mode 1 X_B->calc_mode 1
end
//************************ End Primary Routine ********************************
//*****************************************************************************
