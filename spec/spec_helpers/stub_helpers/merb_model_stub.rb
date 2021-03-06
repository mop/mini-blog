# This is a simple helper method for mocking database models. It stubs the
# following methods:
# [new_record?] => false
# [id] => '1'
# [attribute_loaded] => true
# [reload] => true
#
# You might consider overwriting or adding other stubs via the optional
# params-hash
#
# ==== Parameters
# name<String>::
#   The name of the mock
# params<Hash>::
#   A hash whith optional methods which should be stubbed
#
# ==== Returns
# Spec::Mocks::Mock::
#   A newly created mock will be returned
def merb_model_mock(name, params={})
  tmp = mock(name, {
    :new_record?       => false,
    :id                => '1',
    :attribute_loaded? => true,
    :reload            => true
  }.merge(params))
  # Bugfix for identifiers checking
  def tmp.is_a?(klass)
    return true if klass == DataMapper::Resource
    self.class::is_a?(klass)
  end
  tmp
end
