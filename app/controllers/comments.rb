class Comments < Application
  # provides :xml, :yaml, :js
  before :admin_required, :only => [ :edit, :update, :destroy, :index, :show ]

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
      redirect url(:entry, @entry)
    else
      @entry.reload
      render :template => 'entries/show.html'
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
