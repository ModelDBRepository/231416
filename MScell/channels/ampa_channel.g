//genesis
//ampa_channel.g

function make_AMPA_channel(chanpath)
   str chanpath

   // Values from Wolfs model, original data Gotz et al 1997 (from NA),
   // Chapman et al 2003
   float tau1 = 1.1e-3
   float tau2 = 5.75e-3 

   float gmax = 593e-12
   float Ek = 0.0

	echo "XXXXXXXXXXXXXXX make_AMPA_channel XXXXXXXXXXXXXXXX"
	echo "chanpath = "{chanpath}
	echo "XXXXXXXXXXXXXXX make_AMPA_channel XXXXXXXXXXXXXXXX"

   create synchan {chanpath}

   setfield {chanpath} tau1 {tau1} tau2 {tau2} gmax {gmax} Ek {Ek}

end
