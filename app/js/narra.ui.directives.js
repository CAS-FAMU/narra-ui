'use strict';

/*
 #
 # Copyright (C) 2013 CAS / FAMU
 #
 # This file is part of Narra Core.
 #
 # Narra Core is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # Narra Core is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with Narra Core. If not, see <http://www.gnu.org/licenses/>.
 #
 # Authors: Michal Mocnak <michal@marigan.net>, Krystof Pesek <krystof.pesek@gmail.com>
 #
 */

// directives
angular.module('narra.ui.directives', []).
    directive('versionui', ['version', function (version) {
        return function (scope) {
            version.ui(scope);
        };
    }]).
    directive('versioncore', ['version', function (version) {
        return function (scope) {
            scope.$apply
            version.core(scope);
        };
    }]).
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

