//genesis



function create_CaL13
	str chanName = "CaL13_channel"
	str compPath = "/library"

	int c
	float x = -0.1
	int xdivs = 3000
	float xmin = -0.1
	float xmax = 0.05
        float increment ={{xmax}-{xmin}}/{xdivs}
        echo "CaL13 increment:" {increment} "V"
  	float mPower = 2.0
  	float hPower = 1.0
  
	float hTauCaL13 	= 1.477e-002
	float mTauCaL13 	= 0.0
	float mvHalfCaL13 = -33.0e-3
	float mkCaL13     = -6.7e-3
	float hvHalfCaL13 = -13.4e-3
	float hkCaL13     = 11.9e-3
	float hInfCaL13	= 0.0
	float mInfCaL13	= 0.0

	float theta	= 0.0
	float beta	= 0.0
	float beta_exp	= 0.0
	float mA	= 0.0
	float mB	= 0.0
  	float surf = 0
	float qFactCaL13 	= 2
 	float gMax = 4.25e-009

	pushe {compPath}

	create tabchannel {chanName}
  	setfield {chanName} Xpower {mPower} Ypower {hPower}
	call {chanName} TABCREATE X {xdivs} {xmin} {xmax}
        call {chanName} TABCREATE Y {xdivs} {xmin} {xmax}	
	
	for(c = 0; c < {xdivs} + 1; c = c + 1)
		/************************ Begin CaL13_mTau *********************/
		//mA = 0.0398e6*(vMemb + 8.124e-3)./
		// 							(exp((vMemb + 8.124e-3)/9.005e-3) - 1);
		//mB = 0.99e3*exp(vMemb/31.4e-3);
		//mTauCaL12 = 1./(mA + mB) / qFactCaL12;

		theta = 0.0398e6*{ {x} + 8.124e-3}
		beta = {{x} + 8.124e-3}/9.005e-3
		beta_exp = {exp {beta}}
		beta_exp = beta_exp - 1.0
		mA = {{theta}/{beta_exp}}
		
		beta = {{x}/31.4e-3}
		beta_exp = {exp {beta}} 
		mB = 0.99e3*{beta_exp}

		mTauCaL13 = {1.0/{mA + mB}}/{qFactCaL13}		
		setfield {chanName} X_A->table[{c}] {mTauCaL13}
		/************************ End CaL13_mTau ***********************/		

		/************************ Begin CaL13_mInf *********************/
		// mInfCaL13   = 1./(1 + exp((vMemb - mvHalfCaL13)/mkCaL13));
		beta = {{x} - {mvHalfCaL13}}/{mkCaL13}
		beta_exp = {exp {beta}} + 1.0
		mInfCaL13 = 1.0/{beta_exp}
		setfield {chanName} X_B->table[{c}] {mInfCaL13}
		/************************ End CaL13_mInf ***********************/

		/************************ Begin CaL13_hTau *********************/
		// hTauCaL13 = 14.77e-3*ones(vDiv+1,1); % Already q-corrected
		setfield {chanName} Y_A->table[{c}] {hTauCaL13}
		/************************ End CaL13_hTau ***********************/

		/************************ Begin CaL13_hInf *********************/
		// hInfCaL13   = 1./(1 + exp((vMemb - hvHalfCaL13)/hkCaL13));
		beta = {{x} - {hvHalfCaL13}}/{hkCaL13}
		beta_exp = {exp {beta}} + 1.0
		hInfCaL13 = 1.0/{beta_exp}
		setfield {chanName} Y_B->table[{c}] {hInfCaL13}
		/************************ End CaL13_hInf ***********************/	
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
