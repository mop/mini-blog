#module Merb
#  class Request
#    alias old_handle handle
#
#    def handle(*args, &block)
#      __profile__("request", 1, 1) do 
#      	old_handle(*args, &block)
#      end
#    end
#  end
#end
