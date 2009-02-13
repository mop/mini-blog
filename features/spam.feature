Story: Spam handling on comments

	As a Admin
	I want to see comments marked as spam
	So that I can delete them

	Scenario: Viewing the comments list as regular user
    Given a user
    And an entry
    And some spammy comments
    When visiting /entries/1
    Then only no-spammy comments should be displayed
 
  Scenario: Viewing the comments list as an administrator
    Given a logged in user
    And an entry
    And some spammy comments
    When visiting /entries/1
    Then all spammy comments should be displayed
 
  Scenario: Modifing spam-status of a comment
    Given a logged in user
    And an entry
    And some spammy comments
    When visiting /entries/1
    Then a form allowing to modify the spam-status should be displayed

  Scenario: Actually modifying spam-status of a comment
    Given a logged in user
    And an entry
    And some spammy comments
    And visiting /entries/1
    When submitting the first comment form as no-spam comment
    Then the comments spam-status should have been changed

