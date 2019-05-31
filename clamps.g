// Code that implements Voltage clamp and current clamp



function makeVoltageClamp(baseLevel, delay1, \
                          amplitude1, duration1, \
                          delay2, amplitude2, duration2,\
                          trigMode, compartmentPath)

  float delay1, duration1, amplitude1, delay2, duration2, amplitude2
  float baseLevel, trigMode
  str compartmentPath

  if(!{exists /clamp}) 
    create neutral /clamp
  end

  create pulsegen /clamp/vPulsegen 
  
  
  setfield ^ trig_mode {trigMode} baselevel {baseLevel} \
             level1 {amplitude1} delay1 {delay1} width1 {duration1} \
             level2 {amplitude2} delay2 {delay2} width2 {duration2}

  create RC /clamp/lowpass
   setfield ^ R 1 C 1e-5  //0.00001 charges too fast

//  setfield ^ R 1.0 C 0.03   // Taken from Squid example, Jeanette uses 0.00001
//  setfield ^ R 500 C 0.1e-6  // Taken from neurokit
//  setfield ^ R 1 C 1e-5  

//  setfield ^ R 1.0 C 0.00001   // Taken from Squid example, Jeanette uses 0.00001
   
  create diffamp /clamp/vClamp
   setfield ^ saturation 999.0 gain 1
//  setfield ^ saturation 999.0 gain 0.0 
 //  setfield ^ saturation 999.0 gain 0.002 // Taken from neurokit
//  setfield ^ saturation 999.0 gain 1 

  create PID /clamp/PID     // Values taken from squid example
setfield ^ gain 1e-7 tau_i 1e-5 tau_d 1e-7 saturation 1e-6
  // setfield ^ gain 1e-5 tau_i 1e-5 tau_d 1e-7 saturation 999.0
//  setfield ^ gain 0.50 tau_i 0.02 tau_d 0.005 saturation 999.0
//  setfield ^ gain 0.50 tau_i 0.02 tau_d 0.005 saturation 999 // 10e-3
//  setfield ^ gain 1e-6 tau_i 20e-6 tau_d 5e-6 saturation 999 // from neurokit
//  setfield ^ gain  1e-5 tau_i 1e-5 tau_d 0.25e-7 saturation 999 

  addmsg /clamp/vPulsegen /clamp/lowpass INJECT output
  addmsg /clamp/lowpass /clamp/vClamp PLUS state
  addmsg /clamp/vClamp /clamp/PID CMD output
  addmsg {compartmentPath} /clamp/PID SNS Vm
  addmsg /clamp/PID {compartmentPath} INJECT output 


 //if({trigMode}==1)      // trigger mode
 //echo we use trigger model now! 
 //float trigger_delay = 0.1      // we use 300 ms for free running    
 //create pulsegen /clamp/trig
 //setfield ^ level1 2.0 width1 0.01 delay1 {trigger_delay} width2 30.0
 //addmsg /clamp/trig /clamp/vPulsegen INPUT output
 //end
end


function makeCurrentClamp(baseLevel, delay1, \
                          amplitude1, duration1, \
                          delay2, amplitude2, duration2,\
                          trigMode, compartmentPath)

  float delay1, duration1, amplitude1
  float delay2, duration2, amplitude2
  float baseLevel, trigMode
  str compartmentPath

  echo "Baselevel:   "{baseLevel}"A (width "{delay1}"s)"
  echo "Amplitude 1: "{amplitude1}"A (width "{duration1}"s)"
  echo "Amplitude 2: "{amplitude2}"A (width "{duration2}")"
  echo "Trigger mode: "{trigMode}
  echo "Connecting to "{compartmentPath}

  if(!{exists clamp}) 
    create neutral clamp
  end

  create pulsegen /clamp/iPulsegen 

  setfield ^ trig_mode {trigMode} baselevel {baseLevel}  \
             level1 {amplitude1} delay1 {delay1} width1 {duration1} \
             level2 {amplitude2} delay2 {delay2} width2 {duration2}

  create diffamp /clamp/iClamp
  setfield ^ saturation 999.0 gain 1.0
 
  addmsg /clamp/iPulsegen /clamp/iClamp PLUS output
  addmsg /clamp/iClamp {compartmentPath} INJECT output
  
end





