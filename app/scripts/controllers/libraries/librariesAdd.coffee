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

angular.module('narra.ui').controller 'LibrariesAddCtrl', ($scope, $filter, $modalInstance, dialogs, apiLibrary, apiProject, apiUser, apiGenerator, elzoidoMessages, elzoidoAuthUser) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.library = { name: '', description: '', author: $scope.user, contributors: [], generators: [], project: '' }

  apiLibrary.all (data) ->
    $scope.libraries = data.libraries
  apiProject.all (data) ->
    temporary = angular.copy(data.projects)
    if !$scope.user.isAdmin()
      _.remove(temporary, (project) ->
        !_.contains(_.pluck(project.contributors, 'username').concat([project.author.username]), $scope.user.username))
    $scope.projects = temporary
  apiUser.all (data) ->
    $scope.users = data.users
    $scope.filter()
  apiGenerator.all (data) ->
    $scope.generators = data.generators

  $scope.filter = ->
    temporary = angular.copy($scope.users)
    _.remove(temporary, (user) ->
      _.isEqual(user.username, $scope.library.author.username))
    $scope.contributors = temporary

  $scope.close = ->
    $modalInstance.dismiss('canceled')

  # save action
  $scope.new = ->
    # open waiting
    wait = dialogs.wait('Please Wait', 'Registering new library ...')

    # close dialog
    $modalInstance.close(wait)

    apiLibrary.new({
      name: $scope.library.name
      author: $scope.library.author.username
      description: $scope.library.description
      generators: _.pluck($scope.library.generators, 'identifier')
      contributors: _.pluck($scope.library.contributors, 'username')
      project: $scope.library.project.name
    }, (data) ->
      # close wait dialog
      wait.close(data.library.id)
      # fire message
      elzoidoMessages.send('success', 'Success!', 'Library ' + data.library.name + ' was successfully created.')
    )

  $scope.validateName = (value) ->
    !_.contains(_.pluck($scope.libraries, 'name'),  value)