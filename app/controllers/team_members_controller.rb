class TeamMembersController < ApplicationController
  def index
    @team_members = TeamMember.all

    respond_to do |format|
      format.html
      format.csv { send_data @team_members.to_csv, filename: "team-members-#{Date.today}.csv" }
    end
  end

  def import
    TeamMember.import(params[:file])

    redirect_back fallback_location: team_members_path, notice: "Team members have been imported."
  end
end
