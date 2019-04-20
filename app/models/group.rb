class Group < ApplicationRecord
  has_many :team_members

  SWAP_COUNT = 1000

  def self.optimize_groups
    self.calculate_and_record_scores_for_groups

    SWAP_COUNT.times do
      self.swap_groups
    end

    self.calculate_and_record_scores_for_groups
  end

  def self.swap_groups
    groups_to_swap = Group.all.sample(2)
    group1 = groups_to_swap[0]
    group2 = groups_to_swap[1]
    group1_members = group1.team_members
    group2_members = group2.team_members
    swapee1 = TeamMember.where(group: group1).sample
    swapee2 = TeamMember.where(group: group2).sample
    swap_group1_members = swap_member(group1_members, swapee1, swapee2)
    swap_group2_members = swap_member(group2_members, swapee2, swapee1)

    if self.improved_by_swapping?(group1_members, group2_members, swap_group1_members, swap_group2_members)
      swapee1.update!(group: groups_to_swap[1])
      swapee2.update!(group: groups_to_swap[0])
    end
  end

  def self.swap_member(group, old_member, new_member)
    new_group = group.dup.to_a

    swap_index = new_group.index(old_member)

    new_group[swap_index] = new_member

    new_group
  end

  def self.improved_by_swapping?(og_gr_1, og_gr_2, swap_gr_1, swap_gr_2)
    original_score = self.calculate_group_score(og_gr_1) + self.calculate_group_score(og_gr_2)
    swap_score = self.calculate_group_score(swap_gr_1) + self.calculate_group_score(swap_gr_2)
    
    if original_score >= swap_score
      return true
    else
      return false
    end
  end

  def self.calculate_and_record_scores_for_groups
    Group.all.each do |group|
      score = calculate_group_score(group.team_members)

      group.update!(score: score)
    end
  end

  def self.calculate_group_score(group_members)
    current_group_score = 0

    TeamMember::CATEGORIES.each do |category|
      current_group_score += self.calculate_cat_score(category, group_members)
    end

    current_group_score
  end

  def self.calculate_cat_score(category, members)
    group_total = members.count

    case category
    when "years_at_github"
      score = 0
      total_old = TeamMember.where('years_at_github >= 3').count
      total_new = TeamMember.where('years_at_github < 3').count
      total_traits = { old: total_old, new: total_new }
      group_traits = { old: 0, new: 0 }

      members.each do |member|
        member.years_at_github > 3 ? group_traits[:old] += 1 : group_traits[:new] += 1
      end
      
      group_traits.each do |trait, val|
        score += ((val.to_f / group_total) - (total_traits[trait].to_f / ::TeamMember.count)).abs
      end

      score
    else
      score = 0
      total_traits = TeamMember.group(category.to_sym).count
      group_traits = Hash.new(0)

      members.each do |member|
        group_traits[member.send(category.to_sym)] += 1
      end

      group_traits.each do |trait, val|
        score += ((val.to_f / group_total) - (total_traits[trait].to_f / ::TeamMember.count)).abs
      end

      score
    end
  end
end
