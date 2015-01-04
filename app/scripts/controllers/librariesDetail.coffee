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

angular.module('narra.ui').controller 'LibrariesDetailCtrl', ($scope, $rootScope, $routeParams, $location, $filter, $q, dialogs, apiProject, apiLibrary, apiUser, elzoidoPromises, elzoidoAuthUser, elzoidoMessages) ->
  # set up context
  $scope.project = $routeParams.project

  # refresh data
  $scope.refresh = ->
    # get current user
    $scope.user = elzoidoAuthUser.get()
    # get deffered
    library = $q.defer()
    items = $q.defer()

    apiLibrary.get {id: $routeParams.id}, (data) ->
      $scope.library = data.library
      library.resolve true
    apiLibrary.items {id: $routeParams.id}, (data) ->
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
      wait.result.then (library)->
        # fire event
        $rootScope.$broadcast 'event:narra-library-updated', library

  # refresh when new library is added
  $rootScope.$on 'event:narra-item-created', (event, status) ->
    $scope.refresh()

  # refresh when new library is added
  $rootScope.$on 'event:narra-library-updated', (event, library) ->
    $scope.refresh()

  # initial data
  $scope.refresh()