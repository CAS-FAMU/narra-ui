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

angular.module('narra.ui').controller 'ItemsAddCtrl', ($scope, $rootScope, $q, $timeout, $filter, $modalInstance, dialogs, apiItem, apiLibrary, apiUser, elzoidoMessages, elzoidoAuthUser, elzoidoPromises, serviceThumbnail) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.item = {url: '', library: '', author: $scope.user}

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

  # next action
  $scope.next = ->
    if $scope.second
      $scope.third = true
      $scope.second = false
    else
      # author is provided
      $scope.author = true
      # setup collections
      $scope.items = []
      # open waiting
      waiting = dialogs.wait('Please Wait', 'Checking new items ...')
      # promises
      promises = []
      # parse items
      items = $scope.item.url.split("\n")
      # iterate over
      _.forEach(items, (item) ->
        # get deffered
        wait = $q.defer()
        # register promise
        promises.push(wait.promise)
        # add item
        $timeout(->
          apiItem.check({ url: item }, (data) ->
            # thumbnail check
            _.forEach(data.items, (x) ->
              x.thumbnail = serviceThumbnail.thumbnail(x.type) if _.isNull(x.thumbnail)
              # push into collection
              $scope.items.push(x)
              # author is provided
              $scope.author = $scope.author && x.author
            )
            # resolve
            wait.resolve true
          , (error) ->
            wait.resolve true
          )
        , 100)
      )

      # register promises into one queue
      elzoidoPromises.register('check-items', promises)
      # close dialog
      elzoidoPromises.promise('check-items').then ->
        # close
        waiting.close()
        # and setup for the next slide
        $scope.second = true if !_.isEmpty($scope.items)

  # back action
  $scope.back = ->
    # move back according to level
    if $scope.third
      $scope.third = false
      $scope.second = true
    else if $scope.second
      # setup collections
      $scope.items = []
      # back to the first slide
      $scope.second = false

  # save action
  $scope.new = ->
    # open waiting
    waiting = dialogs.wait('Please Wait', 'Registering new items ...')
    # close dialog
    $modalInstance.close(waiting)
    # promises
    container = []
    # iterate over
    _.forEach($scope.items, (item) ->
      # prepare item
      container.push({
        url: item.url
        author: $scope.item.author.name
        library: $scope.item.library.id
        connector: item.connector
        options: item[item.connector]
      })
    )
    # add items
    apiItem.new { items: container}, (data) ->
      # fire message
      elzoidoMessages.send('success', 'Success!', 'Items were successfully created.')
      # close dialog
      waiting.close()