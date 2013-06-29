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

// services
angular.module('narra.ui.services', []).
    service('version', function ($filter, System) {
        this.ui = function (scope) {
            scope.versionUi = 'dev ' + $filter('date')(new Date(), 'yyyyMMdd');
        };

        this.core = function (scope) {
            System.version(function (data) {
                scope.versionCore = data.version.branch + " " + data.version.revision;
            });
        };
    }).
    service('messages', function ($rootScope) {
        this.send = function (type, title, message) {
            $rootScope.$broadcast('event:alert', {type: type, title: title, message: message});
        };
    }).
    service('user', ['$rootScope', function($rootScope) {
        // empty user object
        var current_user = {name:'Guest', email: 'Unregistered'};

        $rootScope.$on('event:auth_user', function(event, user) {
            // setup current user
            current_user = user;
        });

        this.current = function() {
            return current_user;
        };
    }]);
