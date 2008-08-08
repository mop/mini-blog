# This controller is used for previewing markdown
class MarkdownConverter < Application
  include MarkdownConvertHelper
  before :admin_required

  def index
    str = convert(
      params[:markdown]
    )
    render str, :layout => false
  end
end
