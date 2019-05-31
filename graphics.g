//genesis




/*********************** Begin Local Subroutines *****************************/
/*****************************************************************************/

	//************************ Begin function record_channel *******************
	function record_channel(compt,channel,xcell, color)
 		str compt,xcell,channel, color		
 		str path, graphic_path
                       
		path = {neuronname}@"/"@{compt}@"/"@{channel}
		if ({channel}=="Ca_difshell_1"||{channel}=="Ca_difshell_2"||	\
															{channel}=="Ca_difshell_3")
			if( {isa difshell {path}})
				addmsg {neuronname}/{compt}/{channel} 							\
										{xcell}/Ca PLOT C  *	{channel}  *{color}
			elif( {isa Ca_concen {path}})
				addmsg {neuronname}/{compt}/{channel} 							\
										{xcell}/Ca PLOT Ca *{compt}  *{color}
			end
		else 
			addmsg {neuronname}/{compt}/{channel} {xcell}/channels 			\
										PLOT Ik *{channel} *{color}
		end 
	end
	//************************ End function record_channel *********************
	//**************************************************************************

	//************************ Begin function record_channel *******************
	function record_voltage (compt, xcell,color)
 		str compt, xcell, color
 	
 		str path, spacer, graphic_path
 	
		spacer = "        "
		//graphic_path = {compt}@{spacer}
    	addmsg {neuronname}/{compt} {xcell}/v PLOT Vm *{compt} *{color}
	end
	//************************ End function record_channel *********************
	//**************************************************************************
	
	//************************ Begin function step_tmax ************************
	function step_tmax
   	reset
   	setfield /cell/soma inject 0
   	step 5000
   	setfield /cell/soma inject {getfield /control/Injection value}
   	step 20000
   	setfield /cell/soma inject 0.0
	end
	//************************ End function step_tmax **************************
	//**************************************************************************
	
	//************************ Begin function set_inject ***********************
	function set_inject(dialog)
    	str dialog
    	setfield /cell/soma inject {getfield {dialog} value}
	end
	//************************ End function set_inject *************************
	//**************************************************************************
	
	//************************ Begin function overlaytoggle ********************
	function overlaytoggle(widget)
    	str widget
    	setfield /##[TYPE=xgraph] overlay {getfield {widget} state}
	end
	//************************ End function overlaytoggle **********************
	//**************************************************************************
	
	//************************ Begin function add_overlay **********************
	function add_overlay
		create xtoggle /control/overlay   -script "overlaytoggle <widget>"
		setfield /control/overlay offlabel "Overlay OFF" onlabel "Overlay ON" \
																								state 0
	end
	//************************ End function add_overlay ************************
	//**************************************************************************

/*********************** End Local Subroutines *******************************/
/*****************************************************************************/


/*********************** Begin Externally Available Subroutines **************/
/*****************************************************************************/

	//************************ Begin function make_control *********************
	function make_control
    	create xform /control [1050,0,250,145]
    	create xlabel /control/label -hgeom 25 -bg cyan -label "CONTROL PANEL"
       
    	create xbutton /control/RESET -wgeom 33%       -script reset
    	create xbutton /control/RUN  -xgeom 0:RESET -ygeom 0:label -wgeom 33% \
         -script step_tmax
         
    	create xbutton /control/QUIT -xgeom 0:RUN -ygeom 0:label -wgeom 34% 	 \
      	-script quit
    	create xdialog /control/Injection -label "Inject Amps" 					 \
         -value 304.95e-12 -script "set_inject <widget>"
   
    	xshow /control
	end
	//************************ End function make_control ***********************
	//**************************************************************************

	//************************ Begin function make_graph ***********************	
	function make_graph
		str xcell = "/data"	
		float tmax = 0.6
		float xmin = 0.01
					
		create xform  /data [0,0,1000,1000]
		create xlabel /data/label [10,0,95%,25] 							\
			-label " MSN Cell"  													\
      	-fg    red

		create xgraph /data/v [10,10:label.bottom, 50%, 45%] 			\
      	-title "Memberaine Potential in the Soma"  					\
      	-bg    white

		create xgraph /data/syncurrents [10,10:v.bottom,50%,45%] 	\
      	-title "Synaptic currents"  										\
      	-bg    white 
	
		create xgraph /data/Ca [10:v.right,10:label.bottom,50%,45%] \
      	-title "Calcium Concentration: Calcium Buffer 3" 			\
      	-bg    white
      
		create xgraph /data/channels 											\
			[10:syncurrents.right,10:Ca.bottom,48%,45%] 					\
      	-title "Channel Currents: tertdend4/tert_dend5" 			\
      	-bg    white

		setfield /data/v      		xmin {xmin} xmax {tmax+0.01}   	\
											ymin -0.1 ymax 0.05
		setfield /data/Ca     		xmin {xmin} xmax {tmax+0.01}   	\
											ymin 4.5e-5 ymax 7e-5
		setfield /data/syncurrents xmax {tmax+0.8}  ymin 0 			\
											ymax 5.0e-12
		setfield /data/channels   	xmax {tmax+0.01}  ymin -1.2e-12 	\
											ymax 1.0e-13

  		useclock /data/v					 	1
  		useclock /data/Ca        			1 
  		useclock /data/channels  			1
		xshow /data
	
		reset
		

		//record voltage of the compartment
		record_voltage "tertdend4/tert_dend5" {xcell} "blue" 	                   
		record_voltage soma {xcell} "red"  

		record_channel "tertdend4/tert_dend5" KAsI_channel 	{xcell} "blue"
		record_channel "tertdend4/tert_dend5" KAsII_channel	{xcell}  "red"
		record_channel "tertdend4/tert_dend5" KIR_channel   	{xcell}  "black"
		record_channel "tertdend4/tert_dend5" KAf_channel   	{xcell}  "green"
		record_channel soma 			{CA_BUFF_3}		{xcell}  "blue"
		record_channel primdend4 	{CA_BUFF_3} 	{xcell}  "black"
		record_channel secdend6 	{CA_BUFF_3} 	{xcell}  "red"
		record_channel tertdend4 	{CA_BUFF_3} 	{xcell}  "green"

		reset 

		add_overlay 
	end
	//************************ End function make_graph *************************
	//**************************************************************************
	
/*********************** End Externally Available Subroutines ****************/
/*****************************************************************************/




