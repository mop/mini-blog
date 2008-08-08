module MarkdownConvertHelper
  # This method is a helper method which converts the given text into markdown.
  # Moreover it filters <filter:code lang="_language_">_code_</filter:code> 
  # tags and parses the code with ultra-violet.
  #
  # ==== Parameters
  # text<String>::
  #   The markdown-text as string, which should be parsed
  #
  # ==== Returns
  # String::
  #   A parsed HTML-String is returned
  # --- 
  # @public
  def convert(text)
    re = /<filter:code lang=['"](.*?)["']>(.*?)<\/filter:code>/im
    sub = text.gsub(re) do |str|
      lang, code = re.match(str)[1,2]
      Uv.parse(code, 'xhtml', lang, true, 'idle')
    end
    Maruku.new(sub).to_html
  end
end
