class TeamMembersController < ApplicationController
  def index
    @team_members = TeamMember.all
  end

  def import
    TeamMember.import(params[:file])

    redirect_back fallback_location: team_members_path, notice: "Team members have been imported."
  end
end
