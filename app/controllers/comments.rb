class Comments < Application
  before :admin_required, :only => [ :edit, :update, :destroy, :index, :show ]
  provides :html, :js

  def new
    only_provides :html
    @comment = Comment.new
    render
  end

  def edit
    only_provides :html
    @comment = Comment.get(params[:id])
    render
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
          '/entries/comment', 
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
      redirect url(:entry, @comment.entry)
    else
      render :edit
    end
  end

  def destroy
    @entry   = Entry.get(params[:entry_id])
    @comment = Comment.get(params[:id])
    @comment.destroy rescue nil
    redirect url(:entry, @entry)
  end
end
