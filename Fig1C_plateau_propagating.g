//genesis


include MScell/globals_1		  		// Defines & initializes cell specific parameters
include clamps.g


int usingHsolve = 1
int usingNewKaF = 0
int usingNaP    = 1
int addCa2Spine = 1
int useAMPA = 1
int use_F_factor = 1
int usingElectro_Leak = 0      // to simulate eletro-leak in the soma 
int usingClamp = 0
int usingCaT = 1
int usingCaR = 1
int usingKIR = 1
int showMSoutput =	1
int usingSaturSynchan = 100  //3.3



/* F is the factor for spine compensation
*** you can ignore this part*******************/
if ({{use_F_factor}==1})
float F = 1.38  // 1.38
else
float F = 1
end
float F2 = 1     // RA in the distal dendrite = 4, Surmeier's paper 

str 	neuronname = "/cell"                     // cell morphology file
include MScell/MScellSpine_test                // access make_MS_cell this function is only called from MSsim.g
str pfile="MScell/swc5_SPN.g"


include xcell		        // access functions "record_channel"
				// These two functions are only called from MSsim.g

/****************************** End includes *********************************/
float speedA = 20
	setclock 0 {speedA*1e-6}   // Simulation time step (Second)       
	setclock 1 {speedA*1e-6}   // clock for graphic output


/******************* Compensate for spines***********************************/
make_MS_cell {neuronname} {pfile} 30.0e-6 160.0e-6 {F} {F2} 	// MS_cell.g 
/*****************************************************************************************/


reset


/*****************************Visualize the neuron**********************************/
///////////////////////////////////////////////////////////////////////////////
str list = {findCompt {neuronname} 1e-6 200e-6 0.5e-6 }
increaseXcellDia {neuronname} {list} 2
  create xform /cellform1 [620,50,1000,1000]
    create xdraw /cellform1/draw [0,0,100%,100%] \
                             -wx 3e-3  \
                             -wy 3e-3  \
                             -transform ortho3d \
                             -bg black
    //setfield {neuronname}/soma dia 8e-6
    setfield /cellform1/draw xmin -1.2e-4 xmax 1.2e-4 ymin -1.2e-4 ymax 1.2e-4 \
        zmin -1e-3 zmax 1e-3 

     setfield /cellform1/draw transform z

    xshow /cellform1
    echo creating xcell
    create xcell /cellform1/draw/cell
    setfield /cellform1/draw/cell colmin -0.09 colmax -0.01 \
                                  path {neuronname}/##[TYPE=compartment]   field Vm \
                                  script "echo widget clicked on = <w> value = <v>" \
                                  diarange -50

     xcolorscale hot

    str above = "cell" 
    str parent  =  "/cellform1/draw"
  //make_colorbar {parent} {above}
     reset
 
 /////////////////////////////////////////////////////////////////////////////////////////




str compt_1 = "1409"  //proximal,1146; distal,1409
add_spines {neuronname} {compt_1} spine 15         // located 90-100 um from the soma




// IMPORT!!!! Using HSOVLE METHOD HERE
if ({usingHsolve == 1})
pushe {neuronname}
  create hsolve solve
  setfield  solve  \
           chanmode 1 \
           path     {neuronname}/##[][TYPE=compartment]

  call ^ SETUP

 setmethod 11

 pope
 reset
end	







/****************************** End MSsim.g **********************************/

// // /********************************************************
// // ************* begin to draw results**********************
// // *********************************************************/


if({showMSoutput}==1)
/*****function make_xcells(xcell, label, title1,title2,title3,title4,tmin,tmax)********/
str xcell ="xcell"
str label = "Dendritic Plateau at "@{compt_1}
str title1 = "Membrane_Voltage"
str xcellPath = "output/"@{xcell}
int chanmode = 0  
float tmin = 0.2
float tmax = 0.5

make_VerticalXcells {xcellPath} {label} {title1} {tmin} {tmax} 
/*****************************************************************************/
/*********function record_channel(cellpath,compt,channel,xcell,title, color,ymin,ymax)********/
/*********function record_voltage (cellpath, compt, xcell,lable,color,ymin,ymax,chanmode)****/
/******************** record voltage ****************************************************/
float ymin_volt = -0.09
float ymax_volt = 0.0
record_voltage   {neuronname}   soma                 {xcellPath}  {title1} "soma"        "blue"    {ymin_volt} {ymax_volt} {chanmode}    
record_voltage {neuronname}     {compt_1}         {xcellPath}  {title1}    "dendrite"     "red"     {ymin_volt} {ymax_volt} {chanmode}   // to record voltage of the compartment            
//record_voltage {neuronname}    1437               {xcellPath} {title1}     "distal tip"   "black"  {ymin_volt} {ymax_volt} {chanmode}
//record_voltage {neuronname}    746                {xcellPath} {title1}     "another branch"   "pink" {ymin_volt} {ymax_volt} {chanmode}


reset

/**************************************************************************/
end

mkdir /home/kai/results/Plateaus

float isi = 0.001

int inj = 100
float inj1 = inj*1e-12







// Simulation Protocols 

 setfield {neuronname}/soma inject {inj1}
 step 0.3 -time   // activation of 15 spines need 15 ms, "0.485"


activate_spines {neuronname} {compt_1} "spine" 15 {isi} 1

step 0.2 -time
//

//deletemsg /output/Vsoma  0 -in
//deletemsg /output/Vdend  0 -in
//reset


//end
//end // for n=...








