require File.dirname(__FILE__) + '/../spec_helper'

describe Project do
  it "should translate feed:// to http://" do
    p = Project.create(:name => "foo", :source_code_feed => "feed://foo.com/")
    p.source_code_feed.should == "http://foo.com/"
  end
  
  it "should lookup feed if nil" do
    p = Project.create(:name => "OSS Dashboard", :source_code => "http://github.com/epall/oss_dashboard/")
    p.save!
    p.source_code_feed.should_not be_nil
  end
  
  it "should not lookup feed if already specified" do
    p = Project.create(:name => "OSS Dashboard",
      :source_code => "http://github.com/epall/oss_dashboard/",
      :source_code_feed => "http://github.com/epall.atom")
    p.save!
    p.source_code_feed.should == "http://github.com/epall.atom"
  end
  
  it "should automatically generate fields for GitHub hosting" do
    p = Project.create(:name => "OSS Dashboard", :github => "epall/oss_dashboard")
    p.source_code.should == "http://github.com/epall/oss_dashboard/"
    p.source_code_feed.should == "http://github.com/feeds/epall/commits/oss_dashboard/master"
    p.wiki.should == "http://wiki.github.com/epall/oss_dashboard/"
  end
end
