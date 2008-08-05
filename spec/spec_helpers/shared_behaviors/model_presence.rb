module ValidationHelper
  module ValidationHelperGroupMethods
    def it_should_assign_attributes
      required_fields.each do |field|
        it "should have a #{field}-field" do
          elem = model_class.new(valid_attributes)
          elem.send(field).should eql(valid_attributes[field])
        end
      end
    end

    # TODO: Refactor this
    def it_should_validate_required
      required_fields.each do |field|
        it "should not be valid without #{field}" do
          elem = model_class.new(valid_attributes)
          elem.send("#{field}=", nil)
          elem.should_not be_valid
        end
      end
      it "should be valid with all fields" do
        elem = model_class.new(valid_attributes)
        elem.should be_valid
      end
    end

    def it_should_verify_uniqueness_of(attrs)
      attrs.each_pair do |key, val|
        it "should only allow one #{key}" do
          item = model_class.new(valid_attributes)
          item.send("#{key}=", val)
          item.save

          dupl = model_class.new(valid_attributes)
          dupl.send("#{key}=", val)
          dupl.should_not be_valid
        end
      end
    end

    def it_should_belong_to(klass)
      inject_belongs_to_attribute(klass)
      create_belongs_to_spec(klass)
    end
    
    # Some meta-magic which creates the code
    def create_belongs_to_spec(klass)
      eval <<-EOF
      describe "belongs to #{klass}" do
        before(:each) do
          @belongs_to_model = #{klass}_meta.model_class.new(
            #{klass}_meta.valid_attributes
          )
          @belongs_to_model.save
        end

        after(:each) do
          @belongs_to_model.destroy
        end
        
        it "should create a valid #{klass} model" do
          @belongs_to_model.should be_valid
        end

        it 'should be able to assign the model' do
          my_model = model_class.create(valid_attributes)
          my_model.send(
            "\#\{#{klass}_meta.attribute_name\}=",
            @belongs_to_model
          )
          my_model.save
          my_model.send(
            #{klass}_meta.attribute_name
          ).should eql(@belongs_to_model)
        end
      end
      EOF
    end

    # This method injects a meta-object as a klass_meta 
    # method into the test-class-code
    def inject_belongs_to_attribute(klass)
      name = klass.to_s.capitalize
      mod = Kernel.const_get(
        "#{name}SpecHelper"
      )
      belonger = Class.new.send(:include, mod)
      belonger.instance_eval <<-EOF
        def attribute_name
          :#{klass}
        end
      EOF

      # unfortunately, there is no class_variable_set-method :(
      self.send(:eval, <<-EOF
        @@#{klass}_meta = belonger
      EOF
      )

      # Inject it to the instance methods so that we can use
      # it in our tests
      ValidationHelperMethods.module_eval <<-code
        def #{klass}_meta
          ValidationHelperGroupMethods.send(
            :class_variable_get, :@@#{klass}_meta
          )
        end
      code
    end
  end

  module ValidationHelperMethods
  end

  def self.included(klass)
    klass.extend ValidationHelperGroupMethods
    klass.send(:include, ValidationHelperMethods)
  end
end
