//genesis

/*********************************************************************/
 /**begin to draw :) **/

// function make_xcell(xcell,tmax)

//  str xcell
//  float tmax

//  create xform /{xcell} [200,50,800,800]
//  create xlabel /{xcell}/label [10,0,95%,25] \
//         -label " CA1 SPINE"  \
//         -fg    red
//  create xgraph /{xcell}/v [10,10:label.bottom, 50%, 45%] \
//         -title "Memberaine Potential"  \
//         -bg    white

//  create xgraph /{xcell}/syncurrents [10,10:v.bottom,50%,45%] \
//         -title "Synaptic currents"  \
//         -bg    white 
//  create xgraph /{xcell}/Ca [10:v.right,10:label.bottom,50%,45%] \
//         -title "Calcium Concentration" \
//         -bg    white
//  create xgraph /{xcell}/channels [10:syncurrents.right,10:Ca.bottom,48%,45%] \
//         -title "Channel Currents" \
//         -bg    white

//   setfield /{xcell}/v      xmax {tmax+0.8}   ymin -0.1 ymax 0.05
//   setfield /{xcell}/Ca         xmax {tmax+0.8}   ymin 1e-6 ymax 1e-2
//   setfield /{xcell}/syncurrents   xmax {tmax+0.8}  ymin 0 ymax 5.0e-12
//   setfield /{xcell}/channels   xmax {tmax+0.8}  ymin -1e-9  ymax 1e-9



//   useclock /{xcell}/v 1
//   useclock /{xcell}/Ca        1 
//   useclock /{xcell}/syncurrents  1
//   useclock /{xcell}/channels  1
//   xshow /{xcell}
//     reset
// end

function make_xcells(xcell, label, title1,title2,title3,title4,tmin,tmax)

 str xcell,label, title1,title2,title3,title4
 float tmin,tmax

 create xform /{xcell} [200,50,800,800]
 create xlabel /{xcell}/{label} [10,0,95%,25] \
        -label {label}  \
        -fg    red
 create xgraph /{xcell}/{title1} [10,10:{label}.bottom, 50%, 45%] \
        -title {title1}  \
        -bg    white

 create xgraph /{xcell}/{title2} [10,10:{title1}.bottom,50%,45%] \
        -title {title2}  \
        -bg    white 
 create xgraph /{xcell}/{title3} [10:{title1}.right,10:{label}.bottom,50%,45%] \
        -title {title3} \
        -bg    white
 create xgraph /{xcell}/{title4} [10:{title2}.right,10:{title3}.bottom,48%,45%] \
        -title {title4} \
        -bg    white

  setfield /{xcell}/{title1}            xmin {tmin} xmax {tmax}  
  setfield /{xcell}/{title2}            xmin {tmin} xmax {tmax}  
  setfield /{xcell}/{title3}            xmin {tmin} xmax {tmax}
  setfield /{xcell}/{title4}            xmin {tmin} xmax {tmax}



  useclock /{xcell}/{title1} 1
  useclock /{xcell}/{title2}  1 
  useclock /{xcell}/{title3}  1
  useclock /{xcell}/{title4}  1
  xshow /{xcell}
  reset
end


function make_VerticalXcells(xcell, label, allTitles,tmin,tmax)

 str xcell,label, allTitles,title1,title_old
 float tmin,tmax, height
 int num,n0

 echo allTitles is {allTitles}
 num = {getarg {arglist {allTitles}} -count}    // number of the xgraphs that is going to draw 
 n0 = 1
 height = 90.0/num 

 create xform /{xcell} [620,50,400,400]
 create xlabel /{xcell}/{label} [10,0,100%,5] \
        -label {label}  \
        -fg    red

  
 foreach title1 ({arglist {allTitles}})
     echo title1 is {title1}
     if (n0 == 1 )
      create xgraph /{xcell}/{title1} [10,10:{label}.bottom, 95%, {height}%] \
                                      -title {title1}  \
                                      -bg    white
     else 
     title_old = {getarg {arglist {allTitles}} -arg {(n0-1)}}
     echo title_old is {title_old} and n0 is {n0}
     create xgraph /{xcell}/{title1} [10,10:{title_old}.bottom, 95%, {height}%] \
                                      -title {title1}  \
                                      -bg    white
    end     // end of if....

  setfield /{xcell}/{title1}            xmin {tmin} xmax {tmax}  
  useclock /{xcell}/{title1} 1
  n0 = n0+1
 end     // foreach...
  xshow /{xcell}
  reset
