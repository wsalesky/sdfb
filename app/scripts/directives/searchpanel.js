'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:searchPanel
 * @description
 * # searchPanel
 */
angular.module('redesign2017App')
  .directive('searchPanel', function() {
    return {
      templateUrl: './views/search-panel.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the searchPanel directive');
        scope.peopleToSelect = ['Francis Bacon (1600)', 'Francis Bacon (1587)', 'Francis Bacon (1561)', 'William Shakespeare (1564)', 'John Milton (1562)', 'Alice Spencer (1559)'];
        scope.person = { 'selected' : scope.peopleToSelect[1] }
        scope.radioModel = 'individual-force';

        scope.sharedToSelect = scope.peopleToSelect;
        scope.shared = { 'selected' : undefined }

        scope.resetIndividualNetwork = function() {
          console.log('resetIndividualNetwork');
          scope.person.selected = undefined;
        }

        scope.resetSharedNetwork = function() {
          console.log('resetSharedNetwork');
          scope.shared.selected = undefined;
          scope.config.viewMode = 'individual-force';
        }

        scope.selectedShared = function($person2, $person1) {
          console.log('Shared network between:', $person1, 'and', $person2);
          if ($person2 && $person1) {
            scope.config.viewMode = 'shared-network'
            scope.$broadcast('shared network query', { 'person1': $person1, 'person2': $person2 });
          } else {
            console.error('You need to specify two people for getting data for a shared network.', $person1, $person2)
          }
        };


        scope.groupsTypeahead = ['Virginia Company (1606)', 'Marian martyrs 1555', 'Cavalier poets  1640', 'Puritans 1532', 'Castalian band  1584', 'Participants in the vestiarian controversy  1563'];
        scope.groupTypeaheadSelected = scope.groupsTypeahead[0];
      }
    };
  });
