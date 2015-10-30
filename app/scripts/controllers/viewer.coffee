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

angular.module('narra.ui').controller 'ViewerCtrl', ($scope, $routeParams, $window, $rootScope, $q, apiProject, apiVisualization, elzoidoPromises, serviceLayouts) ->
# inicialization
  $scope.refresh = ->
# get deffered
    project = $q.defer()

    apiProject.get {name: $routeParams.project}, (data) ->
      data.project.metadata = _.filter(data.project.metadata, (meta) ->
        !_.isEqual(meta.name, 'public'))
      $scope.project = data.project
      $rootScope.project = data.project
      # resolve
      project.resolve true

    # register promises into one queue
    elzoidoPromises.register('viewer', [project.promise])
    elzoidoPromises.promise('viewer').then ->
      $rootScope.viewer = true
      # resolve layout or visualization
      if !_.isUndefined($routeParams.visualization)
        # get layout
        visualizationLayout = _.find(serviceLayouts.layouts(), { id: 'visualization_only' })
        # setup object
        visualizationLayout.options['visualization'] = $routeParams.visualization
        # set
        $scope.layout = visualizationLayout
      else
        if _.isUndefined($routeParams.layout)
          $scope.layout = _.find($scope.project.layouts, { main: true })
        else
          $scope.layout = _.find($scope.project.layouts, { id: $routeParams.layout })

  # initial data
  $scope.refresh()