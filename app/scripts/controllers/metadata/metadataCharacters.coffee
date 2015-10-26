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

angular.module('narra.ui').controller 'MetadataCharactersCtrl', ($scope, $modalInstance, dialogs, elzoidoMessages, elzoidoAuthUser, data) ->
  $scope.user = elzoidoAuthUser.get()
  # init data
  if _.isUndefined(data.meta)
    $scope.meta = {name: 'characters', value: ''}
  else
    $scope.meta = data.meta
    $scope.meta.value = _.map(data.meta.value.split(','), (type) ->
      type.trim()
    )
  
  if _.isUndefined(data.values)
    $scope.characters = []
  else
    $scope.characters = data.values

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