//genesis


/* AB: Comments indicate the qfactor used with the various channels
*  conductance of CaN and CaL12 sum the inactivating and non-inactivating channel
*  conductances from the previous model
*/
        float ELEAK = -0.07 // 
        float Egaba = -0.06  
        float PI = 3.1415926
        float RA = 4.0;
        float RM = 1.8;           // 
        float CM = 0.01;
        float EREST_ACT = -0.086
 	float TEMPERATURE = 35
        float temperature = 35   // some old MS commands need it
        float Cout        = 2    // 2, (mM), external Calcium concentration   
        float CMg_spine   = 1    // mM, [Mg]2+ on spine head. 
        float CMg         = 1    // Mg for synaptic 
	str  CA_BUFF_1 = "Ca_difshell_1"     // L and T type channels
	str  CA_BUFF_2 = "Ca_difshell_2"     // coupled to the other channels
	str  CA_BUFF_3 = "Ca_difshell_3"     // all calcium channels
	
	int CaDyeFlag = 0   // flags of calcium dye. "0" means NO calcium dyes.
                     // flag =2 : Fluo-4
                     // flag =3 : Fluo-5F
	int shellMode = 1     // we  have two shell-modes:
                     //  mode = 0 : detailed multi-shell model, using "difshell" object
                     //  mode = 1 : simple calcium pool adopted from  Sabatini's work(Sabatini, 2001, 2004)

/******* Conductances for synapses****************/
       float AMPAcond = 170e-12*0.8    //*2.5
       float NMDAcond = 470e-12*0.8

/******* Conductance for spines*********************/
       float AMPAcond2 = 170e-12*2 //*6.5 for plateau
       //float NMDAcond2 = 170e-12*6.5*f1 //*2.5
       float NMDAcond2 = 470e-12*4 //*6.5
       int setSynBoundary = 100   //3.3, Carter and Sabatini, 2004, Neuron. max EPSCs = 30 pA

/******* Conductance for "add_Rand_ClusterExSynapse"*********************/
       float AMPAcond3 = 170e-12*1.5//
       float NMDAcond3 = 470e-12*1.5 //



//parameters determined by hand tuning to match spike width, AHP shape &amp, fI curve

        float gNaFprox={90000}*1.2 //*1.2, 
        float gNaFmid= {975}*0.3  // X0.5, 
     

        float gNaFdist={975}*0.1  // 0.1


        float gNaPprox = 0.4
        float gNaPdist = 0.4

       
        float gKAfprox={3214}*1.8 //1.1,1.5 
        float gKAfmid={375}*1.5 //1.2
        float gKAfdist={375}*1.0 // *0.4

        float gKAsSoma={277}*2 //2.6, qfactor=2, 3.5	 
        float gKAsprox={22.9}*1// 0.1
        float gKAsdist={22.9}*1// 0.1

        float gKIRsoma= 4.2*4     //4, qfactor = 0.5;   gKIR=4.2
        float gKIRdist= 4.2*3
        float gKDRsoma={7.25}*3 //*13, qfactor = 0.5  
        float gKDRdist={7.25}*1 // 0.1

	float gCaL13 = 1.0625e-8  //qfactor=2
/********************************************************************************
********** "gCaV33  =  0.5875e-8*0.6 gCaV32  =  0.5875e-8*0.3" 
**********  generating ~78 pA current via whole-cell recording
***********************************************************************************/  
	float gCaV33  =  0.5875e-8*0.3// 0.1  CaT in the dendrites 
       float gCaV32  =  0.5875e-8*0.5*0.6  // 0.1
/********************************************************************************
*********************************************************************************/

      float gCaT  =  0.5875e-8*10    // not using now
	float gCaR  =  6.5e-8*10         //*10; 
                                          // 6.5e-8*10 = 688 pA whole cell CaR (clamping from -100mV to -10 mV)
//	float gCaQ  =  1.5e-7
	float gCaN =   2.5e-7*2      //qfactor=2
	float gCaL12 = 0.8375e-7    //qfactor=2

/************************* spine **************************************************/
float kk = 0.2
       float Pbar_CaV32         =    kk*2*0.235e-7   // 2*,CaT in the spines
//       float Pbar_CaT       =    5*0.235e-7   // CaT in the spines
       float Pbar_CaV33        =    kk*5*0.235e-7   //5*,
       float Pbar_CaR         =    kk*3*13e-7
/**********************************************************************************************/
