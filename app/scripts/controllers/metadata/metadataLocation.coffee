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

angular.module('narra.ui').controller 'MetadataLocationCtrl', ($scope, $modalInstance, dialogs, elzoidoAuthUser, data) ->
  $scope.user = elzoidoAuthUser.get()
  # init data
  if _.isUndefined(data.meta)
    $scope.meta = {name: 'location', value: ''}
  else
    $scope.meta = data.meta

  $scope.close = ->
    # cancel dialog
    $modalInstance.dismiss('canceled')

  $scope.add = ->
    console.log($scope.meta.value)
    # process meta if it is a google object
    if !_.isUndefined($scope.meta.value.formatted_address)
      $scope.meta.value = $scope.meta.value.formatted_address
    # add meta
    $modalInstance.close($scope.meta)

  $scope.edit = ->
    # process meta if it is a google object
    if !_.isUndefined($scope.meta.value.formatted_address)
      $scope.meta.value = $scope.meta.value.formatted_address
    # update meta
    $modalInstance.close({action: 'update', meta: $scope.meta})

  $scope.delete = ->
    # delete meta
    $modalInstance.close({action: 'delete', meta: $scope.meta})