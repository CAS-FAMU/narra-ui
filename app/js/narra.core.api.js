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

angular.module('narra.core.api', ['ngResource']).
    factory('api_Authentication', function ($resource, service_Server) {
        return $resource(service_Server.url() + '/auth/:prefix', {}, {
            active: {method: 'GET', params: {prefix: 'providers/active'}, isArray: false}});
    }).
    factory('api_User', function ($resource, service_Server, service_Token) {
        return $resource(service_Server.url() + '/v1/users/:id/:action', { token: service_Token.current() }, {
            all: {method: 'GET', params: {id: '', action: ''}, isArray: false},
            get: {method: 'GET', params: {action: ''}, isArray: false },
            me: {method: 'GET', params: {id: 'me', action: ''}, isArray: false},
            signout: {method: 'GET', params: {id: 'me', action: 'signout'}, isArray: false},
            delete: {method: 'GET', params: {action: 'delete'}}});
    }).
    factory('api_Project', function ($resource, service_Server, service_Token) {
        return $resource(service_Server.url() + '/v1/projects/:name/:action', { token: service_Token.current() }, {
            all: {method: 'GET', params: {object_id: '', action: ''}, isArray: false},
            get: {method: 'GET', isArray: false },
            new: {method: 'POST', params: {action: 'new'}, isArray: false},
            update: {method: 'POST', params: {name: '@name', action: 'update'}, isArray: false},
            delete: {method: 'GET', params: {action: 'delete'}}});
    }).
    factory('api_System',function ($resource, service_Server, service_Token) {
        return $resource(service_Server.url() + '/v1/system/:prefix', { token: service_Token.current() }, {
            version: {method: 'GET', params: {prefix: 'version'}, isArray: false}});
    }).
    factory('api_Settings', function ($resource, service_Server, service_Token) {
        return $resource(service_Server.url() + '/v1/settings/:name/:action', { token: service_Token.current() }, {
            all: {method: 'GET', params: {name: ''}, isArray: false},
            get: {method: 'GET', isArray: false},
            defaults: {method: 'GET', params: {name: 'defaults'}, isArray: false},
            update: {method: 'POST', params: {name: '@name', action: 'update'}}});
    });