function makeVoltageClampPlayFile(clamp,voltageInfoFile, compartmentPath, timestep)

  str voltageInfoFile, compartmentPath,clamp
  float timestep, v0
 
  echo {voltageInfoFile}
  openfile {voltageInfoFile} r  

  str voltageFile = {readfile {voltageInfoFile}}
  float xdivs = {readfile {voltageInfoFile}} 
  xdivs = xdivs -1 
  float xmin = {readfile {voltageInfoFile}}
  float xmax = {readfile {voltageInfoFile}}

  closefile {voltageInfoFile}

  if(!{exists /{clamp}}) 
    create neutral /{clamp}
   create table /{clamp}/voltageTable
  create RC /{clamp}/lowpass
  setfield ^ R 1 C 1e-4
//  setfield ^ R 1.0 C 0.03   // Taken from Squid example, Jeanette uses 0.00001
//   setfield ^ R 500 C 0.1e-6  // Taken from neurokit
//  setfield ^ R 1 C 1e-5  

//  setfield ^ R 1.0 C 0.00001   // Taken from Squid example, Jeanette uses 0.00001
   
  create diffamp /{clamp}/vClamp
   setfield ^ saturation 999.0 gain 1
 //  setfield ^ saturation 999.0 gain 0.0 
//  setfield ^ saturation 999.0 gain 0.002 // Taken from neurokit
//  setfield ^ saturation 999.0 gain 1 

  create PID /{clamp}/PID     // Values taken from squid example
  setfield ^ gain 1e-9 tau_i 1e-5 tau_d 1.0e-6 saturation 1e-8    // for detailed model we need very "sensitive" feedback-controler 
   //setfield ^ gain 1e-5 tau_i 1e-5 tau_d 1e-7 saturation 999.0
 //setfield ^ gain 0.50 tau_i 0.02 tau_d 0.005 saturation 999.0
//  setfield ^ gain 0.50 tau_i 0.02 tau_d 0.005 saturation 999 // 10e-3
 //  setfield ^ gain 1e-6 tau_i 20e-6 tau_d 5e-6 saturation 999 // from neurokit
//  setfield ^ gain  1e-5 tau_i 1e-5 tau_d 0.25e-7 saturation 999 

  addmsg /{clamp}/voltageTable /{clamp}/lowpass INJECT output
  addmsg /{clamp}/lowpass /{clamp}/vClamp PLUS state
  addmsg /{clamp}/vClamp /{clamp}/PID CMD output
  addmsg {compartmentPath} /{clamp}/PID SNS Vm
  addmsg /{clamp}/PID {compartmentPath} INJECT output 
  else
  delete /{clamp}/voltageTable
  reset
  create table /{clamp}/voltageTable
  addmsg /{clamp}/voltageTable /{clamp}/lowpass INJECT output
 end

  


  
  call /{clamp}/voltageTable TABCREATE {xdivs} {xmin} {xmax}

  setfield /{clamp}/voltageTable step_mode 1 \ // 
                               stepsize {timestep} 
  int i
  openfile {voltageFile} r
  for(i = 0; i <= {xdivs}; i = i + 1)
    v0 = {readfile {voltageFile}}
    setfield /{clamp}/voltageTable table->table[{i}]  {v0}
  end
 echo "Reading voltage clamp data from "{voltageFile}
  closefile {voltageFile}




end




function makeCurrentClampPlayFile(currentInfoFile, compartmentPath)

  str currentInfoFile, compartmentPath
  

  openfile {currentInfoFile} r  

// note the order of reading file!!
  float timestep = {readfile {currentInfoFile}}
  float xdivs = {readfile {currentInfoFile}} 
  float xmin = {readfile {currentInfoFile}}
  float xmax = {readfile {currentInfoFile}}


  if(!{exists /clamp}) 
    create neutral /clamp
  end

  echo "Reading current clamp data from "{currentInfoFile}


  create table /clamp/currentTable
  call /clamp/currentTable TABCREATE {xdivs} {xmin} {xmax}

  setfield /clamp/currentTable step_mode 1 \ // TAB_LOOP
                               stepsize {timestep} 
  int i

  for(i = 0; i <= {xdivs}; i = i + 1)
    setfield /clamp/currentTable table->table[{i}]  {readfile {currentInfoFile}}
  end

  closefile {currentInfoFile}


  create diffamp /clamp/iClamp
  setfield ^ saturation 999.0 gain 1.0
 
  addmsg /clamp/currentTable /clamp/iClamp PLUS output
  addmsg /clamp/iClamp {compartmentPath} INJECT output

end






