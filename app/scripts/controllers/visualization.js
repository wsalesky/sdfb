'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:VisualizationCtrl
 * @description
 * # VisualizationCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('VisualizationCtrl', function($scope, $uibModal, $log, $document, apiService, initialConfig, initialData) {
    // console.log(initialConfig,initialData);
    $scope.config = initialConfig;
    $scope.data = initialData;
    $scope.legendClosed = false;
    $scope.filtersClosed = true;
    $scope.peopleFinderClosed = true;

    // Container for data realted to groups
    $scope.groups = {};

    // declare a $scope property where to store the future selections
    $scope.currentSelection = {}

    // Other groups modal window
    $scope.modalAnimationsEnabled = true;
    $scope.open = function(size, parentSelector) {
      var parentElem = parentSelector ?
        angular.element($document[0].querySelector('.modal-demo ' + parentSelector)) : undefined;
      var modalInstance = $uibModal.open({
        animation: $scope.modalAnimationsEnabled,
        ariaLabelledBy: 'modal-title',
        ariaDescribedBy: 'modal-body',
        templateUrl: './views/modal-other-groups.html',
        controller: 'ModalinstanceCtrl',
        controllerAs: '$ctrl',
        size: size,
        appendTo: parentElem,
        resolve: {
          groups: function() {
            return $scope.groups.otherGroups;
          },
          currentSelection: function() {
            return $scope.currentSelection;
          }
        }
      });
      modalInstance.result.then(function(selectedItem) {
        $scope.selected = selectedItem;
      }, function() {
        $log.info('Modal dismissed at: ' + new Date());
      });
    };

    $scope.data4groups = function() {
      console.log('data4groups');
      // GET DATA FOR GROUPS
      // use lodash to create a dictionary with groupId as key and group occurrencies as value (eg '81': 17)
      var data4groups = $scope.data.included
      var listGroups = [];
      data4groups.forEach(function(d) {
        if (d.attributes.groups) {
          d.attributes.groups.forEach(function(e) {
            listGroups.push(e);
          })
        }
      });
      listGroups = _.countBy(listGroups);

      //Transform that dictionary into an array of objects (eg {'groupId': '81', 'value': 17})
      var arr = [];
      for (var group in listGroups) {
        if (listGroups.hasOwnProperty(group)) {
          var obj = {
            'groupId': group,
            'value': listGroups[group]
          }
          arr.push(obj);
        }
      }

      //Sort the array in descending order
      arr.sort(function(a, b) {
        return d3.descending(a.value, b.value);
      })
      var cutAt = 20;
      var groupsBar = _.slice(arr, 0, cutAt);
      var otherGroups = _.slice(arr, cutAt);
      var othersValue = 0;
      otherGroups.forEach(function(d) {
        othersValue += d.value;
      });
      groupsBar.push({ 'groupId': 'others', 'value': othersValue, 'amount': otherGroups.length });
      $scope.groups.groupsBar = groupsBar;
      $scope.groups.otherGroups = otherGroups;
      // console.log('Data for groups bar ($scope.groups):', scope.groups);

      // $scope.$emit('Update the groups bar', $scope.groups)

    }

    $scope.data4groups();

    // console.log('broadcast update the force layout')
    // $scope.$broadcast('Update the force layout', { mode: 'force' });
    // console.log('broadcast update the groups bar')
    // $scope.$broadcast('Update the groups bar', 'ciao');

    // write above
    // $scope.$watch('config', function(newValue, oldValue) {
    //   if (newValue !== oldValue) {
    //     console.log('config')
    //     var config = newValue;
    //     // $scope.legendClosed = false;
    //     // $scope.filtersClosed = true; //Stopped filters from automatically closing
    //     if (config.viewObject == 0 && config.viewMode == 'individual-force') {
    //       // console.log('Show individual hooke network')
    //       // $scope.$broadcast('Update the force layout', { mode: 'force' });
    //     } else if (config.viewObject == 0 && config.viewMode == 'individual-concentric') {
    //       // console.log('Show individual concentric network')
    //       // $scope.$broadcast('Update the force layout', { mode: 'concentric' });
    //     } else if (config.viewObject == 1 && config.viewMode == 'all') {
    //       // console.log('All the groups')
    //     }
    //   }
    // }, true);
  });
