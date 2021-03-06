// to parse the morphology data, then calculate the distance from the soma
// implemented by Kai Du, kai.du@ki.se 



function findChildrenElements (parent)
str parent, msgtype , list
int num1,num2, numRaxial,numAxial, i
list = ""

num1 = {getmsg {parent} -out -count}                  // count the total outcoming msgs numbers
num2 = {getmsg {parent} -in -count}                   //                 incoming 

// this is the ending compartment, 
// so it has NO child comparment and return -1  
if ((num1==1) && (num2==1))                               
  return {list}
end

// if it is not the ending compartment
             
 for (i=0;i< num1 ; i=i+1)
    msgtype = {getmsg {parent} -out -type {i}}           // find the msg-type corresponding to the msg-index number 
    if ({msgtype} == "AXIAL" )                           // we only need the msg sending to its "child" compartments
        list = {list}@" "@{getmsg {parent} -out -destination {i}}         // note: we need a SPACE !!
    end  // end of if
   
  end // end of for
 
 return {list}


end

function deleteLastNode(nodelist)
str nodelist, list, node
int num,i
 list = ""
 num = {getarg {arglist {nodelist}} -count}
 if({num == 0})
  echo the nodelist is NULL
  return
 // elif({num} == 1)
 //  return {list}

 else
  for (i=1;i<num;i=i+1)
       node = {getarg {arglist {nodelist}} -arg {i}}
       list = {list}@" "@{node}
  end
    return {list} 
 end
end  
   
function findDistance(parent,child)
str parent, child
float len,position1,position2
 len = {getfield {child} len}
// echo the len is {len}
 position1 = {getfield {parent} position}
 position2 = {position1} + {len}
 setfield {child} position {position2}
end


// Depth-first searching
function SetPosition(somapath)
str somapath,parent,child, listofBranches,list2, nodes, node1
int num1,num2,num3,i,flag
float position1,len,len2
//float x,y,z 
 if (!{exists {somapath}})
  echo The current input {somapath} does not exist! 
  return
 end 
 
// listofBranches = {findChildrenElements {somapath}}
 
//foreach compt ({arglist {listofBranches}})
//  echo now is  {compt} in foreach
  nodes =""      // start from the root
  flag = 1
  num2 = 1       // NUMBER of the nodes
  num1 = 1       // NUMBER of the Child-compartment(s)
  parent = {somapath} // Parent-compartment

  len2 = {getfield {somapath} dia}
  setfield {somapath} position {len2}  //initialize the soma position
  
// if there is any node in the list:

int n=1
// while  ({n}<=55)
//    echo ""
//    echo ""
//    echo the {n}th loop
//    echo the parent compt is {parent} and the number of nodes is {num2}

   while ({num2}>0)
//  echo ""
 // echo the parent compt is {parent} and the number of nodes is {num2}
  //we first find what is/are the next child compartment(s)                                         
  list2 = {findChildrenElements {parent}}
 // echo the child compartment of {parent} is {list2}
  // count the total number of child-compartment(s)
  num1 =  {getarg {arglist {list2}} -count}
 // echo num1 is {num1}
/***************************************************/
/***if this is an ending compartment, we do:********/
/***************************************************/   
  if ({num1} == 0 )
      parent = {getarg {arglist {nodes}} -arg {num2}}     // switch to the last node in the list
    //  echo there are {num2} nodes in the list
    //  echo {child} is an end compartment, so it switches to {parent}  
         

/*****************************************************/  
 // if this is a single child compartment, we do:
/*****************************************************/
  elif ({num1} == 1)                                  
    child =  {arglist {list2}}                              
    findDistance {parent} {child}                       // (1) calculation of distance
    parent = {child}                                      // (2) update the parent compartment
   // echo this is a single compt, so it switches to next one

/********************************************************/
 // if this is a bifurcation
/*******************************************************/
  elif ({num1} > 1)   
    i=1                                 
    child = {getarg {arglist {list2}} -arg {i}}         // we choose the first one
   // echo we now work on {child}!!
    position1 = {getfield {child} position} 
   //adding this node into the node-list if the first child-compartment is not visited       
    if ({position1} ==0)
     //  echo the {child} has not been visited!
       nodes = {nodes}@" "@{parent} 
     //  echo add the parent nodes {parent} into the node-list
       findDistance {parent} {child}
       parent = {child}
      // echo updated parent compartment {parent}                      
    end
   // if this compartment has already been visited, then move to the next one
   // "position > 0"  meaning this one has been visited
        
        while({ position1 > 0}&&({i}<={num1}))
             //  echo {child} has been visited  
             //  echo i is {i} and num1 is {num1}
               if({i<num1})
                 child =  {getarg {arglist {list2}} -arg {i+1}}  // moving to the next branch by updating "i"
                 position1 = {getfield {child} position} 
                // echo we pick up {child} and its parent is {parent}
                 if ({position1}==0)
                     findDistance {parent} {child}
                     parent = {child}
                 end
                
               elif({i==num1})
                // echo the nodes before deletion are {nodes} and the current visiting compt is {child} 
                 nodes = {deleteLastNode {nodes}}                   // delete the current node 
               //  echo now the nodes left are {nodes}
                 num2 =  {getarg {arglist {nodes}} -count}          // update num2
                   if({num2}>0)
                     parent = {getarg {arglist {nodes}} -arg {num2}}     // switch to the last node in the list
                   end
               end // end of if
              i=i+1 
             

         end   // end of while
   
     end  // end of if  
   num2 =  {getarg {arglist {nodes}} -count}
  end // end of while


  //n=n+1
  //end

