'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalReviewCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalReviewCtrl', ['$scope', '$uibModalInstance', '$timeout', 'addToDB', '$window', 'apiService', '$rootScope', 'addedNodes', 'addedGroups', 'addedLinks', function($scope, $uibModalInstance, $timeout, addToDB, $window, apiService, $rootScope, addedNodes, addedGroups, addedLinks) {

    var $ctrl = this;
    $ctrl.addToDB = addToDB;
    $ctrl.addedNodes = addedNodes;
    $ctrl.addedGroups = addedGroups;
    $ctrl.addedLinks = addedLinks;
    // $ctrl.sendData = sendData;

    $ctrl.remove = function(index, list1, list2) {
      list1.splice(index,1);
      if (list2 !== undefined) {
        list2.splice(index,1);
      }
    };

    $ctrl.ok = function() {
      $uibModalInstance.close($ctrl.selected.group);
    };

    $ctrl.cancel = function() {
      // console.log('dismiss')
      $uibModalInstance.dismiss($ctrl.addToDB);
    };

    $ctrl.submit = function() {
      $ctrl.addToDB.auth_token = $rootScope.user.auth_token;

      $ctrl.addToDB.links.forEach (function(l) {
        delete l.id;
      })
      apiService.writeData($ctrl.addToDB).then(function(result) {
        $ctrl.addToDB = {nodes: [], links: [], groups: [], group_assignments: []};
        $ctrl.addedNodes = [];
        $ctrl.addedLinks = [];
        $ctrl.addedGroups = [];
        // $scope.$parent.newNode = {};
        // $scope.$parent.addedNodeId = 0;
        // $scope.$parent.newLink = {source:{}, target: {}};
        // $scope.$parent.newGroup = {};
        // $scope.$parent.groupAssign = {person: {}, group: {}};
        // $scope.$parent.config.added = false;
        $scope.reviewSuccess = true;
        // $scope.$parent.updateNetwork($scope.$parent.data);
      }, function(error) {
        console.error("An error occured while fetching file",error);
        $scope.reviewFailure = true;
      });

    }

  }]);
