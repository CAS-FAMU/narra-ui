'use strict';

/*
 #
 # Copyright (C) 2013 CAS / FAMU
 #
 # This file is part of Narra UI.
 #
 # Narra UI is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # Narra UI is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with Narra UI. If not, see <http://www.gnu.org/licenses/>.
 #
 # Authors: Michal Mocnak <michal@marigan.net>, Krystof Pesek <krystof.pesek@gmail.com>
 #
 */

// directives
angular.module('narra.ui.directives', []).
    directive('version', function () {
        return {
            restrict: 'E',
            transclude: true,
            template: '<span>{{version}}</span>',
            controller: function($scope, $attrs, $filter, api_System) {
                if (!_.isUndefined($attrs.ui)) {
                    $scope.version = 'dev ' + $filter('date')(new Date(), 'yyyyMMdd');
                } else if(!_.isUndefined($attrs.core)) {
                    api_System.version(function (data) {
                        $scope.version = data.version.branch + " " + data.version.revision;
                    });
                }
            },
            replace: false
        };
    }).
    directive('navigation',function () {
        return {
            restrict: 'E',
            transclude: true,
            scope: {},
            controller: 'ComponentsNavigationCtrl',
            templateUrl: '/partials/components_navigation.html',
            replace: false
        };
    }).
    directive('user',function () {
        return {
            restrict: 'E',
            transclude: true,
            scope: {},
            controller: 'ComponentsUserCtrl',
            templateUrl: '/partials/components_user.html',
            replace: false
        };
    }).
    directive('login',function () {
        return {
            restrict: 'E',
            transclude: true,
            scope: {},
            controller: 'ComponentsLoginCtrl',
            templateUrl: '/partials/components_login.html',
            replace: false
        };
    }).
    directive('messages',function () {
        return {
            restrict: 'E',
            transclude: true,
            scope: {},
            controller: 'ComponentsMessagesCtrl',
            templateUrl: '/partials/components_messages.html',
            replace: false
        };
    }).
    directive('access',function (service_User) {
        return {
            restrict: 'A',
            link: function ($scope, $element, $attrs) {
                // hidden flag
                var hidden = false;

                // refresh fucntion
                var refresh = function () {
                    // prepare access attributes
                    var data = $attrs.access.split('|');
                    var roles = data[0].split(',');
                    var object = _.isUndefined(data[1]) ? data[1] : JSON.parse(data[1]);
                    var user = service_User.current();

                    // checks if user has access to this element
                    if (_.contains(user.roles, 'admin') || _.isUndefined($attrs.access) || _.isEmpty($attrs.access)) {
                        // show element
                        hide(false);
                    } else if (_.isEmpty(_.intersection(user.roles, roles))) {
                        // hide element
                        hide(true);
                    } else if ((!_.isUndefined(object) && !_.isEqual(user.id, object.owner.id))) {
                        // hide element
                        hide(true);
                    } else {
                        // show element
                        hide(false);
                    }
                }

                // show or hide element
                var hide = function(state) {
                    // hide or show element
                    state ? $element.hide() : $element.show();
                    // set flag
                    hidden = state
                }

                // preserves that access directive has master privileges
                if (!_.isUndefined($attrs.ngShow)) {
                    $scope.$watch($attrs.ngShow, function (value) {
                        if (!_.isUndefined(value)) {
                            hidden ? $element.hide() : $element.show();
                        }
                    }, true);
                }

                // listener for the attribute evaluation
                // workaround for using expressions in attributes
                $attrs.$observe('access', function() {
                   refresh();
                });

                // listener for the initial user login
                // workaround for the title page to be refreshed after login
                $scope.$on('event:auth_user', function () {
                    refresh();
                });
            }
        };
    });

angular.module('ng').directive('ngFocus', function ($timeout) {
    return {
        link: function (scope, element, attrs) {
            scope.$watch(attrs.ngFocus, function (val) {
                if (!_.isUndefined(val) && val) {
                    $timeout(function () {
                        element[0].focus();
                    });
                }
            }, true);

            element.bind('blur', function () {
                if (!_.isUndefined(attrs.ngFocusLost)) {
                    scope.$apply(attrs.ngFocusLost);

                }
            });
        }
    };
});

