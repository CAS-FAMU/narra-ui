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

angular.module('narra.ui').controller 'ProjectsDetailCtrl', ($scope, $rootScope, $routeParams, $location, $filter, $q, dialogs, apiProject, apiUser, elzoidoPromises, elzoidoAuthUser) ->
  $scope.refresh = ->
    # get current user
    $scope.user = elzoidoAuthUser.get()
    # get deffered
    project = $q.defer()

    apiProject.get {name: $routeParams.name}, (data) ->
      _.forEach(data.project.libraries, (library) ->
        library.thumbnails = [] if _.isUndefined(library.thumbnails)
        while library.thumbnails.length < 5
          library.thumbnails.push('/images/empty_project.png'))
      $scope.project = data.project
      project.resolve true

    # register promises into one queue
    elzoidoPromises.register('project', [project.promise])
    # show wait dialog when the loading is taking long
    elzoidoPromises.wait('project', 'Loading project ...')

  $scope.edit = ->
    confirm = dialogs.create('partials/projectsInformationEdit.html', 'ProjectsInformationEditCtrl', {project: $scope.project},
      {size: 'lg', keyboard: false})
    # result
    confirm.result.then (wait) ->
      wait.result.then (project)->
        # fire event
        $rootScope.$broadcast 'event:narra-project-updated', project

  # click function for detail view
  $scope.detail = (library) ->
    $location.path('/libraries/' + library.id + '/' + $scope.project.name)

  # refresh when new library is added
  $rootScope.$on 'event:narra-library-created', (event, status) ->
    $scope.refresh()

  # refresh when new library is added
  $rootScope.$on 'event:narra-project-updated', (event, project) ->
    console.log(event)
    console.log(project)
    if _.isEqual(project.name, $scope.project.name)
      $scope.refresh()
    else
      $location.path('/projects/' + project.name)

  # initial data
  $scope.refresh()