// to make ramping voltage clamp mode
function makeRampVoltageClamp(compartmentPath, timestep, amp1,amp2, duration1,\
                                                         amp3,amp4,duration2,\
                                                         amp5,amp6,duration3)
                              
                              

  str  compartmentPath
  float timestep,amp1,amp2,amp3,amp4,amp5,amp6,duration1,duration2,duration3,xmin,xmax,dv1,dv2,dv3,x1,x2,x3
  int xdivs,xdivs1,xdivs2,xdivs3

  if(!{exists /clamp}) 
    create neutral /clamp
  end

 xmin= 0
 xmax = duration1+duration2+duration3
 xdivs=(xmax-xmin)/timestep
 xdivs1=duration1/timestep
 xdivs2=duration2/timestep
 xdivs3=duration3/timestep
 dv1=(amp2-amp1)/xdivs1
 dv2=(amp4-amp3)/xdivs2
 dv3=(amp6-amp5)/xdivs3
 x1=amp1
 x2=amp3
 x3=amp5



  create table /clamp/voltageTable
  call /clamp/voltageTable TABCREATE {xdivs} {xmin} {xmax}

  setfield /clamp/voltageTable step_mode 1 \ // TAB_LOOP
                               stepsize {timestep} 
  int i


  for(i = 0; i <= {xdivs}; i = i + 1)
    if (i<=xdivs1)
    setfield /clamp/voltageTable table->table[{i}]  {x1}
    x1=x1+dv1
    elif (i<={xdivs1+xdivs2})
    setfield /clamp/voltageTable table->table[{i}]  {x2}
    x2=x2+dv2
    else
    setfield /clamp/voltageTable table->table[{i}]  {x3}
    x3=x3+dv3
    end
  end



  create RC /clamp/lowpass
  setfield ^ R 1 C 0.00001

//  setfield ^ R 1.0 C 0.03   // Taken from Squid example, Jeanette uses 0.00001
//  setfield ^ R 500 C 0.1e-6  // Taken from neurokit
//  setfield ^ R 1 C 1e-5  

//  setfield ^ R 1.0 C 0.00001   // Taken from Squid example, Jeanette uses 0.00001
   
  create diffamp /clamp/vClamp
  setfield ^ saturation 999.0 gain 1
//  setfield ^ saturation 999.0 gain 0.0 
//  setfield ^ saturation 999.0 gain 0.002 // Taken from neurokit
//  setfield ^ saturation 999.0 gain 1 

  create PID /clamp/PID     // Values taken from squid example
  setfield ^ gain 1e-5 tau_i 1e-5 tau_d 1e-7 saturation 999.0
//  setfield ^ gain 0.50 tau_i 0.02 tau_d 0.005 saturation 999.0
//  setfield ^ gain 0.50 tau_i 0.02 tau_d 0.005 saturation 999 // 10e-3
//  setfield ^ gain 1e-6 tau_i 20e-6 tau_d 5e-6 saturation 999 // from neurokit
//  setfield ^ gain  1e-5 tau_i 1e-5 tau_d 0.25e-7 saturation 999 

  addmsg /clamp/voltageTable /clamp/lowpass INJECT output
  addmsg /clamp/lowpass /clamp/vClamp PLUS state
  addmsg /clamp/vClamp /clamp/PID CMD output
  addmsg {compartmentPath} /clamp/PID SNS Vm
  addmsg /clamp/PID {compartmentPath} INJECT output 

end




function makeVoltageClampPlayFile_2(clamp,voltageFile, compartmentPath, timestep)

  str voltageInfoFile, compartmentPath,clamp,voltageFile
  float timestep, v0,xmin,xmax
  int xdivs
 
  //echo {voltageInfoFile}
  //openfile {voltageInfoFile} r  

  //str voltageFile = {readfile {voltageInfoFile}}
  //float xdivs = {readfile {voltageInfoFile}} 
  //xdivs = xdivs -1 
  //float xmin = {readfile {voltageInfoFile}}
  //float xmax = {readfile {voltageInfoFile}}

 // closefile {voltageInfoFile}

  if(!{exists /{clamp}}) 
    create neutral /{clamp}
   create table /{clamp}/voltageTable
  create RC /{clamp}/lowpass
  setfield ^ R 1 C 1e-4
//  setfield ^ R 1.0 C 0.03   // Taken from Squid example, Jeanette uses 0.00001
//   setfield ^ R 500 C 0.1e-6  // Taken from neurokit
//  setfield ^ R 1 C 1e-5  

//  setfield ^ R 1.0 C 0.00001   // Taken from Squid example, Jeanette uses 0.00001
   
  create diffamp /{clamp}/vClamp
   setfield ^ saturation 999.0 gain 1
 //  setfield ^ saturation 999.0 gain 0.0 
