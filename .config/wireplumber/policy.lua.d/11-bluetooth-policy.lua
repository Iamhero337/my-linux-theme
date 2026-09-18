if bluetooth_policy and bluetooth_policy.policy then
  bluetooth_policy.policy["media-role.use-headset-profile"] = true
  bluetooth_policy.policy["use-persistent-storage"] = true
end
if default_policy and default_policy.policy then
  default_policy.policy["move"] = true
  default_policy.policy["follow"] = true
end
