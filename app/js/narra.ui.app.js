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

// main application settings and routing
angular.module('narra.ui.app', ['narra.core.api', 'narra.ui.filters', 'narra.ui.services',
        'narra.ui.directives', 'ui.bootstrap', 'ui.utils', 'ui.select2', 'ngSanitize', 'ngCookies']).
    config(function ($routeProvider, $locationProvider, $httpProvider) {
        // set html5 pushstate
        $locationProvider.html5Mode(true);

        // set up routing
        $routeProvider.
            when('/', {
                templateUrl: '/partials/dashboard.html',
                controller: DashboardCtrl
            }).
            when('/users', {
                templateUrl: '/partials/users.html',
                controller: UsersCtrl
            }).
            when('/users/:id', {
                templateUrl: '/partials/users_detail.html',
                controller: UsersDetailCtrl
            }).
            when('/system/settings', {
                templateUrl: '/partials/system_settings.html',
                controller: SystemSettingsCtrl
            });

        var interceptor = ['$q', '$rootScope', '$location', 'messages', function ($q, $rootScope, $location, messages) {
            function success(response) {
                return response;
            }

            function error(response) {
                // handle response
                if (response.status === 401) {
                    // fire login required event
                    $rootScope.$broadcast('event:auth_unauthenticated');
                    return $q.reject(response);
                } else {
                    return $q.reject(response);
                }
            }

            return function (promise) {
                return promise.then(success, error);
            }
        }];

        $httpProvider.responseInterceptors.push(interceptor);
    });