//  end // end of foreach

end


function checkSet(cellpath)
str cellpath,compt, badCompts
float position1
int i=0
 badCompts = ""

 foreach compt ({el {cellpath}/##[TYPE=compartment]})
    position1 = {getfield {compt} position}
  if ({position1}==0)
     badCompts = {badCompts}@" "@{compt}
     i=i+1
  end
 end  
 
//return {i}
return {badCompts}
end

//####################################################################################################

function add_exSyns_evenly(cellpath,a,b,number)
// number: num of AMPA/NMDA per compartment
str cellpath,compt,NMDAname,AMPAname
float a,b,position
int number,i

float AMPAcond = 170e-12
float NMDAcond = 470e-12


str buffer1 = "Ca_difshell_1"           // name of the calcium pool in the spine
str buffer2   = "Ca_difshell_2" 
str buffer3 = "Ca_difshell_3"          // only to record NMDA-dependent [Ca]

foreach compt ({el {cellpath}/##[TYPE=compartment]})
    position={getfield {compt} position} 
    if ({position>=a} && {position<b} ) 
    
   for(i=1;i<=number;i=i+1)
     NMDAname   = "NMDAghk"@"_"@{i}
     AMPAname   = "AMPAghk"@"_"@{i}
     addAMPAchannelGHKCa  {compt}  {AMPAname} {buffer1} {AMPAcond}
     addNMDAchannelGHKCa  {compt}  {NMDAname} {buffer1} {NMDAcond}
     if({exists /spikes/input_train/spike  })
        addmsg /spikes/input_train/spike {compt}/{NMDAname} SPIKE
        addmsg /spikes/input_train/spike {compt}/{NMDAname} SPIKE
     end  // end of if ({exists /spikes/input_train/spike  }) 
   end    // end of for...

   end // end of if({position>=a} && {position<b} ) 

end    // end of foreach...

end


//##########################################################################################################

function adjustCellForSpines(cellpath,a,b, F,F2 ) 
/***** The dendritic length and diameter of compartments are adjust for spines*************
********** L = l* F^(2/3); D = d* F^(1/3)***************************************************
************ the factor "F" is calculated by: F = A_dend+A_spines/A_dend********************
**ref: NMDA/AMPA Ratio Impacts State Transitions and Entrainment to Oscillations in a Computational Model of the Nucleus Accumbens Medium Spiny Projection Neuron. Wolf, et.al.2005 
*/
str cellpath, compt
float a,b,position,dia,len,dia2,len2,Rm,Cm,Ra,Rm2,Cm2,Ra2,F,F2, Dsurf

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

foreach compt ({el {cellpath}/##[TYPE=compartment]})
	
		//************** Begin external if statement*****************************
 		if (!{{compt} == {{cellpath}@"/axIS"} || {compt} == {{cellpath}@"/ax"}}) 
    		dia = {getfield {compt} dia}
    		position = {getfield {compt} position}
              //  echo the position of this compt is {position}
     		len = {getfield {compt} len}
                Rm = {getfield {compt} Rm}
 		Cm = {getfield {compt} Cm}
		Ra = {getfield {compt} Ra}
    		if ({{getpath {compt} -tail} == "soma"})
              len = dia
   		end
   		
   		//************** Begin internal if statement**************************
  			//if the compartment is not a spine and its position is between [a,b] 
   		if ({position >= a} && {position < b} ) 
                len2 = len*{pow {F} {2.0/3.0}}
                dia2 = dia*{pow {F} {1.0/3.0}}
                   Rm2 = Rm*(dia*len/(dia2*len2))
                    //  echo the old Rm is {Rm} and the new Rm is {Rm2}
                    Cm2 = Cm*(dia2*len2/(dia*len))
                   //Cm2 = Cm*10
                    //  echo the old Cm is {Cm} and the new Cm is {Cm2}
                     if ({position} >= 30e-6)
                   Ra2 = Ra*(len2*dia*dia/(len*dia2*dia2))*F2                        // "*4" as in Surmeier's paper
                      else 
                       Ra2 = Ra
                        end
			// echo the old Ra is {Ra} and the new Ra is {Ra2}
                setfield {compt} dia {dia2}
                setfield {compt} len {len2}
                setfield {compt} Rm {Rm2}
                setfield {compt} Cm {Cm2}
                setfield {compt} Ra {Ra2}
                end
               end                                     
end                                                   // end of foreach...

end


function set_colors(cellpath, compt_list,color_values)  
str cellpath, path, compt, compt_list
float color_values 
foreach compt ({arglist {compt_list}}) 
  path = {cellpath}@"/"@{compt}
  setfield {path} color {color_values}
 end

end



