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

angular.module('narra.ui').controller 'ViewerCtrl', ($scope, $routeParams, $window, $rootScope, $q, apiProject, elzoidoPromises, angularLoad) ->
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

  $scope.refresh = ->
    # get deffered
    project = $q.defer()
    junctions = $q.defer()
    items = $q.defer()
    $scope.junctions = {}

    apiProject.get {name: $routeParams.project}, (data) ->
      _.forEach(data.project.visualizations, (visualization) ->
        visualization.thumbnail = '/images/bars.png')
      _.forEach(data.project.libraries, (library) ->
        library.thumbnails = [] if _.isUndefined(library.thumbnails)
        while library.thumbnails.length < 5
          library.thumbnails.push('/images/bars.png'))
      data.project.metadata = _.filter(data.project.metadata, (meta) ->
        !_.isEqual(meta.name, 'public'))
      $scope.project = data.project
      $scope.visualization = data.project.visualizations[0]
      $rootScope.project = data.project
      project.resolve true

    project.promise.then ->
      # get junctions
      _.forEach($scope.project.synthesizers, (synthesizer, index) ->
        apiProject.junctions {name: $routeParams.project, param: synthesizer.identifier}, (data) ->
          $scope.junctions[synthesizer.identifier] = data.junctions
          if index + 1 == $scope.project.synthesizers.length
            junctions.resolve true
      )

    apiProject.items {name: $routeParams.project}, (data) ->
      $scope.items = data.items
      items.resolve true

    items.promise.then ->
      $scope.ready = true
      if ($scope.visualization.type == 'p5.js')
        angularLoad.loadScript($scope.visualization.script).then ->
          $scope.sketch = $window.visualization

    # register promises into one queue
    elzoidoPromises.register('viewer', [project.promise, junctions.promise, items.promise])

  # initial data
  $scope.refresh()