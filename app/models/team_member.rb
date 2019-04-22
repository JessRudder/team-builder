class TeamMember < ApplicationRecord
  require 'csv'

  belongs_to :group, optional: true

  GROUP_SIZE = 6
  CATEGORIES = ["years_at_github", "manager", "manager_squad", "division", "cost_center", "location"]

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      row_hash = row.to_hash
      hire_date = row_hash.delete("original_hire_date").to_date
      years_at_github = (Date.today - hire_date).to_f / 365
      TeamMember.create!(row_hash.merge({ "years_at_github" => years_at_github }))
    end

    members = self.all

    create_groups(members.count)
    random_group_assignment(members)
    optimize_groups
  end

  def self.random_group_assignment(members)
    num_groups = Group.count
    current_group = 1
    current_count = 1
    order = (0...members.count).to_a.shuffle

    order.each do |idx|
      if current_group <= num_groups && current_count <= GROUP_SIZE
        members[idx].update!(group_id: current_group)
        current_count += 1
      elsif current_group <= num_groups && current_count > GROUP_SIZE
        current_group += 1
        current_count = 1

        members[idx].update!(group_id: current_group)
        current_count += 1
      end
    end
  end

  def self.create_groups(members_count)
    num_groups = number_of_groups(members_count)

    num_groups.times do
      Group.create!
    end
  end

  def self.number_of_groups(count)
    if count % GROUP_SIZE == 0
      count / GROUP_SIZE
    else
      count / GROUP_SIZE + 1
    end
  end

  def self.optimize_groups
    Group.optimize_groups
  end

  def self.to_csv
    attributes = self.attribute_names

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end
end
