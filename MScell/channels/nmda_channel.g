//genesis
//nmda_channel.g

function make_NMDA_channel (chanpath, Ek, KMg, tau2, gmax, ghk)

  str chanpath //what you want the channel to be called (full path)
  float KMg, tau2, gmax  //parameters that differ between NR2A, B, C and D subunits
  
  float Ek
  int ghk 
  
  float tau1 = (4.4624e-3)/2 //  DE Chapman et al 2003, table 1 (12.13/e=5.63ms)
  float CMg = 1  // [Mg] in mM

  float eta = 1/3.57  // per mM
  float gamma = 62  // per Volt

	echo "XXXXXXXXXXXXXXX make_NMDA_channel XXXXXXXXXXXXXXXX"
	echo "chanpath = "{chanpath}
	echo "caBuffer = "{Ek}
	echo "KMg = "{KMg}
	echo "tau2 = "{tau2}
	echo "gmax = "{gmax}
	echo "XXXXXXXXXXXXXXX make_NMDA_channel XXXXXXXXXXXXXXXX"

	create synchan {chanpath}
	setfield {chanpath} \
          Ek   {Ek}   \
          tau1 {tau1} \
          tau2 {tau2} \
          gmax {gmax/2}
   
//the kinetics of the magnesium block is different for different subunits.  
// NR2A and B are about the same, but C and D are much less affected by the block.  
//these numbers were used because the made the magnesium block curve fit the figures by Moyner et al (1994 figure 7) best by eye.

  create Mg_block {chanpath}/block
  setfield {chanpath}/block CMg {CMg} 
  setfield {chanpath}/block KMg_B {1.0/{gamma}}
  setfield {chanpath}/block KMg_A {KMg}
				
  addmsg {chanpath} {chanpath}/block CHANNEL Gk Ek

  if (ghk==1)
     create ghk {chanPath}/GHK
     setfield {chanPath}/GHK Cout 2 // Carter & Sabatini 2004 uses 2mM, Wolf 5mM
     setfield {chanPath}/GHK valency 2.0
     setfield {chanPath}/GHK T {temperature}
     addmsg {compPath}/{chanpath}/block {chanPath}/GHK PERMEABILITY Gk 
  end

end

