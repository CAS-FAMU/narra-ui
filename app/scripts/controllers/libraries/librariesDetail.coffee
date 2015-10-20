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

angular.module('narra.ui').controller 'LibrariesDetailCtrl', ($timeout, $scope, $rootScope, $routeParams, $location, $document, $interval, $filter, $q, dialogs, apiProject, apiLibrary, apiUser, apiItem, elzoidoPromises, constantMetadata, elzoidoAuthUser, elzoidoMessages) ->
  # initialization
  $scope.rotation = {}
  $scope.thumbnail = {}
  # init metadata providers
  $scope.libraryMetadata = {}
  $scope.itemsMetadata = {}
  $scope.tabs = { library: { active: true }, items: { }, metadata: { } }

  if !_.isUndefined($routeParams.tab)
    $scope.tabs[$routeParams.tab].active = true

  # refresh data
  $scope.refresh = ->
    # get current user
    $scope.user = elzoidoAuthUser.get()
    # get deffered
    library = $q.defer()
    items = $q.defer()

    apiLibrary.get {id: $routeParams.library}, (data) ->
      data.library.metadata = _.filter(data.library.metadata, (meta) ->
        !_.isEqual(meta.name, 'shared')
      )
      $scope.library = data.library
      library.resolve true
    apiLibrary.items {id: $routeParams.library}, (data) ->
      _.forEach(data.items, (item) ->
        $scope.thumbnail[item.name] = item.thumbnails[0])
      $scope.items = data.items
      # resolve metadata providers
      $scope.metadataProviders = constantMetadata.providers
      items.resolve true

    # set up context
    library.promise.then ->
      if !_.isUndefined($routeParams.project)
        $scope.project = _.find($scope.library.projects, { name: $routeParams.project })

    # register promises into one queue
    elzoidoPromises.register('library', [library.promise, items.promise])

  $scope.isSelected = ->
    !_.isEmpty($scope.selectedItems())

  $scope.selectedItems = ->
    _.where($scope.items, { selected: true })

  $scope.select = (selected) ->
    _.forEach($scope.items, (item) ->
      item.selected = if selected then true else undefined
    )

  $scope.isAuthor = ->
    !_.isUndefined($scope.library) && _.isEqual($scope.library.author.username, $scope.user.username) || $scope.user.isAdmin()

  $scope.isContributor = ->
    !_.isUndefined($scope.library) && _.include(_.pluck($scope.library.contributors, 'username'), $scope.user.username)

  $scope.edit = ->
    # check
    return if !$scope.isAuthor() && !$scope.isContributor()
    # process
    confirm = dialogs.create('partials/librariesInformationEdit.html', 'LibrariesInformationEditCtrl',
      {library: $scope.library},
      {size: 'lg', keyboard: false})
    # result
    confirm.result.then (wait) ->
      wait.result.then ->
        # fire event
        $rootScope.$broadcast 'event:narra-library-updated', $routeParams.library

  $scope.deleteItems = ->
    # open confirmation dialog
    confirm = dialogs.confirm('Please Confirm',
      'You are about to delete selected items, this procedure is irreversible. Do you want to continue ?')

    # prepare items
    itemsDelete = $scope.selectedItems()

    # result
    confirm.result.then ->
      # open waiting
      waiting = dialogs.wait('Please Wait', 'Deleting selected items ...')
      # promises
      promises = []
      # delete items
      _.forEach(itemsDelete, (item) ->
        # get deffered
        wait = $q.defer()
        # register promise
        promises.push(wait.promise)
        # delete items
        $timeout(->
          apiItem.delete({id: item.id}, (data) ->
            wait.resolve true
          , (error) ->
            wait.resolve true
            # fire message
            elzoidoMessages.send('danger', 'Error!', 'Item ' + item.name + ' encountered problem.')
          )
        , 100)
      )
      # register promises into one queue
      elzoidoPromises.register('delete-items', promises)
      # close dialog
      elzoidoPromises.promise('delete-items').then ->
        # refresh scope
        $scope.refresh()
        # fire message
        elzoidoMessages.send('success', 'Success!', 'Items were successfully deleted.')
        # close dialog
        waiting.close()

  $scope.deleteLibrary = ->
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
  $scope.detail = (item) ->
    # define basic url
    url = '/items/' + item.id + '?library=' + $scope.library.id
    # when comes from project
    if !_.isUndefined($scope.project)
      url = url + '&project=' + $scope.project.name
    # change location
    $location.url(url)

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