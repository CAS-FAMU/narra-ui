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

angular.module('narra.ui').controller 'LayoutsVisualizationOnlyCtrl', ($scope, $routeParams, $window, $rootScope, $q, apiProject, apiVisualization, elzoidoPromises, angularLoad) ->
  # narra api for processing
  $window.narra =
    width: $window.innerWidth - 5
    height: $window.innerHeight - 5
    getProject: ->
      $scope.project
    getItems: (synthesizer, item) ->
      if _.isUndefined(synthesizer)
        $scope.items
      else
        _.reject(_.flatten(_.pluck(_.where($scope.junctions[synthesizer], {items: [{id: item}]}), 'items')), {id: item})
    getItem: (item) ->
      _.find($scope.items, {id: item})
    getJunctions: (synthesizer, item) ->
      if _.isUndefined(item)
        $scope.junctions[synthesizer]
      else
        _.where($scope.junctions[synthesizer], {items: [{id: item}]})

  # inicialization
  $scope.visualization = {}
  $scope.meta = {}

  $scope.refresh = ->
    junctions = $q.defer()
    items = $q.defer()
    visualization = $q.defer()
    $scope.junctions = {}

    # get junctions
    if !_.isEmpty($scope.project.synthesizers)
      _.forEach($scope.project.synthesizers, (synthesizer, index) ->
        apiProject.junctions {name: $scope.project.name, param: synthesizer.identifier}, (data) ->
          $scope.junctions[synthesizer.identifier] = data.junctions
          if index + 1 == $scope.project.synthesizers.length
            junctions.resolve true
      )
    else
      junctions.resolve true

    # get visualization
    apiVisualization.get {id: $scope.layout.options['visualization'] }, (data) ->
      $scope.visualization = data.visualization
      visualization.resolve true

    # get items
    apiProject.items {name: $scope.project.name}, (data) ->
      $scope.items = data.items
      items.resolve true

    # register promises into one queue
    elzoidoPromises.register('viewer', [junctions.promise, items.promise, visualization.promise])
    elzoidoPromises.promise('viewer').then ->
      $scope.ready = true
      if ($scope.visualization.type == 'p5js')
        angularLoad.loadScript($scope.visualization.script).then ->
          $scope.sketch = $window.visualization

  # initial data
  $scope.refresh()