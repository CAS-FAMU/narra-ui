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

angular.module('narra.ui').controller 'ProjectsAddCtrl', ($q, $scope, $filter, $modalInstance, dialogs, apiProject, apiUser, elzoidoMessages, elzoidoAuthUser) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.project = {name: '', title: '', author: $scope.user, description: ''}

  apiProject.all (data) ->
    $scope.projects = data.projects
  apiUser.all (data) ->
    $scope.users = data.users

  $scope.close = ->
    $modalInstance.dismiss('canceled')

  # save action
  $scope.new = ->
    # open waiting
    wait = dialogs.wait('Please Wait', 'Registering new project ...')

    # close dialog
    $modalInstance.close(wait)

    # append date suffix
    project_name = $filter('projectname')($scope.project.name)

    apiProject.new({
        name: project_name
        title: $scope.project.title
        author: $scope.project.author.username
        description: $scope.project.description
        contributors: []
      }, (data) ->
        # close wait dialog
        wait.close(data.project.name)
        # fire message
        elzoidoMessages.send('success', 'Success!', 'Project ' + data.project.title + ' was successfully created.')
    )

  $scope.validateName = (value) ->
    # get deffered object
    validation = $q.defer()
    # validate
    apiProject.validate {name: $filter('projectname')(value)}, (data) ->
      if data.validation then validation.resolve() else validation.reject()
    # promise
    validation.promise

  $scope.validateTitle = (value) ->
    # get deffered object
    validation = $q.defer()
    # validate
    apiProject.validate {title: value}, (data) ->
      if data.validation then validation.resolve() else validation.reject()
    # promise
    validation.promise