end



function record_channel(cellpath,compt,channel,xcell,label, name,color,ymin,ymax)
 str cellpath,compt,xcell,channel, path, color,label,name
 int chanmode                         // hsolve : 1
                                     // normal : 0
 float ymin,ymax
//  echo the cellpath is {cellpath}
//  echo the compatment is {compt}
//  echo the ion channel is {channel}
//  echo the xcell is {xcell}
//  echo th chanmode is {chanmode}

 if(!{exists {cellpath}})
   echo the cell {cellpath} does not exist! Please check the cellpath
   return
 end

 if(!{exists {cellpath}/{compt}})
   echo the compartment {cellpath}/{compt} does not exist! 
   return
 end

 if(!{exists {cellpath}/{compt}/{channel}})
   echo the channel {cellpath}/{compt}/{channel} does not exist! 
   return
 end

 if(!{exists /{xcell}})
   echo the xcell {xcell} does not exist! 
   return
 end

 if (!{isa xform /{xcell}})
   echo the xcell is not the "xform" object that we want!!
   return
 end

          path = {cellpath}@"/"@{compt}@"/"@{channel}

       //  if ({channel}=="Ca_difshell_1"||{channel}=="Ca_difshell_2"||{channel}=="Ca_difshell_3")
  
          if( {isa difshell {path}})
                  addmsg {cellpath}/{compt}/{channel} /{xcell}/{label} PLOT C  *{path}  *{color}
                  echo add {path} successfully!
          elif( {isa Ca_concen {path}})
                  addmsg {cellpath}/{compt}/{channel} /{xcell}/{label} PLOT Ca  *{path}  *{color}
                  echo add {path} successfully!
       //   end
        else  // for synaptic and ion channels

         addmsg {cellpath}/{compt}/{channel} /{xcell}/{label} PLOT Ik *{name} *{color}
          echo add {path} successfully!
  
          end 


   setfield /{xcell}/{label}            ymin {ymin} ymax {ymax} 


end

function record_channel_Gk(cellpath,compt,channel,xcell,label, color,ymin,ymax)
 str cellpath,compt,xcell,channel, path, color,label
 int chanmode                         // hsolve : 1
                                     // normal : 0
 float ymin,ymax
//  echo the cellpath is {cellpath}
//  echo the compatment is {compt}
//  echo the ion channel is {channel}
//  echo the xcell is {xcell}
//  echo th chanmode is {chanmode}

 if(!{exists {cellpath}})
   echo the cell {cellpath} does not exist! Please check the cellpath
   return
 end

 if(!{exists {cellpath}/{compt}})
   echo the compartment {cellpath}/{compt} does not exist! 
   return
 end

 if(!{exists {cellpath}/{compt}/{channel}})
   echo the channel {cellpath}/{compt}/{channel} does not exist! 
   return
 end

 if(!{exists /{xcell}})
   echo the xcell {xcell} does not exist! 
   return
 end

 if (!{isa xform /{xcell}})
   echo the xcell is not the "xform" object that we want!!
   return
 end

          path = {cellpath}@"/"@{compt}@"/"@{channel}
     

         addmsg {cellpath}/{compt}/{channel} /{xcell}/{label} PLOT Gk *{channel} *{color}
          echo add {path} successfully!


   setfield /{xcell}/{label}            ymin {ymin} ymax {ymax} 


end


function record_voltage (cellpath, compt, xcell,title,volt_label,color,ymin,ymax,chanmode)
 str cellpath,compt,xcell,path,path1,color,title,volt_label
 int chanmode
 float ymin,ymax
 if(!{exists {cellpath}})
   echo the cell {cellpath} does not exist! Please check the cellpath
   return
 end

 if(!{exists {cellpath}/{compt}})
   echo the compartment {cellpath}/{compt} does not exist! 
   return
 end

 if(!{exists /{xcell}})
   echo the xcell {xcell} does not exist! 
   return
 end

 if (!{isa xform /{xcell}})
   echo the xcell is not the "xform" object that we want!!
   return
 end

 if ({{chanmode} == 1} || {chanmode}==0 )
    path = {getpath {compt} -tail}
    addmsg {cellpath}/{compt} /{xcell}/{title} PLOT Vm *{volt_label} *{color}
 elif ({chanmode} == 4)
    path = {getpath {compt} -tail}  
    path1 = {findsolvefield {cellpath}/solve {path} Vm}
    addmsg {cellpath} /{xcell}/{title} PLOT {path1} *{volt_label} *{color}
  else

     echo The function record_channel currently does not support the chanmode {chanmode}!
     echo only chanmode 0, 1 and 4 are available!
     return
 end 

  setfield /{xcell}/{title}            ymin {ymin} ymax {ymax} 
 echo the title is {title}
