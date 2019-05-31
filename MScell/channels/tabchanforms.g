/*form call file for creating tab channels*/


function exp_form (rate, slope, V)
	float rate,slope,V
	//equation is ({rate} *(exp (-{V}/{slope}) ))
	float numx ={{-V}/{slope}}
	float expx = {exp {numx}}
	float entry = ({rate}*{expx})
	return {entry}
end

function sig_form (rate, vhalf, slope, V)
	float rate, vhalf, slope, V
	//equation is ({rate}/(exp ({{V}-{vhalf}}/{slope})+1))
	//rate/(EXP((v-vhalf)/slope)+1)
	float numx = {{{V}-{vhalf}}/{slope}}
	float expx = {exp {numx}}
	float entry = ({rate}/{{expx}+1})
	return {entry}
end

function lin_form (rate, vhalf, slope, V)

	float rate, vhalf, slope, V
	//equation is (({rate}*({V}-{vhalf}))/{exp ({v}-{vhalf}/{slope})-1)})
	float numx = {{{{V}-{vhalf}}/{slope}}-1}
	float expx = {exp {numx}}
	float numerator = {{rate}*{{V}-{vhalf}}}
	float entry = {{numerator}/{expx}}
	return {entry}
	// put in check for if v=vhalf then add 0.0001 or something. or... dtop/dbottom is L'Hopital.  
	
end
