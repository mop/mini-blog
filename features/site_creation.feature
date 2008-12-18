Story: Some story about site_creation_story

  As a Admin
  I want to create sites
  So that I can show it to my users
  
  Scenario: Unauthorized access
    Given a user
    When visiting /sites
    Then he should be redirected

  Scenario: Authorized access
    Given a user
    And visiting /sessions/new
    And filling in the correct credentials
    When visiting authorized /sites
    Then the sites should be displayed

  Scenario: Creation of a site
    Given a user
    And visiting /sessions/new
    And filling in the correct credentials
    And visiting /sites
    And pressing on /sites/new
    And filling in all elements
    When submitting the creation-form
    Then the site should be created

  Scenario: Update of a site
    Given a user
    And an existing sample site
    And visiting /sessions/new
    And filling in the correct credentials
    And visiting /sites
    And pressing on /sites/1/edit
    And filling in all elements
    When submitting the edit-form
    Then the site should be updated

