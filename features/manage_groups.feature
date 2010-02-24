Feature: Manage groups
  In order to keep track of separate cohorts of projects
  dashboard maintainers
  want to define independent groups
  
  Scenario: Listing page
    Given a group called RCOS Spring 2010
    And a project called CAGE
    When I am on the group listing page for group 1
    Then I should see "CAGE"
