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

angular.module('narra.ui').controller 'UsersEditCtrl', ($scope, $q, $location, $filter, $modalInstance, dialogs, apiUser, elzoidoMessages, elzoidoAuthUser, data) ->
  # receive user through dialog data
  $scope.user = data.user
  $scope.username = data.user.username
  $scope.admin = elzoidoAuthUser.get().isAdmin()

  apiUser.all (data) ->
    $scope.users = data.users

  apiUser.roles (data) ->
    $scope.roles = data.roles

  $scope.close = ->
    $modalInstance.dismiss('canceled')

  # save action
  $scope.edit = ->
    # open waiting
    wait = dialogs.wait('Please Wait', 'Saving user ...')

    # close dialog
    $modalInstance.close(wait)

    # filter username
    username = $filter('projectname')($scope.user.username)

    apiUser.update({
        username: $scope.username
        new_username: username
        roles: $scope.user.roles
      }, (data) ->
      # close wait dialog
      wait.close()
      # fire message
      elzoidoMessages.send('success', 'Success!', 'User ' + data.user.name + ' was successfully saved.')
    )

  $scope.validateUsername = (value)->
    !_.contains(_.pluck($scope.users, 'username'),  $filter('projectname')(value))

  $scope.validateRolesRequired = (value)->
    !_.isEmpty(value)

  $scope.validateRolesAdmin = (value)->
    return true if _.contains(value, 'admin')
    # get all admin users
    admins = _.where($scope.users, 'roles': ['admin'])
    # if more admins than it is fine
    return true if admins.length > 1
    # if currently edited user is not that admin
    return true if _.isEmpty(_.where(admins, 'username': $scope.username))