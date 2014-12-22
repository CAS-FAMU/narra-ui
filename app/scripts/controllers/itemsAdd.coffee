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

angular.module('narra.ui').controller 'ItemsAddCtrl', ($scope, $filter, $modalInstance, dialogs, apiItem, apiLibrary, apiUser, elzoidoMessages, elzoidoAuthUser) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.item = { url: '', library: '', author: $scope.user }

  apiLibrary.all (data) ->
    temporary = angular.copy(data.libraries)
    if !$scope.user.isAdmin()
      _.remove(temporary, (library) ->
        !_.contains(_.pluck(library.contributors, 'username').concat([library.author.username]), $scope.user.username))
    $scope.libraries = temporary
  apiUser.all (data) ->
    $scope.users = data.users

  $scope.close = ->
    $modalInstance.dismiss('canceled')

  # save action
  $scope.new = ->
    # open waiting
    wait = dialogs.wait('Please Wait', 'Registering new library ...')

    # close dialog
    $modalInstance.close(wait)

    apiItem.new({
      url: $scope.item.url
      author: $scope.item.author.username
      library: $scope.item.library.id
    }, (data) ->
      # close wait dialog
      wait.close()
      # fire message
      elzoidoMessages.send('success', 'Success!', 'Item ' + data.item.name + ' was successfully created.')
    )