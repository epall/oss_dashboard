class Bugger < ActionMailer::Base
  def weekly_update(group)
    recipients group.mailing_list
    from "updates@dashboard.rcos.cs.rpi.edu"
    subject "Weekly Dashboard update"
    
    most_active = group.projects.inject do |best, current|
      current.activity_this_week > best.activity_this_week ? current : best
    end
    
    least_active = group.projects.inject do |best, current|
      current.activity_this_week < best.activity_this_week ? current : best
    end
    
    sorted_by_activity = group.projects.sort_by(&:total_activity)
    
    top_active = sorted_by_activity.reverse[0..2]
    bottom_active = sorted_by_activity[0..2]
    
    body :group => group, :most_active => most_active, :least_active => least_active, :top_active => top_active,
      :bottom_active => bottom_active
  end
end
