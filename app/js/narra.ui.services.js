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

// services
angular.module('narra.ui.services', []).
    service('service_Server', function () {
        this.url = function () {
            return 'http://api.narra.dev';
        };
    }).
    service('service_Messages', function ($rootScope) {
        this.send = function (type, title, message) {
            $rootScope.$broadcast('event:alert', {type: type, title: title, message: message});
        };
    }).
    service('service_User', ['$rootScope', function($rootScope) {
        // empty user object
        var current_user = {name:'Guest', email: 'Guest'};

        $rootScope.$on('event:auth_user', function(event, user) {
            // setup current user
            current_user = user;
        });

        this.current = function() {
            return current_user;
        };
    }]).
    service('service_Token', ['$location', function($location) {
        // empty user object
        var token = _.isUndefined($location.search().token) ? '' : $location.search().token;

        this.current = function() {
            return token;
        };
    }]);
