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
      project.resolve true

    project.promise.then ->
<<<<<<< HEAD
      # resolve main layout
      $scope.layout = _.find($scope.project.layouts, { main: true })

    # register promises into one queue
    elzoidoPromises.register('viewer', [project.promise])
=======
      # get junctions
      _.forEach($scope.project.synthesizers, (synthesizer, index) ->
        apiProject.junctions {name: $routeParams.project, param: synthesizer.identifier}, (data) ->
          $scope.junctions[synthesizer.identifier] = data.junctions
          if index + 1 == $scope.project.synthesizers.length
            junctions.resolve true
      )
      # get visualization
      if _.isUndefined($routeParams.visualization)
        apiVisualization.get {id: $scope.project.visualizations[0].id }, (data) ->
          $scope.visualization = data.visualization
          visualization.resolve true
      else
        apiVisualization.get {id: $routeParams.visualization }, (data) ->
          $scope.visualization = data.visualization
          visualization.resolve true

    apiProject.items {name: $routeParams.project}, (data) ->
      $scope.items = data.items
      items.resolve true

    # register promises into one queue
    elzoidoPromises.register('viewer', [project.promise, junctions.promise, items.promise, visualization.promise])
    # wait for complete
    elzoidoPromises.promise('viewer').then ->
      $scope.ready = true
      if ($scope.visualization.type == 'p5js')
        angularLoad.loadScript($scope.visualization.script).then ->
          $scope.sketch = $window.visualization
>>>>>>> 868bc4fe6d935be804568c2edb59620d99768dd8

  # initial data
  $scope.refresh()