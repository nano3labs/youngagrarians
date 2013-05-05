class LocationsController < ApplicationController
  require 'spreadsheet'
  require 'fileutils'
  require 'iconv'

  @tmp = {}

  def search
    @locations = Location.search params[:terms]
    respond_to do |format|
      format.json { render :json =>  @locations }
    end
  end

  # GET /locations
  # GET /locations.json
  def index
  Rails.logger.info '---------------------------------'
    respond_to do |format|
      format.html {
        if not authenticated?
          redirect_to :root
        end
  Rails.logger.info '+++++++++=========------------------'
        @locations = Location.all
      }# index.html.erb
      format.json {
  Rails.logger.info '==================------------------'
        @locations = Location.where( :is_approved => true ).all
        render :json =>  @locations
      }
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    @location = Location.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json =>  @location }
    end
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
    @location = Location.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json =>  @location }
    end
  end

  # custom!
  def excel_import
    if params.has_key? :dump and params[:dump].has_key? :excel_file
      @tmp = params[:dump][:excel_file].tempfile

      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet.open @tmp.path
      sheet1 = book.worksheet 0
      sheet1.each_with_index do |row, i|
        # skip the first row dummy
        next if i == 0

        cat = nil
        if not row[1].empty?
          cat = Category.find_or_create_by_name( row[1] )
        end

        # do things at your leeeisurrree
        Location.new(:type => row[0] ||= '',
                     :category => cat,
                     :subcategory => row[2] ||= '',
                     :name => row[3] ||= '',
                     :bioregion => row[4] ||= '',
                     :address => row[5] ||= '',
                     :phone => row[5] ||= '',
                     :url => row[6] ||= '',
                     :fb_url => row[7] ||= '',
                     :twitter_url => row[8] ||= '',
                     :content => row[9] ||= '').save
      end
    end
  end

  # GET /locations/1/edit
  def edit
    @categories = Category.all
    @locations = nil
    if params.has_key? :id
      location = Location.find(params[:id])
      @locations = [ location ]
    elsif params.has_key? :ids
      @ids = params[:ids].split ','
      @locations = Location.find @ids
    end
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(params[:location])

    respond_to do |format|
      if @location.save
        format.html { redirect_to @location, :notice => 'Location was successfully created.' }
        format.json { render :json =>  @location, :status => :created, :location => @location }
      else
        format.html { render :action => "new" }
        format.json { render :json =>  @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update
    @locations = nil
    if params.has_key? :id
      location = Location.find(params[:id])
      @locations = [ location ]
    elsif params.has_key? :ids
      @locations = Location.find params[:ids]
    end

    @errors = []
    @locations.each do |l|
      if not l.update_attributes params[l.id][:location]
        @errors.push l.errors
      end
    end

    respond_to do |format|
      if @errors.empty?
        format.html { redirect_to :locations, :notice => 'Locations successfully updated.'}
        format.json { head :no_content }
      else
        format.html { render :action =>"edit" }
        format.json { render :json =>  @errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @locations = nil

    if params.has_key? :id
      location = Location.find params[:id]
      @locations = [ location ]
    elsif params.has_key? :ids
      @locations = Location.find params[:ids]
    end

    if not @locations.nil?
      @locations.destroy
    end

    respond_to do |format|
      format.html { redirect_to locations_url }
      format.json { head :no_content }
    end
  end

  def approve
    @locations = Location.find params[:ids]
    @locations.each do |l|
      l.is_approved = true
      l.save
    end

    respond_to do |format|
      format.html { redirect_to locations_url }
      format.json { head :no_content }
    end
  end
end

# WAT
if @tmp
  FileUtils.rm @tmp.path unless nil
end
