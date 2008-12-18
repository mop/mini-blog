Given "visiting /sessions/new" do
  @controller = request("/sessions/new")
end

Given "filling in the correct credentials" do
  @controller.body.should have_tag(
    "input", :name => 'user', :type => 'text'
  )
  @controller.body.should have_tag(
    "input", :name => 'password', :type => 'password'
  )
  Application.class_eval do 
    def authorize(name, pw)
      name == 'test' && pw == 'testpw'
    end
  end
  @controller = request('/sessions/', {
    :method => "POST", :params =>  { 
      'user'     => 'test',
      'password' => 'testpw' 
    }
  }) do |controller|
    controller.stub!(:session).and_return(session)
    controller.should_receive(:authorize).with('test', 'testpw').
        and_return(true)
  end
end
