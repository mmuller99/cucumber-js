Feature: Hook Parameters

  @spawn
  Scenario: before hook parameter
    Given a file named "features/my_feature.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a step
      """
    And a file named "features/step_definitions/my_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({When}) => {
        When(/^a step$/, function() {})
      })
      """
    And a file named "features/support/hooks.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({Before}) => {
        Before(function(testCase) {
          console.log(testCase.sourceLocation.uri + ":" + testCase.sourceLocation.line)
          console.log('tags: ', testCase.pickle.tags);
          console.log('name: ', testCase.pickle.name);
        })
      })
      """
    When I run cucumber.js
    Then the output contains the text:
      """
      features/my_feature.feature:2
      tags: []
      name: a scenario
      """

  @spawn
  Scenario: after hook parameter
    Given a file named "features/my_feature.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a passing step

        Scenario: another scenario
          Given a failing step
      """
    And a file named "features/step_definitions/my_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({When}) => {
        When(/^a passing step$/, function() {})
        When(/^a failing step$/, function() { throw new Error("my error") })
      })
      """
    And a file named "features/support/hooks.js" with:
      """
      import {defineSupportCode, Status} from 'cucumber'

      defineSupportCode(({After}) => {
        After(function(testCase) {
          let message = testCase.sourceLocation.uri + ":" + testCase.sourceLocation.line + " "
          if (testCase.result.status === Status.FAILED) {
            message += "failed"
          } else {
            message += "did not fail"
          }
          console.log(message)
          console.log('tags: ', testCase.pickle.tags);
          console.log('name: ', testCase.pickle.name);
        })
      })
      """
    When I run cucumber.js
    Then it fails
    And the output contains the text:
      """
      features/my_feature.feature:2 did not fail
      tags: []
      name: a scenario
      """
    And the output contains the text:
      """
      features/my_feature.feature:5 failed
      tags: []
      name: another scenario
      """
