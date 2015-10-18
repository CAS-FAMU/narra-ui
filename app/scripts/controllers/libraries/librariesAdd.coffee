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

angular.module('narra.ui').controller 'LibrariesAddCtrl', ($q, $scope, $filter, $modalInstance, dialogs, apiLibrary, apiProject, apiUser, apiGenerator, elzoidoMessages, elzoidoAuthUser) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.library = { name: '', description: '', author: $scope.user, project: undefined }

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
  apiGenerator.all (data) ->
    $scope.generators = data.generators

  $scope.close = ->
    $modalInstance.dismiss('canceled')

  # save action
  $scope.new = ->
    # open waiting
    wait = dialogs.wait('Please Wait', 'Registering new library ...')

    # close dialog
    $modalInstance.close(wait)

    # prepare project
    if _.isUndefined($scope.library.project)
      $scope.library.project = {name: undefined}

    apiLibrary.new({
      name: $scope.library.name
      author: $scope.library.author.username
      description: $scope.library.description
      generators: []
      contributors: []
      project: $scope.library.project.name
    }, (data) ->
      # close wait dialog
      wait.close(data.library.id)
      # fire message
      elzoidoMessages.send('success', 'Success!', 'Library ' + data.library.name + ' was successfully created.')
    )

  $scope.validateName = (value) ->
# get deffered object
    validation = $q.defer()
    # validate
    apiLibrary.validate {name: value}, (data) ->
      if data.validation then validation.resolve() else validation.reject()
    # promise
    validation.promise