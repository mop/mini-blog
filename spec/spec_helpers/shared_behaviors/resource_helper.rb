# TODO
# * Refactor each group into an separate module, because the file is actually
#   very long and the flog-results are _very_ bad, because of nesting blocks
#   into methods :(.

# This module contains the single magic it_should_be_resourceful method, which
# generates tests for your controller on the fly. If you are browsing this code
# with your text-editor make shure you have folding enabled, because otherwise
# you'll definitely loose the overview over this module :/
module ResourceHelper
  module ResourceHelperGroupMethods
    ######################### index ##########################################
    # Specs for the index action of the controller
    def index_specs(params)
      if params[:auth_actions].include? :index
        index_auth_specs(params)
      end
      index_regular_specs(params)
    end

    def index_auth_specs(params)
      @params = params
      describe controller_class, "unauthorized index action" do
        def do_get
          dispatch_to(controller_class, :index, no_id_params) do |controller|
            controller.stub!(:render)
          end
        end

        it 'should not fetch the from the database' do
          model_class.should_not_receive(:all)
          do_get
        end
      end
    end
    
    def index_regular_specs(params)
      describe controller_class, "index action" do
        before(:each) do
          @items = []
        end

        def do_get
          dispatch_to(controller_class, :index, no_id_params) do |controller|
            controller.stub!(:render)
            controller.stub!(auth_method).and_return(true)
          end
        end
        
        it 'should fetch all items from the database' do
          model_class.should_receive(:all).and_return(@items)
          do_get
        end

        it 'should assign items' do
          model_class.stub!(:all).and_return(@items)
          do_get.assigns(items_name).should eql(@items)
        end

        it 'should be successful' do
          model_class.stub!(:all).and_return(@items)
          do_get.should be_successful
        end
      end
    end

    ############################### show #####################################
    # Specs for the show action of the controller
    def show_specs(params)
      if params[:auth_actions].include? :show 
        show_auth_specs(params)
      end
      show_regular_specs(params)
    end

    def show_auth_specs(params)
      describe controller_class, "unauthorized show action" do
        def do_get
          dispatch_to(controller_class, :show, no_id_params) do |controller|
            controller.stub!(:render)
          end
        end

        it 'should not fetch the from the database' do
          model_class.should_not_receive(:get)
          do_get
        end
      end
    end
    
    def show_regular_specs(params)
      describe controller_class, "show action" do
        before(:each) do
          @item = merb_model_mock('item')
        end

        def do_get
          dispatch_to(controller_class, :show, id_params(1)) do |controller|
            controller.stub!(:render)
            controller.stub!(auth_method).and_return(true)
          end
        end

        it 'should fetch the correct element on get' do
          model_class.should_receive(:get).with('1').and_return(@item)
          do_get
        end
        
        it 'should be successful' do
          model_class.stub!(:get).and_return(@item)
          do_get.should be_successful
        end
        
        it 'should assign the item variable' do
          model_class.stub!(:get).and_return(@item)
          do_get.assigns(item_name).should eql(@item)
        end
      end
    end

    ######################### new ############################################
    # Specs for the new action of the controller
    def new_specs(params)
      if params[:auth_actions].include? :new
        new_auth_specs(params)
      end
      new_regular_specs(params)
    end

    def new_auth_specs(params)
      describe controller_class, 'new page' do
        def do_get
          dispatch_to(controller_class, :new, no_id_params) do |controller|
            controller.stub!(:render)
          end
        end

        it 'should not be successful' do
          do_get.assigns(item_name).should be_nil
        end
      end
    end

    def new_regular_specs(params)
      describe controller_class, 'new page authorized' do
        def do_get
          dispatch_to(controller_class, :new, no_id_params) do |controller|
            controller.stub!(:render)
            controller.stub!(auth_method).and_return(true)
          end
        end

        it 'should be successful' do
          do_get.should be_successful
        end

        it 'should assign the item-variable' do
          model_class.stub!(:new).and_return(:true)
          do_get.assigns(item_name).should eql(:true)
        end

        it 'should create a new item' do
          model_class.should_receive(:new)
          do_get
        end
      end
    end
    
   
    ######################### create #########################################
    # Specs for the create action of the controller
    def create_specs(params)
      if params[:auth_actions].include? :create
        create_auth_specs(params)
      end
      create_regular_specs(params)
    end

    def create_auth_specs(params)
      describe controller_class, 'unauthorized create' do
        def do_post(params={})
          tmp = valid_attributes(params)

          dispatch_to(
            controller_class,
            :create,
            hash_params(item_name => tmp)
          ) do |controller|

            controller.stub!(:render)
            yield controller if block_given?
            controller
          end
        end

        it 'should not be successful' do
          model_class.should_not_receive(:create)
          do_post
        end
      end
    end

    def create_regular_specs(params)
      describe controller_class, 'create' do
        before(:each) do
          stub_nested_get if nested?
        end
        
        def do_post(params={})
          tmp = valid_attributes(params)

          dispatch_to(
            controller_class,
            :create,
            hash_params(item_name => tmp)
          ) do |controller|

            controller.stub!(:render)
            controller.stub!(auth_method).and_return(true)
            yield controller if block_given?
            controller
          end
        end

        def item_mock(flag=true) 
          tmp = merb_model_mock('item', :valid? => flag)
          stub_nested(tmp) if nested?
          tmp
        end

        it 'should create the item' do
          model_class.should_receive(:create).with(hash_including(
            update_attributes
          )).and_return(item_mock)
          do_post
        end

        it 'should redirect the the user on success' do
          model_class.stub!(:create).and_return(item_mock)
          do_post.should redirect_to(redirect_create_path)
        end

        it 'should display the new page again on failure' do
          model_class.stub!(:create).and_return(item_mock(false))
          do_post.should be_successful
        end
      end
    end


    ########################## edit ###########################################
    # Specs for the edit action of the controller
    def edit_specs(params)
      if params[:auth_actions].include? :edit
        edit_auth_specs(params)
      end
      edit_regular_specs(params)
    end

    def edit_auth_specs(params)
      describe controller_class, 'unauthorized edit' do
        def do_get
          dispatch_to(controller_class, :edit, id_params(1)) do |controller|
            controller.stub!(:render)
          end
        end

        it 'should not edit the item' do
          model_class.should_not_receive(:get)
          do_get
        end
      end
    end
    
    def edit_regular_specs(params)
      describe controller_class, 'authorized edit' do
        def do_get
          dispatch_to(controller_class, :edit, id_params('1')) do |controller|
            controller.stub!(:render)
            controller.stub!(auth_method).and_return(true)
          end
        end

        it 'should be successful' do
          model_class.stub!(:get).and_return(:edit)
          do_get.should be_successful
        end

        it 'should fetch the item from the database' do
          model_class.should_receive(:get).with('1').and_return(:edit)
          do_get
        end
        
        it 'should assign the item to an attribute' do
          model_class.stub!(:get).and_return(:edit)
          do_get.assigns(item_name).should eql(:edit)
        end
      end
    end

    ########################## update #########################################
    # Specs for the update action of the controller
    def update_specs(params)
      if params[:auth_actions].include? :update
        update_auth_specs(params)
      end
      update_regular_specs(params)
    end

    def update_auth_specs(params)
      describe controller_class, 'unauthorized update' do
        def do_post(params={})
          tmp = valid_attributes(params)

          dispatch_to(
            controller_class,
            :update,
            hash_params(item_name => tmp, :id => 1)
          ) do |controller|

            controller.stub!(:render)
          end
        end

        it 'should not fetch the item' do
          model_class.should_not_receive(:get)
          do_post
        end
      end
    end
    
    def update_regular_specs(params)
      describe controller_class, 'authorized update' do
        before(:each) do
          stub_nested_get if nested?
        end

        def do_post(params={})
          tmp = valid_attributes(params)

          dispatch_to(
            controller_class,
            :update,
            hash_params(item_name => tmp, :id => 1)
          ) do |controller|

            controller.stub!(:render)
            controller.stub!(auth_method).and_return(true)
          end
        end

        def item_mock(rv=true)
          @item_mock ||= create_item_mock(rv)
        end

        def create_item_mock(rv=true)
          item = merb_model_mock(item_name, :update_attributes => rv)
          stub_nested(item) if nested?
          item
        end

        it 'should fetch the item' do
          model_class.should_receive(:get).with('1').and_return(item_mock)
          do_post
        end
        
        it 'should update the item' do
          model_class.stub!(:get).with('1').and_return(item_mock)
          item_mock.should_receive(:update_attributes).with(hash_including(
            update_attributes
          ))
          do_post
        end

        it 'should redirect to the show-path' do
          model_class.stub!(:get).with('1').and_return(item_mock)
          do_post.should redirect_to(redirect_update_path)
        end
        
        it 'should render the edit again on failure' do
          model_class.stub!(:get).with('1').and_return(item_mock)
          item_mock.stub!(:update_attributes).and_return(false)
          do_post.should be_successful
        end
      end
    end
    
    ########################## destroy ########################################
    # Specs for the destroy action of the controller
    def destroy_specs(params)
      if params[:auth_actions].include? :destroy
        destroy_auth_specs(params)
      end
      destroy_regular_specs(params)
    end

    def destroy_auth_specs(params)
      describe controller_class, 'unauthorized destroy' do
        def do_post
          dispatch_to(controller_class, :destroy, id_params(1)) do |controller|
            controller.stub!(:render)
          end
        end

        it 'should not fetch the item' do
          model_class.should_not_receive(:get).with('1')
          do_post
        end
      end
    end
    
    def destroy_regular_specs(params)
      describe controller_class, 'authorized destroy' do
        before(:each) do
          stub_nested_get if nested?
        end
        
        def do_post
          dispatch_to(controller_class, :destroy, id_params(1)) do |controller|
            controller.stub!(:render)
            controller.stub!(auth_method).and_return(true)
          end
        end

        def item_mock
          @item_mock ||= merb_model_mock(item_name, :destroy => true)
        end

        it 'should fetch the item' do
          model_class.should_receive(:get).with('1').and_return(item_mock)
          do_post
        end
        
        it 'should destroy it' do
          model_class.stub!(:get).and_return(item_mock)
          item_mock.should_receive(:destroy)
          do_post
        end

        it 'should redirect to the index' do
          model_class.stub!(:get).and_return(item_mock)
          do_post.should redirect_to(redirect_destroy_path)
        end
        
        it 'should redirect to the index if not found' do
          model_class.stub!(:get).and_return(nil)
          do_post.should redirect_to(redirect_destroy_path)
        end
      end
    end

    # Injects the parameters as an class-attribute
    def inject_params(params)
      name = controller_class.to_s.downcase
      eval("@@#{name} = params")
      ResourceHelperMethods.module_eval <<-code
        def #{name}
          ResourceHelperGroupMethods.send(:class_variable_get, :@@#{name})
        end
      code
    end

    # Checks if the controller is resourceful. 
    # It might take the following parameters as hash
    # [auth_method]  the method which is used to authenticate the user. It 
    #                might be a method like :logged_in? or something similar.
    # [auth_actions] an array of methods, which should be checked for
    #                authentication
    # [nested_in]    an symbol which indicates if the resource is nested into
    #                another resource
    # [redirect_update_path] An alternative redirection-path which should be
    #                        checked after the update-action is performed
    # [redirect_destroy_path] An alternative redirection-path which should be
    #                        checked after the destroy-action is performed
    # [redirect_create_path] An alternative redirection-path which should be
    #                        checked after the create-action is performed
    def it_should_be_resourceful(params={})
      auth_method = params[:auth_method] || :no_auth_method
      default = {
        :auth_actions => [],
        :auth_method  => :no_auth_method,
        :nested_in    => nil,
        :excludes     => []
      }.merge(params)

      default[:excludes] = [* default[:excludes]]

      self.class_eval <<-EOF
        def auth_method
          :#{default[:auth_method]}
        end
      EOF

      inject_params(default)

      index_specs(default) unless default[:excludes].include? :index
      show_specs(default) unless default[:excludes].include? :show
      new_specs(default) unless default[:excludes].include? :new
      create_specs(default) unless default[:excludes].include? :create
      edit_specs(default) unless default[:excludes].include? :edit
      update_specs(default) unless default[:excludes].include? :update
      destroy_specs(default) unless default[:excludes].include? :destroy
    end
  end

  module ResourceHelperMethods
    def item_name
      model_class.to_s.downcase.to_sym
    end

    def items_name
      controller_class.to_s.downcase.to_sym
    end

    def path_prefix
      Merb.config[:path_prefix]
    end

    def nested_id_name
      params = send(controller_class.to_s.downcase)
      params[:nested_in].to_s.downcase.singularize + "_id"
    end
    
    # Returns a parameter hash for the index, create, .. action
    def no_id_params
      params = send(controller_class.to_s.downcase)
      result = {}
      if params[:nested_in]
        result.merge!(nested_id_name => '1')
      end
      result
    end

    # Returns the id parameter hash for updating/editing/... an item
    def id_params(id)
      params = send(controller_class.to_s.downcase)
      result = {}
      if params[:nested_in]
        result.merge!(nested_id_name => '1')
      end
      result.merge(:id => id)
    end

    # Creates a parameter hash for post/put-requests and merges them with
    # parameters of nested routes
    def hash_params(hash={})
      params = send(controller_class.to_s.downcase)
      if params[:nested_in]
        hash.merge!(nested_id_name => '1')
      end
      hash
    end

    # Returns true if the controller is nested
    def nested?
      params = send(controller_class.to_s.downcase)
      !params[:nested_in].nil?
    end

    # Returns a stub for the outer element of the nested controller
    def stub_nested(elem)
      params = send(controller_class.to_s.downcase)
      name = params[:nested_in].to_s.singularize
      elem.stub!(name).and_return(merb_model_mock('elem'))
      elem.stub!("#{name}_id").and_return('1')
      elem
    end

    # Creates a stub for the get-mehtod of the outer resource
    def stub_nested_get
      params = send(controller_class.to_s.downcase)
      my_name = model_class.to_s.downcase.pluralize.to_sym

      name = params[:nested_in].to_s.singularize
      klass = name.to_const_string

      proxy_mock = mock('proxy')
      eval <<-code
      def proxy_mock.create(params)
        #{model_class}.create(params.merge(:#{name}_id => '1'))
      end
      code

      Kernel.const_get(klass).stub!(:get).with('1').
        and_return(merb_model_mock('elem', my_name => proxy_mock))
    end

    # Returns the index-path of the controller
    # If the controller is nested the nested element is returned.
    def index_path
      params = send(controller_class.to_s.downcase)
      if nested? 
        "#{path_prefix}/#{params[:nested_in]}/1/#{items_name}"
      else
        "#{path_prefix}/#{items_name}"
      end
    end

    # Returns the path which should be expected to be redirected to after an
    # updated
    def redirect_update_path
      params = send(controller_class.to_s.downcase)
      return params[:redirect_update_path] if params[:redirect_update_path]
      "#{index_path}/1"
    end

    # Returns the path which should be expected to be redirected to after a
    # destroy
    def redirect_destroy_path
      params = send(controller_class.to_s.downcase)
      return params[:redirect_destroy_path] if params[:redirect_destroy_path]
      index_path
    end

    # Returns the path which should be expected to be redirected to after a
    # create
    def redirect_create_path
      params = send(controller_class.to_s.downcase)
      return params[:redirect_create_path] if params[:redirect_create_path]
      index_path
    end
  end

  def self.included(klass)
    klass.extend ResourceHelperGroupMethods
    klass.send(:include, ResourceHelperMethods)
  end
end
