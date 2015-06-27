#
# Copyright (C) 2015 CAS / FAMU
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

angular.module('narra.ui').controller 'VisualizationsCtrl', ($scope, $rootScope, $location, $interval, $filter, $q, dialogs, apiProject, apiVisualization, apiUser, elzoidoPromises, elzoidoAuthUser) ->
  $scope.refresh = ->
    # get current user
    $scope.user = elzoidoAuthUser.get()
    # get deffered
    visualizations = $q.defer()

    apiVisualization.all (data) ->
      _.forEach(data.visualizations, (visualization) ->
        visualization.thumbnail = '/images/bars.png')
      $scope.myVisualizations = _.filter(data.visualizations, (visualization) ->
        _.isEqual(visualization.author.username, $scope.user.username))
      $scope.publicVisualizations = _.filter(data.visualizations, (visualization) ->
        visualization.public && !_.contains(_.pluck($scope.myVisualizations, 'id'), visualization.id)
      )
      visualizations.resolve true

    # register promises into one queue
    elzoidoPromises.register('visualizations', [visualizations.promise])
    # show wait dialog when the loading is taking long
    elzoidoPromises.wait('visualizations', 'Loading visualizations ...')

  # click function for detail view
  $scope.detail = (visualization) ->
    $location.path('/visualizations/' + visualization.id)

  # refresh when user is logged
  $rootScope.$on 'event:elzoido-auth-user', (event, status) ->
    $scope.refresh()

  # refresh when new library is added
  $rootScope.$on 'event:narra-visualization-created', (event, status) ->
    $scope.refresh()

  # initial data
  $scope.refresh()