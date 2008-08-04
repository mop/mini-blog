module PermalinkHelper
  module PermalinkHelperGroupMethods
    def it_should_create_permalinks_on(attribute)
      class_eval <<-EOF
        def permalink_test_attribute
          :#{attribute}
        end
      EOF

      describe 'permalink creation' do
        before(:each) do
          @item = model_class.create(valid_attributes)
        end

        after(:each) do
          @item.destroy
        end

        it 'should not contain any whitespaces' do
          @item.permalink.should_not match(/ /)
        end
        
        it 'should not contain any \' and " literals' do
          @item.permalink.should_not match(/['"]/)
        end

        it 'should create a permalink' do
          @item.permalink.should_not be_nil
        end

        it 'should convert a sample title correctly' do
          @item.send(
            "#{permalink_test_attribute}=", 
            'some " literals \''
          )
          @item.save
          @item.reload
          @item.permalink.should eql(
            'some--literals-'
          )
        end
      end
    end
  end

  module PermalinkHelperMethods
  end

  def self.included(klass)
    klass.extend(PermalinkHelperGroupMethods)
    klass.send(:include, PermalinkHelperMethods)
  end
end
