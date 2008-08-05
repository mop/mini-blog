module ResourceHelper
  module ResourceHelperGroupMethods
    def self.included(klass)
      p klass
      @klass = klass
    end

    # Specs for the index action of the controller
    def index_specs(auth_actions)
      if auth_actions.include? :index
        describe controller_class, "unauthorized index action" do
          def do_get
            dispatch_to(controller_class, :index) do |controller|
              controller.stub!(:render)
            end
          end

          it 'should not fetch the from the database' do
            model_class.should_not_receive(:all)
            do_get
          end
        end
      end

      describe controller_class, "index action" do
        before(:each) do
          @items = []
        end

        def do_get
          dispatch_to(controller_class, :index) do |controller|
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

    # Specs for the show action of the controller
    def show_specs(auth_actions)
      if auth_actions.include? :show 
        describe controller_class, "unauthorized show action" do
          def do_get
            dispatch_to(controller_class, :show) do |controller|
              controller.stub!(:render)
            end
          end

          it 'should not fetch the from the database' do
            model_class.should_not_receive(:get)
            do_get
          end
        end
      end

      describe controller_class, "show action" do
        before(:each) do
          @item = mock(:item)
        end

        def do_get
          dispatch_to(controller_class, :show, :id => 1) do |controller|
            controller.stub!(:render)
            controller.stub!(auth_method).and_return(true)
          end
        end

        it 'should fetch the correct element on get' do
          model_class.should_receive(:get).with('1')
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

    # Specs for the new action of the controller
    def new_specs(auth_actions)
      if auth_actions.include? :new
        describe controller_class, 'new page' do
          def do_get
            dispatch_to(controller_class, :new) do |controller|
              controller.stub!(:render)
            end
          end

          it 'should not be successful' do
            do_get.assigns(item_name).should be_nil
          end
        end
      end

      describe controller_class, 'new page authorized' do
        def do_get
          dispatch_to(controller_class, :new) do |controller|
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

    # Specs for the create action of the controller
    def create_specs(auth_actions)
      if auth_actions.include? :create
        describe controller_class, 'unauthorized create' do
          def do_post(params={})
            tmp = valid_attributes(params)

            dispatch_to(
              controller_class,
              :create,
              item_name => tmp
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

      describe controller_class, 'create' do
        def do_post(params={})
          tmp = valid_attributes(params)

          dispatch_to(
            controller_class,
            :create,
            item_name => tmp
          ) do |controller|

            controller.stub!(:render)
            controller.stub!(auth_method).and_return(true)
            yield controller if block_given?
            controller
          end
        end

        def item_mock(flag=true) 
          mock('item', :valid? => flag)
        end

        it 'should create the item' do
          model_class.should_receive(:create).with(hash_including(
            update_attributes
          )).and_return(item_mock)
          do_post
        end

        it 'should redirect the the user on success' do
          model_class.stub!(:create).and_return(item_mock)
          do_post.should redirect_to("#{path_prefix}/#{items_name}/")
        end

        it 'should display the new page again on failure' do
          model_class.stub!(:create).and_return(item_mock(false))
          do_post.should be_successful
        end
      end
    end

    # Specs for the edit action of the controller
    def edit_specs(auth_actions)
      if auth_actions.include? :edit
        describe controller_class, 'unauthorized edit' do
          def do_get
            dispatch_to(controller_class, :edit, :id => 1) do |controller|
              controller.stub!(:render)
            end
          end

          it 'should not edit the item' do
            model_class.should_not_receive(:get)
            do_get
          end
        end
      end

      describe controller_class, 'authorized edit' do
        def do_get
          dispatch_to(controller_class, :edit, :id => 1) do |controller|
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

    # Specs for the update action of the controller
    def update_specs(auth_actions)
      if auth_actions.include? :update
        describe controller_class, 'unauthorized update' do
          def do_post(params={})
            tmp = valid_attributes(params)

            dispatch_to(
              controller_class,
              :update,
              :id => 1,
              item_name => tmp
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

      describe controller_class, 'authorized update' do
        def do_post(params={})
          tmp = valid_attributes(params)

          dispatch_to(
            controller_class,
            :update,
            :id => 1,
            item_name => tmp
          ) do |controller|

            controller.stub!(:render)
            controller.stub!(auth_method).and_return(true)
          end
        end

        def item_mock(rv=true)
          @item_mock ||= mock(item_name, :update_attributes => rv, :id => '1')
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
          do_post.should redirect_to("#{path_prefix}/#{items_name}/1")
        end
        
        it 'should render the edit again on failure' do
          model_class.stub!(:get).with('1').and_return(item_mock)
          item_mock.stub!(:update_attributes).and_return(false)
          do_post.should be_successful
        end
      end
    end
    
    # Specs for the destory action of the controller
    def destroy_specs(auth_actions)
      if auth_actions.include? :destroy
        describe controller_class, 'unauthorized destroy' do
          def do_post
            dispatch_to(controller_class, :destroy, :id => '1') do |controller|
              controller.stub!(:render)
            end
          end

          it 'should not fetch the item' do
            model_class.should_not_receive(:get).with('1')
            do_post
          end
        end
      end

      describe controller_class, 'authorized destroy' do
        def do_post
          dispatch_to(controller_class, :destroy, :id => '1') do |controller|
            controller.stub!(:render)
            controller.stub!(auth_method).and_return(true)
          end
        end

        def item_mock
          @item_mock ||= mock(item_name, :id => '1', :destroy => true)
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
          do_post.should redirect_to("#{path_prefix}/#{items_name}")
        end
        
        it 'should redirect to the index if not found' do
          model_class.stub!(:get).and_return(nil)
          do_post.should redirect_to("#{path_prefix}/#{items_name}")
        end
      end
    end

    # Checks if the controller is resourceful. 
    # It might take the following parameters as hash
    # [auth_method] the method which is used to authenticate the user. It might
    # be a method like :logged_in? or something similar.
    # [auth_actions] an array of methods, which should be checked for
    # authentication
    def it_should_be_resourceful(params={})
      auth_method = params[:auth_method] || :no_auth_method
      auth_actions = params[:auth_actions] || []
      self.class_eval <<-EOF
        def auth_method
          :#{auth_method}
        end
      EOF

      index_specs(auth_actions)
      show_specs(auth_actions)
      new_specs(auth_actions)
      create_specs(auth_actions)
      edit_specs(auth_actions)
      update_specs(auth_actions)
      destroy_specs(auth_actions)
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
  end

  def self.included(klass)
    klass.extend ResourceHelperGroupMethods
    klass.send(:include, ResourceHelperMethods)
  end
end
