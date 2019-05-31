//genesis
//gaba_channel.g

function make_GABA_channel

   str chanpath = "GABA_channel"
   // From Galarreta and Hestrin 1997 (used in Wolfs model)
   float tau1 =  0.25e-3             //      
   float tau2 =  3.75e-3            //     

   float gmax = 750e-12  //Modified Koos 2004 (Wolf uses 435e-12)

	echo "XXXXXXXXXXXXXXX make_GABA_channel XXXXXXXXXXXXXXXX"
	echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
	echo "XXXXXXXXXXXXXXX make_GABA_channel XXXXXXXXXXXXXXXX"

   create synchan {chanpath}

   setfield {chanpath} tau1 {tau1} \
                       tau2 {tau2}\ 
                       gmax {gmax}\
                        Ek {Egaba}

end


function make_GABA2_channel
//"A Novel Functionally Distinct Subtype of Striatal Neuropeptide Y Interneuron", Tepper 2011, J. Neurosci.
// slow GABAA inhibition from NPY-NGF to MSN
   str chanpath = "NPY_NGF_GABA_channel"
   float tau1 = 10e-3
   float tau2 = 80e-3  //150

   float gmax = 900e-12  //

	echo "XXXXXXXXXXXXXXX make_GABA2_channel XXXXXXXXXXXXXXXX"
	echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
	echo "XXXXXXXXXXXXXXX make_GABA2_channel XXXXXXXXXXXXXXXX"

   create synchan {chanpath}

   setfield {chanpath} tau1 {tau1} \
                       tau2 {tau2}\ 
                       gmax {gmax}\
                        Ek {Egaba}

end

function make_GABA3_channel
//"Recurrent Collateral Connections of Striatal Medium Spiny Neurons Are Disrupted in Models of Parkinson’s Disease"
//Stefano Taverna, et.al. 2008 J.Neurosci. 

   str chanpath = "MSN_GABA_channel"
   float tau1 = 1e-3
   float tau2 = 10e-3  // fig2. 

   float gmax = 700e-12  //

	echo "XXXXXXXXXXXXXXX make_GABA3_channel XXXXXXXXXXXXXXXX"
	echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
	echo "XXXXXXXXXXXXXXX make_GABA3_channel XXXXXXXXXXXXXXXX"

   create synchan {chanpath}

   setfield {chanpath} tau1 {tau1} \
                       tau2 {tau2}\ 
                       gmax {gmax}\
                        Ek {Egaba}

end

// the pseudoGABA has a fixed driving force of 20 mV ( Ek - V )
// by default, "synchan" set voltage "V" = 0 
// Note we DO NOT make the pseudoGABA communicate with its parent compartment
function make_pseudoGABA_channel(tau1,tau2,Ek_pseudoGABA)
   str chanpath = "pseudoGABA_channel"
   float tau1 
   float tau2  
   float Ek_pesudoGABA 

   float gmax = 700e-12  //

	echo "XXXXXXXXXXXXXXX make_pseudoGABA_channel XXXXXXXXXXXXXXXX"
	echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
	echo "XXXXXXXXXXXXXXX make_pseudoGABA_channel XXXXXXXXXXXXXXXX"

   create synchan {chanpath}

   setfield {chanpath} tau1 {tau1} \
                       tau2 {tau2}\ 
                       gmax {gmax}\
                        Ek  {Ek_pseudoGABA}

 
end



//an AMPA like channel 
function make_AMPA2_channel

   str chanpath = "AMPA2_channel"
   // From Galarreta and Hestrin 1997 (used in Wolfs model)
   float tau1 = 1.9e-3
   float tau2 = 4.8e-3

   float gmax = 750e-12  //Modified Koos 2004 (Wolf uses 435e-12)


   create synchan {chanpath}

   setfield {chanpath} tau1 {tau1} \
                       tau2 {tau2}\ 
                       gmax {gmax}\
                        Ek 0

end

