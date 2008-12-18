Story: Some story about update_entry_story

  As a Admin
  I want to Update my entries
  So that I can correct my mistakes
  
  Scenario: Unauthorized access
    Given an user
    And a entry
    And visiting /entries/1/title
    When clicking unauthorized on edit entries
    Then he should be redirected to /entries

  Scenario: Authorized access
    Given an user
    And a entry
    And visiting /sessions/new
    And filling in the correct credentials
    And visiting /entries/1/title
    When clicking authorized on edit entries
    Then the entry form should be displayed for updateing

  Scenario: Authorized update
    Given an user
    And a entry
    And visiting /sessions/new
    And filling in the correct credentials
    And visiting /entries/1/title
    And clicking authorized on edit entries
    When filling out the form and submitting
    Then the entry should be modified
