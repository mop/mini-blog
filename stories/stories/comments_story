Story: Some story about comments_story

  As a User
  I want to read and write comments
  So that I can complain to the blogger
  
  Scenario: Viewing the comment-count
    Given a user
    And an entry
    And some comments
    When visiting /entries/
    Then the count of the comments should be shown

  Scenario: Viewing a page with comments
    Given a user
    And an entry
    And some comments
    When visiting /entries/1
    Then the comments should be shown

  Scenario: Adding a comment
    Given a user
    And an entry
    And some comments
    And visiting /entries/1
    And a comments-form
    When submitting the form
    Then the user should be redirected
    And the comment should be shown

  Scenario: Adding a malicious comment
    Given a user
    And an entry
    And some comments
    And visiting /entries/1
    And a comments-form
    When submitting the form with malicious content
    Then the user should be redirected
    And the malicious content should be shown escaped
