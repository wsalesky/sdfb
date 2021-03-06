'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:navigationDirective
 * @description
 * # navigationDirective
 */
angular.module('redesign2017App')
  .directive('navigationDirective', ['$window', 'apiService', '$cookieStore', '$rootScope', function ($window, apiService, $cookieStore, $rootScope) {
    return {
      templateUrl: './views/navigation-directive.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {

        scope.toggleContribute = function() {
          if ($rootScope.user && $rootScope.user.is_active) {
            scope.config.contributionMode = !scope.config.contributionMode;

            if (scope.config.contributionMode) {
              scope.cursorStyle = {'cursor': 'copy'};
              $rootScope.filtersClosed = false;
              $rootScope.legendClosed = true;
              $rootScope.searchClosed = true;
            } else {
              scope.cursorStyle = {'cursor': 'auto'};
            }
          }
          else {
            // $('.login-toggle').dropdown('toggle');
            $window.alert("You must log in before you can contribute.")
            scope.cursorStyle = {'cursor': 'auto'};
          }
        }

        var now = new Date()
        scope.today = now.getFullYear() + '_' + ("0" + (now.getMonth() + 1)).slice(-2) + '_' + ("0" + now.getDate()).slice(-2);

        scope.logIn = function() {
          apiService.logIn($rootScope.user).then(function(result) {
            $rootScope.user = result.data;
            var session = angular.copy($rootScope.user);
            scope.logInFailed = false;
            delete session.status;
            delete session.error;

            $cookieStore.put('session', session);
          }, function(error) {
            scope.logInFailed = true;
            console.log(error);
          });
        }

        scope.logOut = function() {
          var logOut = {'auth_token': $rootScope.user.auth_token}
          apiService.logOut(logOut).then(function(result) {
            $rootScope.user = {};
            $cookieStore.put('session', null);
          });
        }

      }
    };
  }]);
