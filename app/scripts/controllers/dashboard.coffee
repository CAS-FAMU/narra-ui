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

angular.module('narra.ui').controller 'DashboardCtrl', ($scope, $rootScope, $location, $q, apiProject, apiItem, elzoidoPromises) ->
  $scope.refresh = ->
    # get deffered
    thumbnails = $q.defer()
    projects = $q.defer()

    # data
    apiItem.thumbnails { param: 10 }, (data) ->
      $scope.thumbnails = if _.isEmpty(data.thumbnails) then ['/images/empty_carousel.png'] else data.thumbnails
      thumbnails.resolve true
    apiProject.all (data) ->
      $scope.projects = _.where(data.projects, { public: true })
      projects.resolve true

    # register promises into one queue
    elzoidoPromises.register('dashboard', [projects.promise, thumbnails.promise])

  # shwo in viewer
  $scope.view = (project) ->
    $location.path('/viewer/' + project.name)

  # refresh when new project is added
  $rootScope.$on 'event:narra-project-created', (event, status) ->
    $scope.refresh()

  # initial data
  $scope.refresh()