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

angular.module('narra.ui').controller 'ItemsDetailCtrl', ($scope, $rootScope, $routeParams, $location, $sce, $document, $interval, $filter, $q, dialogs, apiProject, apiLibrary, apiItem, apiUser, uiGmapGoogleMapApi, constantMetadata, elzoidoPromises, elzoidoMessages, elzoidoAuthUser) ->
  # set up context
  $scope.library = $routeParams.library
  $scope.project = $routeParams.project
  $scope.from = $routeParams.from
  $scope.fromPrevious = $routeParams.fromPrevious
  # player
  $scope.player =
    preload: true
    autoHide: false
    autoHideTime: 2000
    autoPlay: false
    sources: []
    tracks: []
    plugins: {}

  # refresh data
  $scope.refresh = ->
    # get current user
    $scope.user = elzoidoAuthUser.get()
    # get deffered
    item = $q.defer()
    library = $q.defer()

    # get library
    apiLibrary.get {id: $routeParams.library}, (data) ->
      $scope.generators = data.library.generators
      library.resolve true

    # get item
    apiItem.get {id: $routeParams.item}, (data) ->
      # set video
      $scope.player.sources = [{src: $sce.trustAsResourceUrl(data.item.video_proxy_hq), type: "video/webm"}]
      # get duration
      $scope.duration = _.where(data.item.metadata, {name: 'duration'})[0].value
      # assign
      $scope.item = data.item
      # get cuepoints
      $scope.cuepoints = _.reduce(data.item.metadata, (result, meta) ->
        if !_.isUndefined(meta.marks) && meta.marks.length > 0 && !_.isEqual(meta.generator,
          'thumbnail') && !_.isEqual(meta.generator, 'transcoder') && !_.isEqual(meta.generator, 'att_speech')
          cuepoint = {in: meta.marks[0].in, position: meta.marks[0].in * (100 / $scope.duration), name: meta.name}
          if !_.isUndefined(meta.marks[0].out)
            cuepoint = _.merge(cuepoint, {out: meta.marks[0].out})
          result.push(cuepoint)
        return result
      , [])
      # item's used generators
      generators = _.uniq(_.pluck($scope.item.metadata, 'generator'))
      # resolve metadata providers
      $scope.metadataProviders = _.filter(constantMetadata.providers, (provider) ->
        !_.include(generators, provider.id) || _.isEqual(provider.id, 'user_custom')
      )
      # resolve
      item.resolve true

    # register promises into one queue
    elzoidoPromises.register('item', [item.promise, library.promise])
    # show wait dialog when the loading is taking long
    elzoidoPromises.wait('item', 'Loading item ...')

  $scope.delete = ->
    # open confirmation dialog
    confirm = dialogs.confirm('Please Confirm',
      'You are about to delete the item ' + $scope.item.name + ', this procedure is irreversible. Do you want to continue ?')

    # result
    confirm.result.then ->
      # delete storage and its projects
      apiItem.delete {id: $scope.item.id}, ->
        # redirect back to library
        $location.url('/libraries/' + $scope.library + '#' + $scope.from)
        # send message
        elzoidoMessages.send('success', 'Success!', 'Item ' + $scope.item.name + ' was successfully deleted.')

  $scope.onPlayerReady = (api) ->
    $scope.api = api

  $scope.seek = (position) ->
    $scope.api.seekTime(position)

  $scope.isLink = (text) ->
    text.indexOf('http') == 0

  $scope.$on 'event:narra-item-updated', (event, item) ->
    if _.isEqual($routeParams.item, item)
      $scope.refresh()

  # initial data
  $scope.refresh()