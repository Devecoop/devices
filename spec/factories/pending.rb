Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do
  factory :pending do
    uri Settings.pending.uri
    device_uri Settings.device.uri
    function_uri Settings.functions.set_intensity.uri
    function_name Settings.functions.set_intensity.name
  end

  factory :pending_complete, parent: :pending do |p|
    p.pending_properties {[
      Factory.build(:pending_property_intensity),
      Factory.build(:pending_property_status)
    ]}
  end
  
  factory :closed_pending, parent: :pending_complete do |p|
    uri Settings.pending_closed.uri
    pending_status false
  end

  factory :not_owned_pending, parent: :pending_complete do |p|
    device_uri Settings.another_device.uri
  end

  factory :pending_property_intensity, class: :pending_property do
    uri Settings.properties.intensity.uri
    value Settings.properties.intensity.new_value
    old_value Settings.properties.intensity.default_value
  end

  factory :pending_property_status, class: :pending_property do
    uri Settings.properties.status.uri
    value Settings.properties.status.new_value
    old_value Settings.properties.status.default_value    
  end
end
