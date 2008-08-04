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
  end

  module ValidationHelperMethods
  end

  def self.included(klass)
    klass.extend ValidationHelperGroupMethods
    klass.send(:include, ValidationHelperMethods)
  end
end
