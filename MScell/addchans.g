//genesis


/*these two functions will be modified when we change the add_CaShells function*/
function connectSKchannel(compPath, caBufferName)
  str compPath
  str caBufferName

  if({isa difshell {compPath}/{caBufferName}}) 
    addmsg {compPath}/{caBufferName} {compPath}/SK_channel CONCEN C
  elif({isa Ca_concen {compPath}/{caBufferName}})
   addmsg {compPath}/{caBufferName} {compPath}/SK_channel CONCEN Ca
  end
end

function connectBKKchannel(compPath, caBufferName)
  str compPath
  str caBufferName

  if({isa difshell {compPath}/{caBufferName}}) 
    addmsg {compPath}/{caBufferName} {compPath}/BKK_channel CONCEN1 C
  elif({isa Ca_concen {compPath}/{caBufferName}})
   addmsg {compPath}/{caBufferName} {compPath}/BKK_channel CONCEN1 Ca
  end
end

include MScell/connectCaChannels.g

//************************ Begin function add_CaShells ************************
/* This function needs modification.  We will need a second function, to which the name of the channel and calcium
   pool is passed to connect them. This alternate approach 
   1. will allow all the ion channels to be created before or after the calcium pools are created 
   2. it will be easier to modify the calcium dynamics model without affecting other parts of the code
   3. it will allow simplication of add_uniform_channels, & include the connectSK and connectBKK functions above.
*/
//***************** simple calcium pool following Sabatini's work *************
function add_CaShells(buffername, a, b, cellpath)
	//************************ Begin Local Variables ***************************
	str buffername,compt, cellpath
	float len,dia,a,b,position,Ca_tau,Ca_base,kb   		
	float shell_thick = 0.1e-6 // meter
	float PI = 3.14159
	float Ca_base = 50e-6   	// mM
	//************************ End Local Variables *****************************
	
	//************************* Begin Warnings ********************************* 
 	if (!{exists {cellpath}})
   	echo the cell path {cellpath} does not exist! Please check it (add_CaShells)
   	return
 	end

 	if (a > b)
   	echo You set a WRONG boundary of a and b (add_CaShell)
   	return
 	end
	//************************* End  Warnings ********************************** 

	//********************* Begin foreach statement ****************************
	foreach compt ({el {cellpath}/##[TYPE=compartment]})
	
		//************** Begin external if statement*****************************
 		if (!{{compt} == {{cellpath}@"/axIS"} || {compt} == {{cellpath}@"/ax"}}) 
    		dia = {getfield {compt} dia}
    		position = {getfield {compt} position}
     		len = {getfield {compt} len}
    		if ({{getpath {compt} -tail} == "soma"})
              len = dia
   		end
   		
   		//************** Begin internal if statement**************************
  			//if the compartment is not a spine and its position is between [a,b] 
   		if ({position >= a} && {position < b} ) 
     			// Sabatini's model. Sabatini, 2001,2004
      		create Ca_concen  {compt}/{buffername}  // create Ca_pool here!
      		if({dia} < 0.75e-6)        // this is tertiary dendrites
            	kb = 96
      		elif (dia < 1.2e-6)        // secondary dendrites
            	kb = 96
      		elif (dia < 2.3e-6)        // primary dendrites
            	kb = 96
 				else                       // soma 
      			kb = 200             	// the setting for soma is imaginary
   			end

   			if({dia}	<	15e-6)
   				Ca_tau = 25e-3
   			else 
      			Ca_tau = 100e-3       	// an imaginary setting to fit the model
   			end  
                
        float kB                        // to model calcium dyes
        float r = 3880          // calculated from Sabatini, 2004
                  // Ca_tau = (1+kE)/r,    without dyes
                  // Ca_tau = (1+kE+kB)/r, with dyes
        if ({CaDyeFlag}==2)
           kB = 220                     // Fluo-4, taken from Yasuda,et,al. 2004
           Ca_tau = (1+kb+kB)/r         // re-calculate time constant because of application of indicators
           elif({CaDyeFlag}==3)
           kB = 70                      // Fluo-5F
           Ca_tau = (1+kb+kB)/r
         end


   			// set Ca_tau  according to diameters of dendrites      
   			float  shell_dia = dia - shell_thick*2
   			float  shell_vol= {PI}*(dia*dia/4-shell_dia*shell_dia/4)*len
   			setfield {compt}/{buffername} \
               B          {1.0/(2.0*96494*shell_vol*(1+kb))} 	\
               tau        {Ca_tau}                        		\
               Ca_base    {Ca_base}   									\
               thick      {shell_thick}  
   		end
   		//************** End internal if statement****************************
   			
  		end
  		//************** End external if statement*******************************

 	end
 	//********************* End foreach statement ******************************

end	
//************************ End function add_CaShells **************************
//*****************************************************************************


//********************* Begin function add_uniform_channel ********************
//*****************************************************************************
function add_uniform_channel(obj, a, b,Gchan,cellpath )
	//************************ Begin Local Variables ***************************
 	str obj, compt, path, strhead,strhead3
 	float dia,len,surf,shell_vol,shell_thick, a,b,position,Gchan,PI,shell_dia,kb
 	int chantype = -1       // initialized as -1
 	float Ca_base = 5.0e-5  // mM
 	float Ca_tau            // second
 	float PI = 3.14159
	//************************ End Local Variables *****************************
	 
	//************************* Begin Warnings *********************************
 	if (!{exists /library/{obj}} )
  		echo the object {obj} has not been made (C) 
  	return
 	end

 	if (!{exists {cellpath}})
   	  echo the cell path {cellpath} does not exist! Please check it (add_uniform_channel)
        return
 	end

 	if (a>b)
   	  echo You set a WRONG boundary of a and b (E)
   	return
 	end
	//************************* End  Warnings ********************************** 
 
	// now we first determine which type the current object channel belongs to. 
	// we devide all channels into 4 categories: 
 	//category 1 : voltage-dependent all Na and K channels
 	// ....... 2 : calcium-dependent SK channel
 	// ....... 3 : both volt- and calcium-dependent BK channel
 	// ....... 4 : Calcium channels
 	strhead = {substring {obj} 0 0}     
		// we need the first letter of the name of the object
 	strhead3 = {substring {obj} 2 2}     
		// we need the third letter of the name of the object
 
	if ({strhead} == "N" || {strhead} == "K" || {strhead} == "I")
   	  chantype = 1                 // all Na+, Kv+, and h channels
 	elif ({strhead} == "S")
   	  chantype = 2                 //  SK channel
 	elif ({strhead} == "B")
   	  chantype = 3                 //  BK
 	elif ({strhead} == "C")
   	  chantype = 4                 // all Ca2+ channels
	end
	
	//********************* Begin foreach statement ****************************
	foreach compt ({el {cellpath}/##[TYPE=compartment]})
		
		//************** Begin external if statement*****************************
	    if (!{{compt} == {{cellpath}@"/axIS"} || {compt} == {{cellpath}@"/ax"}}) 
    		   dia = {getfield {compt} dia}
    	 	   position = {getfield {compt} position} 
    		  		
    		//********* calculate surface area from diameter (above) and length  *************  
 		if ({({dia} > 0.11e-6) && {position >= a} && {position <= b} }) 
 				//if the compartment is not a spine ,and position between [a,b]
     		   len = {getfield {compt} len}
      		   if ({{getpath {compt} -tail} == "soma"})
                       len = dia
         	   end
     		   surf = dia*{PI}*len

 		/* add channels & make channels communicated w/parent dendrites */     
         	   copy /library/{obj} {compt}
         	   addmsg {compt} {compt}/{obj} VOLTAGE Vm
                   if ({chantype} == 1)
         	        addmsg {compt}/{obj} {compt} CHANNEL Gk Ek
       		   elif ({chantype} == 2)
         	        addmsg {compt}/{obj} {compt} CHANNEL Gk Ek
         		connectSKchannel {compt}  {CA_BUFF_2}
     		   elif ({chantype}==3)
         	        addmsg {compt}/{obj} {compt} CHANNEL Gk Ek
              		connectBKKchannel {compt} {CA_BUFF_2}
        	   elif ({chantype}==4)
         	      if ({strhead3}=="L"||{strhead3}=="T")
                	addCaChannel {obj} {compt} {Gchan} {CA_BUFF_1}
         	      else 
                 	addCaChannel {obj} {compt} {Gchan} {CA_BUFF_2}
         	      end
         	      if ({exists {compt}/{CA_BUFF_2}})
            		coupleCaBufferCaChannel1  {CA_BUFF_3} {compt} {obj}
         	      end
     		   end

     		   if ({isa tabchannel /library/{obj}} || {isa tab2Dchannel /library/{obj}})
         		setfield {compt}/{obj} Gbar {Gchan*surf} 
       		   elif ({isa vdep_channel /library/{obj} })
          		setfield {compt}/{obj} gbar {Gchan*surf}
     		   end 

    		end
    		//*************** End internal if statement***************************   
  		
  	   end
  		//****************** End external if statement***************************

	end
 	//********************* End foreach statement ******************************	

end 
//************************ End function add_uniform_channel *******************
//*****************************************************************************





function deleteChannels(cellpath,list,Chan1)
str cellpath,list,compt,fullpath_compt,msg_type,src_channel,channels,ChanName,Chan1,head,head1
int num,i

foreach compt ({arglist {list}})
     fullpath_compt = {cellpath}@"/"@{compt}
 foreach channels ({el {fullpath_compt}/##[OBJECT=tabchannel],{fullpath_compt}/##[OBJECT=ghk]})
   ChanName = {getpath {channels} -tail}
   head = {substring {ChanName} 0 1}
   head1 = {substring {ChanName} 0 0}
   if ({{ChanName}=={Chan1} || "all"=={Chan1}})
     delete {channels}
     echo {channels} has been deleted!
   elif ({head}=="Ca" && "allCa"=={Chan1})
     delete {channels}
     echo {channels} has been deleted!
  elif ({head1}=="K" && "allK"=={Chan1})
     delete {channels}
     echo {channels} has been deleted!
   end
 end    // end of foreach ...

 end    // end of foreach 


end 



function disableChannels(cellpath,list)
str cellpath,list,compt,fullpath_compt,msg_type,src_channel,channels
int num,i

foreach compt ({arglist {list}})
     fullpath_compt = {cellpath}@"/"@{compt}
 foreach channels ({el {fullpath_compt}/#[OBJECT=tabchannel],{fullpath_compt}/#[OBJECT=ghk]})
   disable {channels}
   echo {channels} has been disabled!
 end    // end of foreach ...

 end    // end of foreach 


end 



function setChannelsByratio(cellpath,list,chan,K)
str cellpath,list,compt,fullpath_compt,msg_type,src_channel,chan
float K,gmax

foreach compt ({arglist {list}})
     fullpath_compt = {cellpath}@"/"@{compt}
     gmax = {getfield {fullpath_compt}/{chan} Gbar}
     gmax = gmax*K
     setfield {fullpath_compt}/{chan} Gbar {gmax}
    echo set {fullpath_compt}/{chan} now!
 end    // end of foreach 


end 










function write2file_volt(cellpath, list,filepath,file,Vm_PATH)
 str cellpath, compt,element, file, filename,elementpath,list,Vm_PATH,filepath

float outputclock = {getclock 0}

foreach compt ({arglist {list}})
 elementpath = {{cellpath}@"/"@{compt}}
// float outputclock = 10.0*{getclock 0}  


 if (!{exists {elementpath}})
   echo the element {elementpath} does not exist!
   return 
 end

 filename={filepath}@"/"@{compt}@"_"@{{file}@".dat"} 

if (!{exists /{Vm_PATH}})
    create neutral  /{Vm_PATH}
 end


  if (!{exists /{Vm_PATH}/{compt}})
    create asc_file  /{Vm_PATH}/{compt}
    echo /{Vm_PATH}/{compt} is created!! 
    useclock /{Vm_PATH}/{compt} 0
 end


 setfield /{Vm_PATH}/{compt} filename      {filename} \
                             leave_open    1    \
                             append       1    \
                             flush        1    \
                             initialize   1     \
                             float_format %0.12g 


 
 addmsg {elementpath} /{Vm_PATH}/{compt} SAVE Vm 

end // end of foreach
 
end


function write2file_Ca(cellpath, compt,ca_pool,file)
 str cellpath, compt,element, file, filename,elementpath,ca_pool

 elementpath = {{cellpath}@"/"@{compt}}@"/"@{ca_pool}
// float outputclock = 10.0*{getclock 0}  
float outputclock = 1e-5

 if (!{exists {elementpath}})
   echo the element {elementpath} does not exist!
   return 
 end

 filename={{file}@".dat"}

  if (!{exists {filename}})
    create asc_file  /{file}
    useclock /{file} {outputclock}
 end


 setfield /{file} filename      {filename} \
                 leave_open    1    \
                  append       1    \
                  flush        1    \
                  initialize   1     \
                  float_format %0.12g 


 
 addmsg {elementpath} /{file} SAVE Ca
 
end





function write2file_current(element_list,filepath,file,IK_PATH)
 str cellpath, compt,element, file, filename,elementpath,element_list, IK_PATH,file2
 int n=1

   if (!{exists /{IK_PATH}})
   create neutral /{IK_PATH}
   end

foreach elementpath ({arglist {element_list}})
 
 

 if (!{exists {elementpath}})
   echo the element {elementpath} does not exist!
   return 
 end

 filename={{filepath}@"/"@{file}@"_"@{n}@".dat"}
 echo filename is {filename}
 file2 = {file}@"_"@{n}
 
 n = n+1

 if (!{exists /{IK_PATH}/{file2}})
    create asc_file  /{IK_PATH}/{file2}
    useclock /{IK_PATH}/{file2} 0
 end
 
 setfield /{IK_PATH}/{file2} filename      {filename} \
                 leave_open    1    \
                  append       1    \
                 flush         1    \
                 initialize    1    \
                 float_format %0.15g



 addmsg {elementpath} /{IK_PATH}/{file2} SAVE Ik 

end
 
 //echo Successfully write the current of {elementpath} to the file {filename}!
 
end



function write2file_Gk(element_list,filepath,file,IK_PATH)
 str cellpath, compt,element, file, filename,elementpath,element_list, IK_PATH,file2
 int n=1

   if (!{exists /{IK_PATH}})
   create neutral /{IK_PATH}
   end

foreach elementpath ({arglist {element_list}})
 
 

 if (!{exists {elementpath}})
   echo the element {elementpath} does not exist!
   return 
 end

 filename={{filepath}@"/"@{file}@"_"@{n}@".dat"}
 echo filename is {filename}
 file2 = {file}@"_"@{n}
 
 n = n+1

 if (!{exists /{IK_PATH}/{file2}})
    create asc_file  /{IK_PATH}/{file2}
    useclock /{IK_PATH}/{file2} 0
 end
 
 setfield /{IK_PATH}/{file2} filename      {filename} \
                 leave_open    1    \
                  append       1    \
                 flush         1    \
                 initialize    1    \
                 float_format %0.15g



 addmsg {elementpath} /{IK_PATH}/{file2} SAVE Gk

end
 
 //echo Successfully write the current of {elementpath} to the file {filename}!
 
end







