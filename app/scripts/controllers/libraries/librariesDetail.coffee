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

angular.module('narra.ui').controller 'LibrariesDetailCtrl', ($scope, $rootScope, $routeParams, $location, $document, $interval, $filter, $q, dialogs, apiProject, apiLibrary, apiUser, elzoidoPromises, elzoidoAuthUser, elzoidoMessages) ->
  # set up context
  $scope.project = $routeParams.project
  $scope.from = $routeParams.from
  # initialization
  $scope.rotation = {}
  $scope.thumbnail = {}

  # refresh data
  $scope.refresh = ->
    # get current user
    $scope.user = elzoidoAuthUser.get()
    # get deffered
    library = $q.defer()
    items = $q.defer()

    apiLibrary.get {id: $routeParams.library}, (data) ->
      $scope.library = data.library
      library.resolve true
    apiLibrary.items {id: $routeParams.library}, (data) ->
      _.forEach(data.items, (item) ->
        item.thumbnails = ['/images/bars.png'] if _.isUndefined(item.thumbnails)
        $scope.thumbnail[item.name] = item.thumbnails[0])
      $scope.items = data.items
      items.resolve true

    # register promises into one queue
    elzoidoPromises.register('library', [library.promise, items.promise])
    # show wait dialog when the loading is taking long
    elzoidoPromises.wait('library', 'Loading library ...')

  $scope.edit = ->
    confirm = dialogs.create('partials/librariesInformationEdit.html', 'LibrariesInformationEditCtrl',
      {library: $scope.library},
      {size: 'lg', keyboard: false})
    # result
    confirm.result.then (wait) ->
      wait.result.then ->
        # fire event
        $rootScope.$broadcast 'event:narra-library-updated', $routeParams.library

  $scope.delete = ->
    # open confirmation dialog
    confirm = dialogs.confirm('Please Confirm',
      'You are about to delete the library ' + $scope.library.name + ', this procedure is irreversible. Do you want to continue ?')

    # result
    confirm.result.then ->
      # delete storage and its projects
      apiLibrary.delete {id: $scope.library.id}, ->
        # send message
        elzoidoMessages.send('success', 'Success!', 'Library ' + $scope.library.name + ' was successfully deleted.')
        # redirect back to libraries
        if _.isUndefined($scope.project)
          $location.url('/libraries')
        else
          $location.url('/projects/' + $scope.project + '#' + $scope.from)

  # click function for detail view
  $scope.detail = (item, index) ->
    $location.url('/items/' + item.id + '?library=' + $scope.library.id + '&from=items-' + index)

  $scope.startRotation = (item) ->
    # don't start new refresh when it is already on
    if angular.isDefined($scope.rotation[item.name]) then return
    # counter
    count = 0
    # rotate
    $scope.rotation[item.name] = $interval(->
      # revalidate count
      if count + 1 == item.thumbnails.length then count = 0 else count++
      # rotate
      $scope.thumbnail[item.name] = item.thumbnails[count]
    , 600)

  $scope.stopRotation = (item) ->
    # don't start new refresh when it is already on
    if angular.isDefined($scope.rotation[item.name])
      $interval.cancel($scope.rotation[item.name])
      $scope.rotation[item.name] = undefined
      $scope.thumbnail[item.name] = item.thumbnails[0]

  # refresh when new library is added
  $scope.$on 'event:narra-item-created', (event) ->
    if !_.isUndefined($routeParams.library)
      $scope.refresh()

  # refresh when new library is added
  $scope.$on 'event:narra-item-updated', (event, item) ->
    if !_.isUndefined($routeParams.library) && _.find($scope.items, {id: item})
      $scope.refresh()

  # refresh when new library is added
  $scope.$on 'event:narra-library-updated', (event, library) ->
    if !_.isUndefined($routeParams.library) && _.isEqual($routeParams.library, library)
      $scope.refresh()

  $scope.$on 'event:narra-render-finished', ->
    if !_.isEmpty($location.hash())
      $document.duScrollToElement(document.getElementById($location.hash()))

  # initial data
  $scope.refresh()