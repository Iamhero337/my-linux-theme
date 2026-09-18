table.insert(bluez_monitor.rules, {
  matches = {
    {
      { "node.name", "matches", "bluez_input.*" },
    },
    {
      { "node.name", "matches", "bluez_output.*" },
    },
  },
  apply_properties = {
    ["priority.driver"] = 5000,
    ["priority.session"] = 5000,
  },
})

table.insert(bluez_monitor.rules, {
  matches = {
    {
      { "device.name", "matches", "bluez_card.*" },
    },
  },
  apply_properties = {
    ["bluez5.auto-connect"] = "[ hfp_hf hsp_hs a2dp_sink hfp_ag hsp_ag a2dp_source ]",
  },
})
