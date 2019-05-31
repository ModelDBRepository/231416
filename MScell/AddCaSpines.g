 //function to add calcium channels to spines 
function addCaChannelspines(channelName, compPath, conductance, caBufferName)
  str channelName, compPath
  float conductance
  str caBufferName

  pushe {compPath}

    // Copy the channel from library
    copy /library/{channelName} {channelName}
    copy /library/{channelName}GHK {channelName}GHK

    // Set the new conductance
    float len = {getfield {compPath} len}
    float dia = {getfield {compPath} dia}
    float pi = 3.141592653589793
    float surf = {len*dia*pi} 

    // echo "Channel: "{channelName}", conductance "{conductance}"S/m²"
    // echo "Compartment: "{compPath}", surface area "{surf}"m²"
    setfield {channelName} Gbar {conductance*surf}

    // Couple channel to caBuffer

coupleCaBufferCaChannel {caBufferName} {compPath} {channelName}

    // Couple channel, its GHK object and compartment together
    addmsg {compPath} {channelName}GHK VOLTAGE Vm
    addmsg {compPath} {channelName} VOLTAGE Vm
    addmsg {channelName}GHK {compPath} CHANNEL Gk Ek
    addmsg {channelName} {channelName}GHK PERMEABILITY Gk

//     float len = {getfield {compPath} len}
//     float dia = {getfield {compPath} dia}
//     float pi = 3.141592653589793
//     float surf = {len*dia*pi}

//     // echo "conductance (unscaled): "{conductance}
//     // echo "Compartment: "{compPath}" surface area "{surf}"m²"
//     setfield {channelName} Gbar {conductance*surf}

  pope

end
