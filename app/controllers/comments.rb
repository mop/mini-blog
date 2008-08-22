class Comments < Application
  before :admin_required, :only => [ :edit, :update, :destroy, :index, :show ]
  provides :html, :js

  def new
    only_provides :html
    @comment = Comment.new
    render
  end

  def edit
    @comment = Comment.get(params[:id])
    layout = content_type == :js ? false : nil
    display @comment, :layout => layout
  end

  def create
    @entry = Entry.get(params[:entry_id])
    @comment = @entry.comments.create(params[:comment])
    if @comment.valid?
      # respond_to > provides?!
      # Obviously this is a huge hack, but since the format is somehow lost on
      # a redirect I'll get the whole page back in the ajax request, which
      # sucks. 
      if params[:format] == 'js'
        partial(
          'entries/comment', 
          :format => 'html',
          :with   => @comment
        ) # practically beats purity :D
      else
        redirect url(:entry, @entry)
      end
    else
      @entry.reload
      render :template => '/entries/show'
    end
  end

  def update
    @comment = Comment.get(params[:id])
    if @comment.update_attributes(params[:comment])
      # respond_to > provides?!
      # Obviously this is a huge hack, but since the format is somehow lost on
      # a redirect I'll get the whole page back in the ajax request, which
      # sucks. 
      if params[:format] == 'js'
        render # practically beats purity :D
      else
        redirect url(:entry, @comment.entry)
      end
    else
      if params[:format] == 'js'
        render
      else
        render :edit
      end
    end
  end

  def destroy
    @entry   = Entry.get(params[:entry_id])
    @comment = Comment.get(params[:id])
    @comment.destroy rescue nil
    redirect url(:entry, @entry)
  end
end
