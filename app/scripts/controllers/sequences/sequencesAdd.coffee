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

angular.module('narra.ui').controller 'SequencesAddCtrl', ($scope, $modalInstance, $timeout, dialogs, apiProject, apiUser, elzoidoMessages, elzoidoAuthUser) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.sequence = { type: 'edl', title: '', project: '', author: $scope.user, file: '', fps: '25' }

  apiProject.all (data) ->
    $scope.projects = data.projects
  apiUser.all (data) ->
    $scope.users = data.users

  $scope.setFile = (element) ->
    $scope.$apply () ->
      $scope.sequence.file = element.files[0]
      $scope.sequence.title = element.files[0].name.split('.')[0]

  $scope.close = ->
    $modalInstance.dismiss('canceled')

  # save action
  $scope.new = ->
    # create form data object
    data = new FormData()

    # set up
    data.append('type', $scope.sequence.type)
    data.append('title', $scope.sequence.title)
    data.append('author', $scope.sequence.author.username)
    data.append('file', $scope.sequence.file)

    # open waiting
    wait = dialogs.wait('Please Wait', 'Registering new sequence ...')

    # close dialog
    $modalInstance.close(wait)

    apiProject.sequencesNew({ name: $scope.sequence.project.name, params: { edl_fps: $scope.sequence.fps }}, data, (data) ->
      # workaround to get sequence processed
      $timeout( ->
        # close wait dialog
        wait.close($scope.sequence.title)
        # fire message
        elzoidoMessages.send('success', 'Success!', 'Sequence ' + $scope.sequence.title + ' was successfully created.')
      , 1000)
    )