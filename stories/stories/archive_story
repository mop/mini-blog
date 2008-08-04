Story: Some story about archive_story

  As a User
  I want to view the archive
  So that I can read older posts
  
  Scenario: listening the archive
    Given a user
    And a list of entries
    When requesting /entries/archive
    Then a list of all posts should be displayed
    And a list of links should be displayed
    And no text should be displayed

  Scenario: clicking on an old entry
    Given a user
    And a list of entries
    And the /entries/archive page
    When clicking on an entry
    Then the entry page should be shown
