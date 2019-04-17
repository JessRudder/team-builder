class TeamMember < ApplicationRecord
  require 'csv'
  GROUP_SIZE = 6

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      TeamMember.create!(row.to_hash)
    end

    random_group_assignment
  end

  def self.random_group_assignment
    members = self.all
    num_groups = number_of_groups(members)
    current_group = 1
    current_count = 1
    order = (0...members.count).to_a.shuffle

    order.each do |idx|
      if current_group <= num_groups && current_count <= GROUP_SIZE
        members[idx].update!(assigned_group: current_group)
        current_count += 1
      elsif current_group <= num_groups && current_count > GROUP_SIZE
        current_group += 1
        current_count = 1

        members[idx].update!(assigned_group: current_group)
        current_count += 1
      end
    end
  end

  def self.number_of_groups(members)
    if members.count % GROUP_SIZE == 0
      members.count / GROUP_SIZE
    else
      members.count / GROUP_SIZE + 1
    end
  end

  def self.swap_groups
    groups = TeamMember.pluck(:assigned_group).uniq
    swap_groups = groups.sample(2)
    origin = TeamMember.where(assigned_group: swap_groups[0]).sample
    target = TeamMember.where(assigned_group: swap_groups[1]).sample

    if improved_by_swapping(origin, target)
      origin.update!(assigned_group: swap_groups[1])
      target.update!(assigned_group: swap_groups[0])
    end
  end

  def self.improved_by_swapping(origin, target)
    return true
  end
end
