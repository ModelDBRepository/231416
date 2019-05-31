//genesis



function create_CaL12
	str chanName = "CaL12_channel"
	str compPath = "/library"
	int c

	float xmin = -0.1
	float xmax = 0.05
	int 	xdivs = 3000
	float mPower = 1.0
	float hPower = 1.0
	
        float increment ={{xmax}-{xmin}}/{xdivs}
        echo "CaL12 increment:" {increment} "V"
	float x = -0.1
  	float surf = 0
 	float gMax = 0

	float hTauCaL12 	= 1.477e-002
	float mTauCaL12 	= 0.0
	float mvHalfCaL12 = -8.9e-3
	float mkCaL12     = -6.7e-3
	float hvHalfCaL12 = -13.4e-3
	float hkCaL12     = 11.9e-3
	float hInfCaL12	= 0.0
	float mInfCaL12	= 0.0

	float theta	= 0.0
	float beta	= 0.0
	float beta_exp	= 0.0
	float mA = 0.0
	float mB = 0.0
	float qFactCaL12 	=2
	
	pushe {compPath}

	create tabchannel {chanName}
  	setfield {chanName} Xpower {mPower} Ypower {hPower}
	call {chanName} TABCREATE X {xdivs} {xmin} {xmax}
        call {chanName} TABCREATE Y {xdivs} {xmin} {xmax}	
	
	
	for(c = 0; c < {xdivs} + 1; c = c + 1)
		/************************ Begin CaL12_mTau *********************/
		//mA = 0.0398e6*(vMemb + 8.124e-3)./(exp((vMemb + 8.124e-3)/9.005e-3) - 1);
		//mB = 0.99e3*exp(vMemb/31.4e-3);
		//mTauCaL12 = 1./(mA + mB) / qFactCaL12;

		theta = 0.0398e6*{ {x} + 8.124e-3}
		beta = {{x} + 8.124e-3}/9.005e-3
		beta_exp = {{exp {beta}} - 1.0}
		mA = {{theta}/{beta_exp}}
		
		beta = {{x}/31.4e-3}
		beta_exp = {exp {beta}} 
		mB = 0.99e3*{beta_exp}

		mTauCaL12 = {1/{mA + mB}}/{qFactCaL12}		
		setfield {chanName} X_A->table[{c}] {mTauCaL12}
		/************************ End CaL12_mTau ***********************/		

		/************************ Begin CaL12_mInf *********************/
		// mInfCaL12   = 1./(1 + exp((vMemb - mvHalfCaL12)/mkCaL12));
		beta = {{x} - {mvHalfCaL12}}/{mkCaL12}
		beta_exp = {exp {beta}} + 1.0
		mInfCaL12 = 1.0/{beta_exp}
		setfield {chanName} X_B->table[{c}] {mInfCaL12}
		/************************ End CaL12_mInf ***********************/	

		/************************ Begin CaL12_hTau *********************/
		// hTauCaL12 = 14.77e-3*ones(vDiv+1,1); % Already q-corrected
		setfield {chanName} Y_A->table[{c}] {hTauCaL12}
		/************************ End CaL12_hTau ***********************/

		/************************ Begin CaL12_hInf *********************/
		// hInfCaL12   = 1./(1 + exp((vMemb - hvHalfCaL12)/hkCaL12));
		beta = {{x} - {hvHalfCaL12}}/{hkCaL12}
		beta_exp = {exp {beta}} + 1.0
                //0.17 has vdep inactivation, 0.83 does not inactivate
		hInfCaL12 = {0.17*{1.0/{beta_exp}} + 0.83}
		setfield {chanName} Y_B->table[{c}] {hInfCaL12}
		/************************ End CaL12_hInf ***********************/	
   	x = x + increment
	end	
	tweaktau {chanName} X
	tweaktau {chanName} Y

  	create ghk {chanName}GHK

  	setfield {chanName}GHK Cout {Cout} // Carter & Sabatini 2004 uses 2mM, 
											// Wolf 5mM
  	setfield {chanName}GHK valency 2.0
  	setfield {chanName}GHK T {TEMPERATURE}
	
  	setfield {chanName} Gbar {gMax*surf}
  	addmsg {chanName} {chanName}GHK PERMEABILITY Gk	
  	pope 
end
