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

angular.module('narra.ui').controller 'MetadataLocationCtrl', ($scope, $timeout, $modalInstance, dialogs, elzoidoAuthUser, uiGmapGoogleMapApi, data) ->
  $scope.user = elzoidoAuthUser.get()

  uiGmapGoogleMapApi.then ->
    $scope.mapOptions = {
      center: new google.maps.LatLng(49.873, 15.552),
      zoom: 7,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }

    # by deafult map is disabled
    $scope.ready = false

    # workaround to refresh map everytime
    $timeout(->
      $scope.ready = true
    , 100)

    $scope.mapTilesLoaded = (map) ->
      if _.isUndefined($scope.marker)
        $scope.marker = new google.maps.Marker({map: map})
        # default values
        if $scope.meta.value != ''
          $scope.marker.setPosition(map.center)

    # init data
    if _.isUndefined(data.meta)
      $scope.meta = {name: 'location', value: ''}
    else
      $scope.meta = data.meta
      coordinates = $scope.meta.value.split(',')
      $scope.mapOptions.center = new google.maps.LatLng(coordinates[0], coordinates[1])
      $scope.mapOptions.zoom = 15

    $scope.setMarkerPosition = ($event, $params) ->
      $scope.marker.setPosition(new google.maps.LatLng($params[0].latLng.G, $params[0].latLng.K))
      $scope.meta.value = $params[0].latLng.G + ", " + $params[0].latLng.K

    $scope.close = ->
      # cancel dialog
      $modalInstance.dismiss('canceled')

    $scope.add = ->
      # add meta
      $modalInstance.close($scope.meta)

    $scope.edit = ->
      # update meta
      $modalInstance.close({action: 'update', meta: $scope.meta})

    $scope.delete = ->
      # delete meta
      $modalInstance.close({action: 'delete', meta: $scope.meta})