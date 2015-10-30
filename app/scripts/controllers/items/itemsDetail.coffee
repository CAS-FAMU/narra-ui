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

angular.module('narra.ui').controller 'ItemsDetailCtrl', ($scope, $rootScope, $routeParams, $location, $sce, $document, $interval, $timeout, $filter, $q, dialogs, apiProject, apiLibrary, apiItem, apiUser, uiGmapGoogleMapApi, constantMetadata, elzoidoPromises, elzoidoMessages, elzoidoAuthUser) ->
  # set up context
  $scope.itemMetadata = {}
  # get current user
  $scope.tabs = { player: { }, text: { }, metadata: { active: true } }
  # player
  $scope.player =
    api: undefined
    ready: false
    preload: true
    autoHide: true
    autoHideTime: 2000
    autoPlay: false
    sources: []
    tracks: []
    cuePoints: {}
    plugins: {}

  $scope.editorOption =
    theme: 'chrome',
    require: ['ace/ext/language_tools', 'ace/ext/static_highlight', 'ace/ext/error_marker', 'ace/ext/searchbox'],
    useWrapMode: true,
    showGutter: false,
    showPrintMargin: false,
    advanced: {},
    onLoad: (editor) ->
  # read only
      editor.setReadOnly(true)
      # get session
      session = editor.getSession()
      # resolve mode
      session.setMode('ace/mode/text')
      editor.setAutoScrollEditorIntoView(true)
      editor.setOption("maxLines", 120)
      editor.setFontSize('14px')

  elzoidoPromises.promise('authentication').then ->
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
        $scope.library = data.library
        # get project informations
        if !_.isUndefined($routeParams.project)
          $scope.project = _.find($scope.library.projects, { name: $routeParams.project })
        library.resolve true

      # get item
      apiItem.get {id: $routeParams.item}, (data) ->
        switch(data.item.type)
          when 'video'
            # set video
            $scope.player.sources = [{src: $sce.trustAsResourceUrl(data.item.video_proxy_hq), type: "video/webm"}]
            # get duration
            $scope.duration = _.where(data.item.metadata, {name: 'duration'})[0].value
            # get cuepoints
            $scope.cuepoints = _.reduce(data.item.metadata, (result, meta) ->
              if !_.isUndefined(meta.marks) && meta.marks.length > 0 && !_.isEqual(meta.generator,
                'thumbnail') && !_.isEqual(meta.generator, 'transcoder')
                cuepoint = {
                  timeLapse: {
                    start: meta.marks[0].in
                  }
                  onUpdate: () ->
                    $scope.active = true
                    $scope.live = meta
                  onComplete: () ->
                    $scope.active = false
                    $timeout ->
                      if !$scope.active
                        $scope.live = undefined
                    , 2000
                }
                if !_.isUndefined(meta.marks[0].out)
                  cuepoint.timeLapse.end = meta.marks[0].out
                else
                  cuepoint.timeLapse.end = meta.marks[0].in + 0.3
                result.push(cuepoint)
              return result
            , [])
            # set up cuepoint
            $scope.player.cuePoints = {
              metadata: $scope.cuepoints
            }
            $scope.player.ready = true
          when 'text'
            $scope.text = _.where(data.item.metadata, {name: 'text'})[0].value
            data.item.metadata = _.filter(data.item.metadata, (meta) ->
              !_.isEqual(meta.name, 'text')
            )
        # assign
        $scope.item = data.item
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

    $scope.refreshMetadata = ->
      apiItem.get {id: $routeParams.item}, (data) ->
        $scope.item = data.item
        # item's used generators
        names = _.uniq(_.pluck($scope.item.metadata, 'name'))
        # resolve metadata providers
        $scope.metadataProviders = _.filter(constantMetadata.providers, (provider) ->
          !_.include(names, provider.id) || _.isEqual(provider.id, 'custom')
        )

    $scope.isAuthor = ->
      !_.isUndefined($scope.library) && _.isEqual($scope.library.author.username, $scope.user.username) || $scope.user.isAdmin()

    $scope.isContributor = ->
      !_.isUndefined($scope.library) && _.include(_.pluck($scope.library.contributors, 'username'), $scope.user.username)

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
      $scope.player.api = api

    $scope.seek = (position) ->
      $scope.api.seekTime(position)

    $scope.$on 'event:narra-item-updated', (event, item) ->
      if _.isEqual($routeParams.item, item)
        $scope.refreshMetadata()

    $scope.refresh()