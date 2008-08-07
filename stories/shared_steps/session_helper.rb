module SessionStoryHelper
  module SessionStoryGroupMethods
    def shared_session_steps
      Given "visiting /sessions/new" do
        @controller = get "/sessions/new"
      end

      Given "filling in the correct credentials" do
        @controller.body.should have_tag(
          "input", :name => 'user', :type => 'text'
        )
        @controller.body.should have_tag(
          "input", :name => 'password', :type => 'password'
        )
        @controller = post('/sessions/', { 
          'user'     => 'test',
          'password' => 'testpw' 
        }) do |controller|
          controller.stub!(:session).and_return(session)
          controller.should_receive(:authorize).with('test', 'testpw').
              and_return(true)
        end
      end
    end
  end

  module SessionStoryMethods
    def session
      @session ||= {}
    end

    def do_get(path)
      get path do |controller|
        controller.stub!(:session).and_return(session)
        yield controller if block_given?
      end
    end

    def do_post(path, params={})
      post path, params do |controller|
        controller.stub!(:session).and_return(session)
        yield controller if block_given?
      end
    end
    
    def do_put(path, params={})
      put path, params do |controller|
        controller.stub!(:session).and_return(session)
        yield controller if block_given?
      end
    end

    def do_delete(path, params={})
      delete path, params do |controller|
        controller.stub!(:session).and_return(session)
        yield controller if block_given?
      end
    end
  end
end

include_shared_steps(SessionStoryHelper)
