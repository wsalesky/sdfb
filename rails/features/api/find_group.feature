Feature: Find group
  Background: Basic seed data exists
    Given required app users exist
    And the "has met" relationship type exists with id 4

  Scenario: Finding a given group with the API
    Given a group exists
    When I access the api endpoint for the group
    And I am given json
    Then the data looks like a list of one group
    And the data has correct information for the group

  Scenario: Finding multiple groups with the API
    Given multiple groups exist
    When I access the api endpoint for those groups
    And I am given json
    Then the data looks a list containing 2 groups
    And the data has correct ids for those groups

  Scenario: Finding all of the groups with the API
    Given 3 groups exist
    When I access the api endpoint for all groups
    And I am given json
    Then the data looks a list containing 3 groups
    And the data has correct ids for those groups

  Scenario: Finding a group with an invalid ID
    When I access the api endpoint for a group with an invalid ID
    And I am given json
    Then the errors include "Invalid group ID(s)"

  Scenario: Finding a given group network with the API
    Given a group exists
    And a person is in the group
    And a relationship exists for a group member
    When I access the api endpoint for the group network
    And I am given json
    Then the data looks like a list of one group
    And the included data has information for the relationship members