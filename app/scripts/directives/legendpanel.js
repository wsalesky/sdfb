'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:legendPanel
 * @description
 * # legendPanel
 */
angular.module('redesign2017App')
  .directive('legendPanel', function () {
    return {
      template: '<div></div>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        element.text('this is the legendPanel directive');
      }
    };
  });
