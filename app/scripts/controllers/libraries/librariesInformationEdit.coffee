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

angular.module('narra.ui').controller 'LibrariesInformationEditCtrl', ($scope, $filter, $modalInstance, dialogs, apiProject, apiLibrary, apiUser, apiGenerator, elzoidoMessages, elzoidoAuthUser, data) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.library = data.library
  $scope.initial = angular.copy(data.library)

  apiLibrary.all (data) ->
    $scope.libraries = data.libraries
  apiProject.all (data) ->
    $scope.projects = data.projects
  apiUser.all (data) ->
    $scope.users = data.users
    $scope.filter()
  apiGenerator.all (data) ->
    $scope.generators = data.generators

  $scope.filter = ->
    $scope.contributors = _.filter($scope.users, (user) ->
      !_.isEqual($scope.library.author.username, user.username)
    )

  $scope.close = ->
    $modalInstance.dismiss('canceled')

  # save action
  $scope.edit = ->
    # open waiting
    wait = dialogs.wait('Please Wait', 'Saving library ...')

    # close dialog
    $modalInstance.close(wait)

    apiLibrary.update({
      id: $scope.library.id
      name: $scope.library.name
      author: $scope.library.author.username
      description: $scope.library.description
      generators: _.pluck($scope.library.generators, 'identifier')
      contributors: _.pluck($scope.library.contributors, 'username')
    }, (data) ->
      # update public metadata tag
      apiLibrary.metadataUpdate { id: data.library.id, meta: 'shared', value: $scope.library.shared.toString() }, ->
        # close wait dialog
        wait.close(data.library)
        # fire message
        elzoidoMessages.send('success', 'Success!', 'Library ' + data.library.name + ' was successfully saved.')
    )

  $scope.validateName = (value) ->
    !(_.contains(_.pluck($scope.libraries, 'name'),  value))