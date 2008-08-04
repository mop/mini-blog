Story: View of the all entries

  As a user
  I want to view the entries
  So that I can see the content

  Scenario: requesting the entries
    Given 5 entries
    When I request /entries
    Then I will see the 5 entries

  Scenario: requesting the entries via rss
    Given 5 entries
    When I request /entries.rss2
    Then I will see the 5 entries in rss2

  Scenario: requesting a single entry
    Given 5 entries
    And requesting /entries
    When I click on the headline
    Then I will see the selected entry
