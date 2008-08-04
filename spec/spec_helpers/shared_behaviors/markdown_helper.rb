module MarkdownHelper
  module MarkdownHelperGroupMethods
    # Checks if the text on the text-attribute is transformed into markdown
    # and updated after save
    def it_should_cache_markdown(text_attribute, html_attribute)
      describe 'markdown caching' do
        before(:each) do
          model_class.all.destroy!
          @elem = model_class.new(valid_attributes)
        end

        after(:each) do
          model_class.all.destroy!
        end

        it 'should cache the attributes after save' do
          @elem.send("#{text_attribute}=", "## headline")
          @elem.save
          @elem.send(html_attribute).should match(/h2/)
        end

        it 'should update the attribute after update-attributes' do
          @elem.send("#{text_attribute}=", "## headline")
          @elem.save
          @elem.update_attributes(text_attribute => "### headline")
          @elem.send(html_attribute).should match(/h3/)
        end

        it 'should filter and parse code' do
          @elem.send(
            "#{text_attribute}=",
            '<filter:code lang="ruby"> puts "hello world" </filter:code>'
          )
          @elem.save
          @elem.send(html_attribute).should_not match(/filter/)
        end
      end
    end
  end

  module MarkdownHelperMethods
  end

  def self.included(klass)
    klass.extend(MarkdownHelperGroupMethods)
    klass.send(:include, MarkdownHelperMethods)
  end
end