//  setfield ^ saturation 999.0 gain 0.002 // Taken from neurokit
//  setfield ^ saturation 999.0 gain 1 

  create PID /{clamp}/PID     // Values taken from squid example
  setfield ^ gain 1e-9 tau_i 1e-5 tau_d 1.0e-6 saturation 1e-8    // for detailed model we need very "sensitive" feedback-controler 
   //setfield ^ gain 1e-5 tau_i 1e-5 tau_d 1e-7 saturation 999.0
 //setfield ^ gain 0.50 tau_i 0.02 tau_d 0.005 saturation 999.0
//  setfield ^ gain 0.50 tau_i 0.02 tau_d 0.005 saturation 999 // 10e-3
 //  setfield ^ gain 1e-6 tau_i 20e-6 tau_d 5e-6 saturation 999 // from neurokit
//  setfield ^ gain  1e-5 tau_i 1e-5 tau_d 0.25e-7 saturation 999 

  addmsg /{clamp}/voltageTable /{clamp}/lowpass INJECT output
  addmsg /{clamp}/lowpass /{clamp}/vClamp PLUS state
  addmsg /{clamp}/vClamp /{clamp}/PID CMD output
  addmsg {compartmentPath} /{clamp}/PID SNS Vm
  addmsg /{clamp}/PID {compartmentPath} INJECT output 
  else
  delete /{clamp}/voltageTable
  reset
  create table /{clamp}/voltageTable
  addmsg /{clamp}/voltageTable /{clamp}/lowpass INJECT output
 end
  // we need to determine xmax and xmin from the datafile

  xmin = 0
  xmax = 1     // we create a table with a bigger size 
  xdivs = (xmax-xmin)/timestep    // note! we think the "timestep" in the datafile is identical to simulation timestep 
  call /{clamp}/voltageTable TABCREATE {xdivs} {xmin} {xmax}

  setfield /{clamp}/voltageTable step_mode 1 \ // 
                               stepsize {timestep} 
  
  openfile {voltageFile} r
  int i = 0
  int n
str line = ""

  while (!{eof {voltageFile}})
    line = {readfile {voltageFile} -linemode}   
   n = {strlen {line}}
   //echo n is {n}
   if(n>0)
      v0 = {getarg {arglist {line}} -arg 2}
    setfield /{clamp}/voltageTable table->table[{i}]  {v0}
   //echo v0_0 is {v0}
    i = i+1
   end
  end
 echo "Reading voltage clamp data from "{voltageFile}
  closefile {voltageFile}




end




function makeCurrentClampPlayFile_2(clamp,currentFile, compartmentPath, timestep)

  str voltageInfoFile, compartmentPath,clamp,currentFile
  float timestep, i0,xmin,xmax
  int xdivs
 
  //echo {voltageInfoFile}
  //openfile {voltageInfoFile} r  

  //str currentFile = {readfile {voltageInfoFile}}
  //float xdivs = {readfile {voltageInfoFile}} 
  //xdivs = xdivs -1 
  //float xmin = {readfile {voltageInfoFile}}
  //float xmax = {readfile {voltageInfoFile}}

 // closefile {voltageInfoFile}

  if({exists /{clamp}}) 
  delete /{clamp}
  reset
  end
    create neutral /{clamp}
   create table /{clamp}/currentTable
   create diffamp /{clamp}/iClamp
  setfield ^ saturation 999.0 gain 1.0

  // we need to determine xmax and xmin from the datafile

  xmin = 0
  xmax = 1     // we create a table with a bigger size 
  xdivs = (xmax-xmin)/timestep    // note! we think the "timestep" in the datafile is identical to simulation timestep 
  call /{clamp}/currentTable TABCREATE {xdivs} {xmin} {xmax}

  setfield /{clamp}/currentTable step_mode 1 \ // 
                               stepsize {timestep} 
  
  openfile {currentFile} r
  int i = 0
  int n
str line = ""

  while (!{eof {currentFile}})
    line = {readfile {currentFile} -linemode}   
   n = {strlen {line}}
   //echo n is {n}
   if(n>0)
      i0 = {getarg {arglist {line}} -arg 2}
    setfield /{clamp}/currentTable table->table[{i}]  {i0}
   //echo v0_0 is {v0}
    i = i+1
   end
  end
 echo "Reading voltage clamp data from "{currentFile}
  closefile {currentFile}



 
  addmsg /{clamp}/currentTable /{clamp}/iClamp PLUS output
  addmsg /{clamp}/iClamp {compartmentPath} INJECT output
 reset
end

