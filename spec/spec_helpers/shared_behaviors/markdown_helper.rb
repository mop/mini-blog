module MarkdownHelper
  module MarkdownHelperGroupMethods
    def before_block(text_attribute, html_attribute)
      before(:each) do
        model_class.all.destroy!
        @elem = model_class.new(valid_attributes)
      end
    end

    def after_block(text_attribute, html_attribute)
      after(:each) do
        model_class.all.destroy!
      end
    end

    def markdown_blocks(text_attribute, html_attribute)
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
    end

    def code_parsing_blocks(text_attribute, html_attribute)
      it 'should filter and parse code' do
        @elem.send(
          "#{text_attribute}=",
          '<filter:code lang="ruby"> puts "hello world" </filter:code>'
        )
        @elem.save
        @elem.send(html_attribute).should_not match(/filter/)
      end
    end

    # Checks if the text on the text-attribute is transformed into markdown
    # and updated after save
    def it_should_cache_markdown(text_attribute, html_attribute, params={})
      default = {
        :filter_code => true
      }.merge(params)
      eval <<-EOF
      describe 'markdown caching' do
        before_block("#{text_attribute}", "#{html_attribute}")
        after_block("#{text_attribute}", "#{html_attribute}")

        markdown_blocks("#{text_attribute}", "#{html_attribute}")

        # only if the code should be generated from the <filter-tags check this
        if #{params[:filter_code]}
          code_parsing_blocks("#{text_attribute}", "#{html_attribute}")
        end
      end
      EOF
    end
  end

  module MarkdownHelperMethods
  end

  def self.included(klass)
    klass.extend(MarkdownHelperGroupMethods)
    klass.send(:include, MarkdownHelperMethods)
  end
end
