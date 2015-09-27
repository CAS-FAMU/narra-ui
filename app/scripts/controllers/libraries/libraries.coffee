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

angular.module('narra.ui').controller 'LibrariesCtrl', ($scope, $rootScope, $location, $interval, $filter, $q, dialogs, apiProject, apiLibrary, apiUser, elzoidoPromises, elzoidoAuthUser, elzoidoMessages) ->
  # initialization
  $scope.rotation = {}
  $scope.thumbnail = {}

  $scope.refresh = ->
    # get current user
    $scope.user = elzoidoAuthUser.get()
    # get deffered
    libraries = $q.defer()

    apiLibrary.all (data) ->
      _.forEach(data.libraries, (library) ->
        $scope.thumbnail[library.name] = library.thumbnails[0])
      $scope.libraries = _.filter(data.libraries, (library) ->
        _.isEqual(library.author.username, $scope.user.username))
      $scope.contributions = _.filter(data.libraries, (library) ->
        _.contains(_.pluck(library.contributors, 'username'), $scope.user.username))
      libraries.resolve true

    # register promises into one queue
    elzoidoPromises.register('libraries', [libraries.promise])

  $scope.startRotation = (library) ->
    # don't start new refresh when it is already on
    if angular.isDefined($scope.rotation[library.name]) then return
    # counter
    count = 0
    # rotate
    $scope.rotation[library.name] = $interval(->
      # revalidate count
      if count + 1 == library.thumbnails.length then count = 0 else count++
      # rotate
      $scope.thumbnail[library.name] = library.thumbnails[count]
    , 600)

  $scope.stopRotation = (library) ->
    # don't start new refresh when it is already on
    if angular.isDefined($scope.rotation[library.name])
      $interval.cancel($scope.rotation[library.name])
      $scope.rotation[library.name] = undefined
      $scope.thumbnail[library.name] = library.thumbnails[0]

  # refresh when user is logged
  $rootScope.$on 'event:elzoido-auth-user', (event, status) ->
    $scope.refresh()

  # refresh when new library is added
  $rootScope.$on 'event:narra-library-created', (event, status) ->
    $scope.refresh()

  # refresh when new library is added
  $rootScope.$on 'event:narra-library-purged', (event, status) ->
    $scope.refresh()

  # click function for detail view
  $scope.detail = (library) ->
    $location.path('/libraries/' + library.id)

  # initial data
  $scope.refresh()