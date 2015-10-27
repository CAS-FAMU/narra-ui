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

angular.module('narra.ui').controller 'SequencesDetailCtrl', ($scope, $sce, $timeout, $rootScope, $routeParams, $location, $document, $interval, $filter, $q, dialogs, apiProject, apiUser, elzoidoPromises, elzoidoAuthUser, elzoidoMessages) ->
  # initializations
  $scope.tabs = { sequence: { active: true }, player: { }, editor: { } }
  # player
  $scope.player =
    api: undefined
    ready: false
    preload: true
    autoHide: true
    autoHideTime: 2000
    autoPlay: false
    sources: []
    playlist: []
    current: 0
    tracks: []
    cuePoints: {}
    plugins: {}

  # refresh data
  elzoidoPromises.promise('authentication').then ->
    $scope.refresh = ->
      # get current user
      $scope.user = elzoidoAuthUser.get()
      # get deffered
      sequence = $q.defer()
      items = $q.defer()

      apiProject.items {name: $routeParams.project}, (data) ->
        $scope.items = data.items
        items.resolve true

      items.promise.then ->
        apiProject.sequences {name: $routeParams.project, param: $routeParams.sequence}, (data) ->
          # get seauence
          $scope.sequence = data.sequence
          # set playlist
          _.forEach($scope.sequence.marks, (mark) ->
            # get item
            item = _.find($scope.items, {name: mark.clip.name})
            # get video source
            if _.isUndefined(item)
              if mark.clip.name == 'black'
                source = 'http://static.rur.cz/narra/black/black.mp4'
              else
                source = 'http://static.rur.cz/narra/bars/bars.mp4'
              source_in = 0
              source_out = mark.duration
            else
              source = item.video_proxy_hq
              source_in = mark.in
              source_out = mark.out
            # create playlist entry
            $scope.player.playlist.push({in: source_in, out: source_out, src: {src: $sce.trustAsResourceUrl(source), type: "video/mp4"}})
          )
          # set first video
          $scope.player.sources = [$scope.player.playlist[0].src]
          # resolve
          sequence.resolve true

      # register promises into one queue
      elzoidoPromises.register('sequence', [sequence.promise, items.promise])
      elzoidoPromises.promise('sequence').then ->
        # init player
        $scope.player.ready = true

    $scope.onPlayerReady = (api) ->
      # set player's api
      $scope.player.api = api
      # set first video seek time
      $timeout ->
        $scope.player.api.seekTime($scope.player.playlist[0].in)
      , 0

    $scope.playlistHandler = (currentTime) ->
      if currentTime >= $scope.player.playlist[$scope.player.current].out
        # set next video
        $scope.player.current += 1
        # refresh
        $scope.playerAction()

    $scope.seek = (index) ->
      # set current video
      $scope.player.current = index
      # refresh
      $scope.playerAction()

    $scope.playerAction = () ->
      if $scope.player.current != $scope.player.playlist.length
        $scope.player.sources = [$scope.player.playlist[$scope.player.current].src]
        $timeout ->
          $scope.player.api.seekTime($scope.player.playlist[$scope.player.current].in)
          $scope.player.api.play()
        , 0
      else
        $scope.player.api.stop()
        $scope.player.current = 0
        $scope.player.sources = [$scope.player.playlist[$scope.player.current].src]
        $timeout ->
          $scope.player.api.seekTime($scope.player.playlist[$scope.player.current].in)
        , 0

    $scope.isAuthor = ->
      !_.isUndefined($scope.sequence) && _.isEqual($scope.sequence.author.username, $scope.user.username) || $scope.user.isAdmin()

    $scope.isContributor = ->
      !_.isUndefined($scope.sequence) && _.include(_.pluck($scope.sequence.contributors, 'username'), $scope.user.username)

    $scope.isActive = (index) ->
      $scope.player.current == index

    $scope.edit = ->
      # check
      return if !$scope.isAuthor() && !$scope.isContributor()
      # process
      confirm = dialogs.create('partials/sequencesInformationEdit.html', 'SequencesInformationEditCtrl',
        {sequence: $scope.sequence},
        {size: 'lg', keyboard: false})
      # result
      confirm.result.then (wait) ->
        wait.result.then ->
          # refresh
          $scope.refresh()
          # fire event
          $rootScope.$broadcast 'event:narra-sequence-updated', $routeParams.sequence

    $scope.delete = ->
      # open confirmation dialog
      confirm = dialogs.confirm('Please Confirm',
        'You are about to delete the sequence ' + $scope.sequence.name + ', this procedure is irreversible. Do you want to continue ?')

      # result
      confirm.result.then ->
        # delete storage and its projects
        apiProject.sequencesDelete {name: $routeParams.project, param: $scope.sequence.id}, ->
          # send message
          elzoidoMessages.send('success', 'Success!', 'Sequence ' + $scope.sequence.name + ' was successfully deleted.')
          # redirect back to project
          $location.url('/projects/' + $routeParams.project)

    # initial data
    $scope.refresh()