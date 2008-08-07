# This is a simple helper method for mocking database models. It stubs the
# following methods:
# [new_record?] => false
# [id] => '1'
# [attribute_loaded] => true
# [reload] => true
#
# You might consider overwriting or adding other stubs via the optional
# params-hash
def merb_model_mock(name, params={})
  mock(name, {
    :new_record?       => false,
    :id                => '1',
    :attribute_loaded? => true,
    :reload            => true
  }.merge(params))
end
