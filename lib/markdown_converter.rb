module MarkdownConvertHelper
  def convert(text)
    re = /<filter:code lang=['"](.*?)["']>(.*?)<\/filter:code>/im
    sub = text.gsub(re) do |str|
      lang, code = re.match(str)[1,2]
      Uv.parse(code, 'xhtml', lang, true, 'idle')
    end
    Maruku.new(sub).to_html
  end
end
