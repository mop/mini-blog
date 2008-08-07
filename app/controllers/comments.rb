class Comments < Application
  # provides :xml, :yaml, :js
  before :admin_required, :only => [ :edit, :update, :destroy, :index, :show ]

  def index
    @comments = Comment.all
    render
  end

  def show
    @comment = Comment.get(params[:id])
    #raise NotFound unless @comment
    render
  end

  def new
    only_provides :html
    @comment = Comment.new
    render
  end

  def edit
    only_provides :html
    @comment = Comment.get(params[:id])
    #raise NotFound unless @comment
    render
  end

  def create
    @entry = Entry.get(params[:entry_id])
    @comment = @entry.comments.create(params[:comment])
    if @comment.valid?
      redirect url(:entry_comments, @comment)
    else
      render :new
    end
  end

  def update
    @comment = Comment.get(params[:id])
    #raise NotFound unless @comment
    if @comment.update_attributes(params[:comment])
      redirect url(:entry_comment, @comment)
    else
      render :edit
    end
  end

  def destroy
    @entry   = Entry.get(params[:entry_id])
    @comment = Comment.get(params[:id])
    #raise NotFound unless @comment
    @comment.destroy rescue nil
    redirect url(:entry, @entry) + '/comments'
    #if @comment.destroy
    #  redirect url(:entry_comment, @entry)
    #else
    #  raise BadRequest
    #end
  end
end
