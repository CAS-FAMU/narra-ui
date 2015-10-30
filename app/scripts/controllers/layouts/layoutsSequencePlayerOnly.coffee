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

angular.module('narra.ui').controller 'LayoutsSequencePlayerOnlyCtrl', ($scope, $sce, $timeout, $routeParams, $window, $rootScope, $q, apiProject, apiVisualization, elzoidoPromises) ->
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
    tracks: []
    cuePoints: {}
    plugins: {}

  $scope.refresh = ->
    # get deffered
    sequence = $q.defer()
    # get sequences
    apiProject.sequences {name: $scope.project.name, param: $scope.layout.options['sequence']}, (data) ->
      # get seauence
      $scope.sequence = data.sequence
      # temporary
      master_in = 0
      # process marks
      _.forEach($scope.sequence.marks, (mark) ->
        # get video source
        if _.isUndefined(mark.clip.source)
          if mark.clip.name == 'black'
            mark.clip.source = 'http://static.rur.cz/narra/black/black.mp4'
          else
            mark.clip.source = 'http://static.rur.cz/narra/bars/bars.mp4'
          mark.in = 0
          mark.out = mark.duration
        # set sequence in
        mark.master_in = master_in
        # iterate for the next
        master_in += mark.duration
      )
      # set playlist
      if _.isUndefined($scope.sequence.master)
        _.forEach($scope.sequence.marks, (mark) ->
          $scope.player.playlist.push({
            in: mark.in,
            out: mark.out,
            src: {src: $sce.trustAsResourceUrl(mark.clip.source), type: "video/mp4"}
          })
        )
      else
        $scope.player.playlist.push({
          in: 0,
          src: {src: $sce.trustAsResourceUrl($scope.sequence.master.source), type: "video/mp4"}
        })
      # set first video
      $scope.player.current = 0
      $scope.player.sources = [$scope.player.playlist[0].src]
      # resolve
      sequence.resolve true

    # register promises into one queue
    elzoidoPromises.register('sequence', [sequence.promise])
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
    if _.isUndefined($scope.sequence.master)
      if currentTime >= $scope.player.playlist[$scope.player.current].out
        # set next video
        $scope.player.current += 1
        # refresh
        $scope.playerAction()
    else
      _.forEach($scope.sequence.marks, (mark, index) ->
        if currentTime > mark.master_in && ($scope.sequence.marks.length == index+1 || currentTime < $scope.sequence.marks[index+1].master_in)
          $scope.player.current = index
      )

  $scope.isActive = (index) ->
    $scope.player.current == index

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

  $scope.refresh()