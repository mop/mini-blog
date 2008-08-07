module ValidationHelper
  module ValidationHelperGroupMethods
    # This method checks all required_fields for assignment.
    # ---
    # @public
    def it_should_assign_attributes
      required_fields.each do |field|
        it "should have a #{field}-field" do
          elem = model_class.new(valid_attributes)
          elem.send(field).should eql(valid_attributes[field])
        end
      end
    end

    # This method checks all required_fields if they are really required.
    # ---
    # @public
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

    # Checks if the givven attributes are valid
    #
    # ==== Parameters
    # attrs<Array>:: A list of attributes 
    # ---
    # @public
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

    # Checks if the tested class has a has_many-relationship with the given
    # klass.
    #
    # ==== Parameters
    # :klass<Symbol>::
    #   This is the class of the 
    #
    # ==== Example
    # describe Post do
    #   include PostSpecHelper   # include meta information
    #   it_should_have_many :comments
    # end
    # ---
    # @public
    def it_should_have_many(klass)
      inject_meta_attribute(klass)
      create_has_many_spec(klass)
    end

    # TODO: Refactor this
    def create_has_many_spec(klass)
      eval <<-EOF
      describe "has many #{klass}" do
        before(:each) do
          @item = model_class.create(valid_attributes)
        end

        after(:each) do
          @item.destroy
        end

        it 'should have 0 children' do
          @item.send("#{klass}").size.should eql(0)
        end

        describe 'when adding a children' do
          before(:each) do
            @child = #{klass}_meta.model_class.create(
              #{klass}_meta.valid_attributes
            )
            @item.send("#{klass}") << @child
          end
          
          after(:each) do
            @child.destroy if @child
          end

          it 'should have 1 children' do
            @item.send("#{klass}").size.should eql(1)
          end

          it 'should return the children as first element' do
            @item.send("#{klass}").first.should eql(@child)
          end

          it 'should have 0 children after destroying the child' do
            @child.destroy
            @child = nil
            @item.reload
            @item.send("#{klass}").size.should eql(0)
          end
        end
      end
      EOF
    end

    # Checks if the tested class have a belongs_to relationship with the given
    # klass.
    #
    # ==== Parameters
    # :klass<Symbol>:: A symbol which indicates the other class-name
    #
    # ==== Example
    # describe Comment do
    #   include CommentSpecHelper   # include meta information
    #   it_should_belong_to :post
    # end
    # ---
    # @public
    def it_should_belong_to(klass)
      inject_meta_attribute(klass)
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

    def meta_class(sym)
      name = sym.to_s.singularize.to_const_string
      mod = Kernel.const_get(
        "#{name}SpecHelper"
      )
      klass = Class.new.send(:include, mod)
      klass.instance_eval <<-EOF
        def attribute_name
          :#{sym}
        end
      EOF
      klass
    end

    # This method injects a meta-object as a klass_meta 
    # method into the test-class-code
    def inject_meta_attribute(klass)
      belonger = meta_class(klass)

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
