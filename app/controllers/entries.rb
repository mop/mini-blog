class Entries < Application
  provides :html, :rss2
  before :admin_required, :only => [ :new, :create, :edit, :update, :destroy ]

  def index
    @entries = Entry.all_for_index
    render
  end

  def show
    @entry   = Entry.get(params[:id])
    @comment = Comment.new(:entry => @entry)
    display @entry
  end

  def delete
    render
  end

  def new
    @entry = Entry.new
    render
  end

  def edit
    @entry = Entry.get(params[:id])
    render
  end

  def create
    @entry = Entry.create(params[:entry])
    if @entry.valid?
      redirect url(:entries)
    else
      render :new
    end
  end

  def update
    @entry = Entry.get(params[:id])
    if @entry.update_attributes(params[:entry])
      redirect url(:entry, @entry)
    else
      render :edit, @entry
    end
  end

  def destroy
    @entry = Entry.get(params[:id])
    @entry.destroy rescue nil
    redirect url(:entries)
  end

  def archive
    @entries = Entry.group_for_archive
    render
  end
end
