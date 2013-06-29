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

angular.module('narra.core.api', ['ngResource']).
    factory('Authentication', function ($resource) {
        return $resource('/api/auth/:prefix', {}, {
            active: {method: 'GET', params: {prefix: 'providers/active'}, isArray: false}});
    }).
    factory('User', function ($resource) {
        return $resource('/api/v1/users/:id/:action', {}, {
            all: {method: 'GET', params: {id: '', action: ''}, isArray: false},
            get: {method: 'GET', params: {action: ''}, isArray: false },
            me: {method: 'GET', params: {id: 'me', action: ''}, isArray: false},
            signout: {method: 'GET', params: {id: 'me', action: 'signout'}, isArray: false},
            delete: {method: 'GET', params: {id: '@id', action: 'delete'}}});
    }).
    factory('System',function ($resource) {
        return $resource('/api/v1/system/:prefix', {}, {
            version: {method: 'GET', params: {prefix: 'version'}, isArray: false}});
    }).
    factory('Settings', function ($resource) {
        return $resource('/api/v1/settings/:name/:action', {}, {
            all: {method: 'GET', params: {name: ''}, isArray: false},
            get: {method: 'GET', isArray: false},
            defaults: {method: 'GET', params: {name: 'defaults'}, isArray: false},
            update: {method: 'GET', params: {action: 'update'}}});
    });