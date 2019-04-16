class TeamMembersController < ApplicationController
  def index
    @team_members = TeamMember.all
  end

  def import
    TeamMember.import(params[:file])

    redirect_to root_url, notice: "Team members have been imported."
  end
end
