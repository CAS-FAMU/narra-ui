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

angular.module('narra.ui').controller 'EventsCtrl', ($scope, $rootScope, $interval, dialogs, apiEvent, elzoidoAuthUser) ->
  $scope.refresh = ->
    apiEvent.user {param: elzoidoAuthUser.get().username}, (data) ->
      _.forEach(data.events, (event) ->
        event.progress = Math.floor(event.progress * 100))
      $scope.events = data.events

  $scope.startRefreshInterval = ->
    # don't start new refresh when it is already on
    if angular.isDefined($scope.refreshInterval) then return
    # reload data
    $scope.refresh()
    # create refresh
    $scope.refreshInterval = $interval(->
      # reload data
      $scope.refresh()
    , 5000)

  $scope.stopRefreshInterval = ->
    # don't start new refresh when it is already on
    if angular.isDefined($scope.refreshInterval)
      $interval.cancel($scope.refreshInterval)
      $scope.refreshInterval = undefined

  # refresh when user is logged
  $scope.$on 'event:elzoido-auth-user', ->
    # refresh
    $scope.startRefreshInterval()

  $scope.$on '$destroy', ->
    # stop current refresh
    $scope.stopRefreshInterval()

  $scope.$watch 'events', (newEvents, oldEvents) ->
    # get finished events
    finished = _.difference(_.pluck(oldEvents, 'id'), _.pluck(newEvents, 'id'))
    # check
    if finished.length > 0
      _.forEach(finished, (id) ->
        # find event
        event = _.find(oldEvents, {id: id})
        # check for the item or project
        if !_.isUndefined(event.item)
          $rootScope.$broadcast 'event:narra-item-updated', event.item.id
        if !_.isUndefined(event.project)
          $rootScope.$broadcast 'event:narra-project-updated', event.project.name
      )