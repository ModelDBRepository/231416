//genesis
//  kAs_chanRE.g

/***************************		MS Model, Version 9.3	*********************
**************************** 	      kAs_chanKD.g  	*********************
	
******************************************************************************
2013-03-08
Karolinska Institute
kaidu828@gmail.com(private), kai.du@ki.se(work), 
*****************************************************************************/
function make_KAs_channel
   float qfactorkAs= 3
   //include tabchanforms
  //initial parameters for making tab channel
	float Erev = -0.09
	int m_power = 2
        int h_power = 1
	
//Activation constants for alphas and betas (obtained by matching Tkatch 2000)
	float mA_rate = 0.25 //units msec
	float mA_vhalf = 50
	float mA_slope = -20
	
	float mB_rate = 0.05 //units msec
	float mB_vhalf = -90
	float mB_slope = 35
		
//Inactivation constants for alphas and betas
	float hA_rate = 2.5 //units sec
	float hA_vhalf = -95
	float hA_slope = 16
	
	float hB_rate = 2 //units sec
	float hB_vhalf = 50
	float hB_slope = -70
	    
	//table filling parameters	
    float xmin  = -0.1  /* minimum voltage we will see in the simulation */ 
    float xmax  = 0.05  /* maximum voltage we will see in the simulation */ 
    int  xdivsFiner = 3000 /* the number of divisions between -0.1 and 0.05 */
    int c = 0
    float increment = 1000*{{xmax}-{xmin}}/{xdivsFiner}
//    echo "kAs: inc="{increment}"mV"
    float x = -100
	float m_alpha, m_beta, h_alpha, h_beta
      	
      	
    /* make the table for the activation with a range of -100mV - +50mV
     * with an entry for every 10mV
     */
	 
    str path = "KAs_channel" 
    create tabchannel {path} 
    call {path} TABCREATE X {xdivsFiner} {xmin} {xmax} 
    call {path} TABCREATE Y {xdivsFiner} {xmin} {xmax} 
	 
 
    /*fills the tabchannel with values for minf, mtau, hinf and htau,
     *from the files.
     */


float a = 0.2    // 0.2

echo "make kA, qfactor=" {qfactorkAs}	
    for (c = 0; c < {xdivsFiner} + 1; c = c + 1)
		float m_alpha = {sig_form {mA_rate} {mA_vhalf} {mA_slope} {x}}
		float m_beta = {sig_form {mB_rate} {mB_vhalf} {mB_slope} {x}}
		float h_alpha = {sig_form {hA_rate} {hA_vhalf} {hA_slope} {x}}
		float h_beta = {sig_form {hB_rate} {hB_vhalf} {hB_slope} {x}}
		
		float xa = {1/{{m_alpha}+{m_beta}}}
		float xb = {{m_alpha}/{{m_alpha}+{m_beta}}}
		float ya = {1/{{h_alpha}+{h_beta}}}
		float yb = {{{{h_alpha}/{{h_alpha}+{h_beta}}}*(1-a)}+a}
		//the *0.8+0.2 in yb is to make the channel partially inactivate.  
		
		// Tables are filled with inf and taus in order to make this channel partially inactivate.
		setfield {path} X_A->table[{c}] {(xa*1e-3)/qfactorkAs}
		setfield {path} X_B->table[{c}] {xb}
		setfield {path} Y_A->table[{c}] {ya/qfactorkAs}
        setfield {path} Y_B->table[{c}] {yb}
		x = x + increment
    end
			
    /* Defines the powers of m and h in the Hodgkin-Huxley equation*/
    setfield {path} Ek {Erev} Xpower {m_power} Ypower {h_power} 
    tweaktau {path} X 
    tweaktau {path} Y 

   // tab2file ./MScell/tables/KAsXtable.txt {path} X_A -table2 X_B -overwrite
   // tab2file ./MScell/tables/KAsYtable.txt {path} Y_A -table2 Y_B -overwrite

end