end

function increaseXcellDia(cellpath,compt_list,factor)
str cellpath,compt_list,compt
float dia,factor,dia_new
 foreach compt ({arglist {compt_list}})
  compt = {cellpath}@"/"@{compt}
  dia = {getfield {compt} dia}
  dia_new = dia*factor
  setfield {compt} dia {dia_new}
  //echo   the old dia of {compt} is {dia} and the new dia is {dia_new}
 end
end




function makeColorCode(cellpath,compt_list,field,value)
str cellpath,compt_list,compt,field
float value
 foreach compt ({arglist {compt_list}})
  compt = {cellpath}@"/"@{compt}
  setfield {compt} {field} {value}
 end
end







// the file contains many numbers (such as "Ri") as the color codes
// "the_num": which specific line in the file should be taken as the color code?
function readColorData(cellpath,compt_list,field,filepath,the_num) 
str cellpath,compt_list,compt,field,filepath
int the_num,n0
float value
foreach compt ({arglist {compt_list}})
 n0 = 1
  openfile {filepath}/{compt}".txt" r
    while(n0<=the_num)
    value = {readfile {filepath}/{compt}".txt"} 
    if (n0 == the_num)
    setfield {cellpath}/{compt} {field} {value}
    end
    n0 = n0+1
    end   // end of while
  closefile {filepath}/{compt}".txt"
  //echo the {compt} field {field} is {value}  
end   // end of foreach
end




function makeSpheres(cellpath, compt_list,xdrawPath,xsphere_name,color,dia)
str cellpath,compt_list,compt,color,xsphere_name 
float x,y,z,dia
int i=1
pushe {xdrawPath}
foreach compt ({arglist {compt_list}}) 
x = {getfield {cellpath}/{compt} x}
y = {getfield {cellpath}/{compt} y}
z = {getfield {cellpath}/{compt} z}
if ({exists {xsphere_name}"_"{i}})
delete {xsphere_name}"_"{i}
end
create xsphere {xsphere_name}"_"{i} -fg {color} -tx {x} -ty {y} -tz {z} -r {dia}
i=i+1
end // end of foreach

pope
end

// delete the existed spheres first
function makeSpheres_del(cellpath, compt_list,xdrawPath,xsphere_name,color,dia)
str cellpath,compt_list,compt,color,xsphere_name 
float x,y,z,dia
int i=1

if ({exists {xdrawPath}/xphere})
delete {xdrawPath}/xphere
end

create neutral {xdrawPath}/xphere

pushe {xdrawPath}/xphere
foreach compt ({arglist {compt_list}}) 
x = {getfield {cellpath}/{compt} x}
y = {getfield {cellpath}/{compt} y}
z = {getfield {cellpath}/{compt} z}
if ({exists {xsphere_name}"_"{i}})
delete {xsphere_name}"_"{i}
end
create xsphere {xsphere_name}"_"{i} -fg {color} -tx {x} -ty {y} -tz {z} -r {dia}
i=i+1
end // end of foreach

pope
end




function plotActiveSynByTime(cellpath,spikeList,drawPath,xsphere_name,color,dia,tmin,tmax,ISI)
str spikeList, drawPath, list, list1,cellpath,xsphere_name,color
float tmin,tmax,ISI, dur, dt , t0,t1,dia
int maxN,n
dur = tmax - tmin
int maxN = dur/ISI

for (n=1;n<=maxN;n=n+1)
t0 = tmin+(n-2)*ISI
t1 = tmin +(n-1)*ISI
echo t0 is {t0}, t1 is {t1} 
list1 = ""
  foreach list ({arglist {spikeList}})
list1=list1@" "@{findActivatedRandSyn {list} {t0} {t1}}
  end   // end of foreach...
makeSpheres_del {cellpath} {list1} {drawPath} {xsphere_name} {color} {dia} 
echo list1 is {list1}
step {ISI} -time
end    // end of for ...
end
