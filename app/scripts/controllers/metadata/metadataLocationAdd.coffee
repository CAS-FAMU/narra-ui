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

angular.module('narra.ui').controller 'MetadataLocationCtrl', ($scope, $modalInstance, dialogs, elzoidoAuthUser, uiGmapGoogleMapApi) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.meta = {name: 'location', value: '' }
  $scope.render = true

  $scope.map =
    center:
      latitude: 50.0755381
      longitude: 14.43780049999998
    zoom: 3
    options:
      scrollwheel: true

  uiGmapGoogleMapApi.then (maps) ->
    maps.visualRefresh = true

  $scope.$watch 'meta.value', (value) ->
    if !_.isUndefined(value) && !_.isUndefined(value.geometry)
      $scope.map.center =
        latitude: value.geometry.location.lat()
        longitude: value.geometry.location.lng()
      $scope.map.zoom = 12

  $scope.close = ->
    # cancel dialog
    $modalInstance.dismiss('canceled')

  $scope.add = ->
    # process meta if it is a google object
    if !_.isUndefined($scope.meta.value.formatted_address)
      $scope.meta.value = $scope.meta.value.formatted_address
    # add meta
    $modalInstance.close($scope.meta)