#
# Copyright (C) 2014 CAS / FAMU
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
# Authors: Michal Mocnak <michal@marigan.net>
#

angular.module('narra.ui').controller 'UsersCtrl', ($scope, $rootScope, $q, $location, dialogs, apiUser, elzoidoPromises, elzoidoAuthUser, elzoidoAuthAPI) ->
  # refresh function
  $scope.refresh = ->
    # get deffered
    users = $q.defer()
    # get all projects and get back to view
    apiUser.all (data) ->
      $scope.users = data.users
      $scope.empty = (data.length < 1)
      users.resolve true
    # register promises into one queue
    elzoidoPromises.register('users', users.promise)

  $scope.edit = (user) ->
    confirm = dialogs.create('partials/usersEdit.html', 'UsersEditCtrl', {user: user},
      {size: 'lg', keyboard: false})
    # result
    confirm.result.then (wait) ->
      wait.result.then ->
        # fire event
        $rootScope.$broadcast 'event:narra-user-updated'
        # check if updating current user
        elzoidoAuthAPI.signin() if _.isEqual(user.username, elzoidoAuthUser.get().username)

  # refresh when new user is updated
  $rootScope.$on 'event:narra-user-updated', (event, status) ->
    $scope.refresh()

  # initial data
  $scope.refresh()