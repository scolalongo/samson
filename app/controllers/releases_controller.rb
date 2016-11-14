# frozen_string_literal: true
class ReleasesController < ApplicationController
  include CurrentProject

  before_action :authorize_project_deployer!, except: [:show, :index]

  def show
    @release = @project.releases.find_by_version!(params[:id])
    @changeset = @release.changeset
  end

  def index
    @stages = @project.stages
    @releases = @project.releases.sort_by_version.page(params[:page])
  end

  def new
    @release = @project.releases.build
    @release.assign_release_number
  end

  def create
    @release = ReleaseService.new(@project).create_release!(release_params)
    redirect_to [@project, @release]
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.message
    redirect_to action: :new
  end

  private

  def release_params
    params.require(:release).permit(:commit, :number).merge(author: current_user)
  end
end
