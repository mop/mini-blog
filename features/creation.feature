Story: Some story about creation_story

  As a administrator
  I want to write new entries
  So that users can see my entry
  
  Scenario: unauthorized access

  Given an user
  When visiting /entries/new
  Then I should be redirected to /entries

  Given an user
  And visiting /sessions/new
  And filling in the correct credentials
  When visiting /entries/new
  Then the entry form should be displayed for creation

  Given an user
  And visiting /sessions/new
  And filling in the correct credentials
  And visiting /entries/new
  When submitting a new entry
  Then I should see the new entry on the entries-page
