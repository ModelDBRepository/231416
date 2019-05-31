//genesis

/***************************		MS Model, Version 5.2	*********************
**************************** 	  		CaN_channel.g 			*********************
		Tom Sheehan tsheeha2@gmu.edu	thsheeha@vt.edu	703-538-8361
******************************************************************************
******************************************************************************/
/*AB
This channel combines both the inactivating and non-inactivating CaN channels
It has a smaller qfactor to produce a slower channel
*/
function create_CaN
	str chanName = "CaN_channel"
	str compPath = "/library"

	int c	
	float x = -0.1
	int xdivs = 3000
	float xmin = -0.1
	float xmax = 0.05
        float increment ={{xmax}-{xmin}}/{xdivs}
        echo "CaN increment:" {increment} "V"
  	float mPower = 1.0
  	float hPower = 1.0

	float mvHalfCaN = -8.7e-3
	float mkCaN = -7.4e-3
	float hvHalfCaN = -74.8e-3
	float hkCaN = 6.5e-3
	float mTauCaN = 0.0
	float mInfCaN = 0.0
	float hTauCaN = 2.333e-002
	float hInfCaN = 0.0

	float theta	= 0.0
	float theta_1 = 0.0
	float beta	= 0.0
	float beta_exp	= 0.0
	float mA	= 0.0
	float mB	= 0.0
	float surf = 0.0
 	float gMax = 0
	float qFactCaN = 2

	pushe {compPath}

	create tabchannel {chanName}
  	setfield {chanName} Xpower {mPower} Ypower {hPower}
	call {chanName} TABCREATE X {xdivs} {xmin} {xmax}
        call {chanName} TABCREATE Y {xdivs} {xmin} {xmax}

	for(c = 0; c < {xdivs}; c = c + 1)
		/************************ Begin CaN_mTau *********************/
		// mA = 0.03856e6*(vMemb + 17.19e-3)./
		//                      (exp((vMemb + 17.19e-3)/15.22e-3)-1);
		// mB = 0.3842e3*exp(vMemb/23.82e-3);
		// mTauCaN = (1./(mA + mB)) / qFactCaN;


		theta = 0.03856e6*{ {x} + 17.19e-3}
		beta = {{x}  + 17.19e-3}/15.22e-3
		beta_exp = {exp {beta}}
		beta_exp = beta_exp - 1.0
		mA = {{theta}/{beta_exp}}

		beta = {{x}/23.82e-3}
		beta_exp = {exp {beta}} 
		mB = 0.3842e3*{beta_exp}

		mTauCaN = {1.0/{mA + mB}}/{qFactCaN}		
		setfield {chanName} X_A->table[{c}] {mTauCaN}
		/************************ End CaN_mTau ***********************/
	
		/************************ Begin CaN_mInf *********************/
		// mInfCaN   = 1./(1 + exp((vMemb - mvHalfCaN)/mkCaN));
		beta = {{x} - {mvHalfCaN}}/{mkCaN}
		beta_exp = {exp {beta}} + 1.0
		mInfCaN = 1.0/{beta_exp}
		setfield {chanName} X_B->table[{c}] {mInfCaN}
		/************************ End CaN_mInf ***********************/

		/************************ Begin CaN_hTau *********************/ 
		// hTauCaN   = 23.33e-3*ones(vDiv+1,1); % Already q-fact corrected
		setfield {chanName} Y_A->table[{c}] {hTauCaN}
		/************************ End CaN_hTau ***********************/

		/************************ Begin CaN_hInf *********************/
		// hInfCaN   = 1./(1 + exp((vMemb - hvHalfCaN)/hkCaN));
		beta = {{x} - {hvHalfCaN}}/{hkCaN}
		beta_exp = {exp {beta}} + 1
                //0.21 has vdep inactivation, 0.79 does not inactivate
                hInfCaN = 0.21 * {1/{beta_exp}} + 0.79
 		setfield {chanName} Y_B->table[{c}] {hInfCaN}
		/************************ End CaN_hInf ***********************/
	
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

