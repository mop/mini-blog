Story: Some story about admin_comments_story

  As a Admin
  I want to manipulate comments
  So that I can remove evil comments
  
  Scenario: Unauthorized access
    Given a user
    And a entry
    And a comment
    When visiting /entries/1/comments/1/edit
    Then the access should be denied

  Scenario: Authorized access
    Given a user
    And a entry
    And a comment
    And visiting /sessions/new
    And filling in the correct credentials
    When visiting /entries/1/comments/1/edit
    Then the edit-form should be shown

  Scenario: Authorized update
    Given a user
    And a entry
    And a comment
    And visiting /sessions/new
    And filling in the correct credentials
    And visiting /entries/1
    And clicking on the edit-link of a comment
    When submitting the comments form
    Then the comment should have been changed

  Scenario: Authorized delete
    Given a user
    And a entry
    And a comment
    And visiting /sessions/new
    And filling in the correct credentials
    And visiting /entries/1
    When clicking on the destroy-link of a comment
    Then the comment should have been removed
