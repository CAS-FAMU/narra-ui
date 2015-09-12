#
# Copyright (C) 2014 CAS / FAMU
#
# This file is part of narra-ui.
#
# narra-ui is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# narra-ui is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with narra-ui. If not, see <http://www.gnu.org/licenses/>.
#
# Authors: Michal Mocnak <michal@marigan.net>
#

angular.module('narra.ui').config(($httpProvider, elzoidoAuthModule) ->
  # install elzoido auth into the application
  $httpProvider.interceptors.push('elzoidoAuthInterceptor')

  # static configuration elzoido auth plugin
  elzoidoAuthModule.config.userProvider = 'apiUser'
  elzoidoAuthModule.config.providersProvider = 'apiAuth'
).run ($rootScope, $q, $window, $cookies, dialogs, elzoidoAuthModule, elzoidoAuthUser, elzoidoAuthAPI, serviceToken, serviceServer, apiUser) ->
  # dynamic configuration elzoido auth plugin
  elzoidoAuthModule.config.functionProfile = ->
    confirm = dialogs.create('partials/usersEdit.html', 'UsersEditCtrl', {user: elzoidoAuthUser.get()},
      {size: 'lg', keyboard: false})
    # result
    confirm.result.then (wait) ->
      wait.result.then ->
        # fire event
        $rootScope.$broadcast 'event:narra-user-updated'
        # signin again to refresh current user data
        elzoidoAuthAPI.signin()

  elzoidoAuthModule.config.functionSignin = (provider) ->
    # get deffered
    deferred = $q.defer()
    # token check
    if !serviceToken.get()
      # get deffered
      dialogs.wait('Please wait', 'You are being authenticated right now ...')
      # signin user
      $window.location.href = serviceServer.url + '/auth/' + provider
    # resolve
    deferred.resolve true
    # return promise
    deferred.promise

  elzoidoAuthModule.config.functionSignout = ->
    # get deffered
    deferred = $q.defer()
    # signout user
    apiUser.signout ->
      # delete token
      $cookies.remove('_narra_ui_token')
      # redirect to root
      $window.location.href = '/'
      # resolve
      deferred.resolve true
    # return promise
    deferred.promise

  # autosign check
  if serviceToken.get()
    elzoidoAuthAPI.signin()