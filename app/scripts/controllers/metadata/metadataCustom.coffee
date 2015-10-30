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

angular.module('narra.ui').controller 'MetadataCustomCtrl', ($scope, $modalInstance, dialogs, elzoidoMessages, elzoidoAuthUser, data) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.all = data.all || []
  # init data
  if _.isUndefined(data.meta)
    $scope.meta = {name: '', value: ''}
  else
    $scope.meta = data.meta
  # init marks
  if !_.isUndefined(data.mark)
    $scope.seek = data.seek
    $scope.mark = data.mark
    # watch mark changes to seek player
    $scope.$watch 'mark.in', (value) ->
      if !_.isUndefined(value)
        $scope.seek(value)
    $scope.$watch 'mark.out', (value) ->
      if !_.isUndefined(value)
        $scope.seek(value)

  $scope.validateName = (value) ->
    !_.contains($scope.all, value)

  $scope.close = ->
    # cancel dialog
    $modalInstance.dismiss('canceled')

  $scope.add = ->
    # append marks
    if !_.isUndefined($scope.mark) && $scope.mark.use
      $scope.meta = _.merge($scope.meta, marks: [{in: $scope.mark.in, out: $scope.mark.out}])
    # add meta
    $modalInstance.close($scope.meta)

  $scope.edit = ->
    # append marks
    if !_.isUndefined($scope.mark)
      if $scope.mark.use
        $scope.meta = _.merge($scope.meta, marks: [{in: $scope.mark.in, out: $scope.mark.out}])
      else
        $scope.meta.marks = []
    # update meta
    $modalInstance.close($scope.meta)