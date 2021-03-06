'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalSignupCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalSignupCtrl', ['$scope', '$uibModalInstance', '$timeout', '$window', 'apiService', function($scope, $uibModalInstance, $timeout, $window, apiService) {

    var $ctrl = this;
    
    $ctrl.cancel = function() {
      console.log('dismiss')
      $uibModalInstance.dismiss('cancel');
    };

    $ctrl.close = function() {
      $uibModalInstance.close($ctrl.new);
    }

  }]);
