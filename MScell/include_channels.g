//genesis
//include_channels.g
/*******
AB: removed CaNNOINACT_channel and CaL12NOINACT_channel by combining with inactivating channels
AB: deleted CaQ because no evidence for such in SP, and doesn't contribute much anyway
AB: Also, removed KRP channels from here because we're not using them
AB: no longer making naP in the library since it is not used, and has been moved to a different directory
**********/

include MScell/channels/tabchanforms.g
//calcium channels
include MScell/channels/CaL12inact_channel
include MScell/channels/CaL13_channel
include MScell/channels/CaNinact_channel
//include MScell/channels/CaQ_channel
include MScell/channels/CaR_channel
include MScell/channels/CaT_channel

//voltage dependent channels
include MScell/channels/naF_chanOg
include MScell/channels/NaP_channel
include MScell/channels/kAf_chanRE
include MScell/channels/kIR_chanKD
include MScell/channels/kAs_chanRE
include MScell/channels/K_DR_channel

//calcium dependent potassium channels
include MScell/channels/BKKchannel
include MScell/channels/SKchannelCaDep

// NMDA/AMPA channel prototype taken from the old MS model
include MScell/ampa_channel_ghkCa
include MScell/nmda_channel_ghkCa
include MScell/channels/gaba_channel.g

