def merb_model_mock(name, params={})
  mock(name, {
    :new_record?       => false,
    :id                => '1',
    :attribute_loaded? => true
  }.merge(params))
end
