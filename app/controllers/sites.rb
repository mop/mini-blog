class Sites < Application
  # provides :xml, :yaml, :js
  before :admin_required, :only => [ 
    :new, :create, :edit, :update, :destroy, :index 
  ]

  def index
    @sites = Site.all
    display @sites
  end

  def show
    @site = Site.get(params[:id])
    #raise NotFound unless @site
    display @site
  end

  def new
    only_provides :html
    @site = Site.new
    render
  end

  def edit
    only_provides :html
    @site = Site.get(params[:id])
    #raise NotFound unless @site
    render
  end

  def create
    @site = Site.create(params[:site])
    if @site.valid?
      redirect url(:site)
    else
      render :new
    end
  end

  def update
    @site = Site.get(params[:id])
    #raise NotFound unless @site
    if @site.update_attributes(params[:site])
      redirect url(:site, @site)
    else
      render :edit
      #raise BadRequest
    end
  end

  def destroy
    @site = Site.get(params[:id])
    @site.destroy if @site
    redirect url(:sites)
  end
end
