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

angular.module('narra.ui').controller 'SequencesAddCtrl', ($scope, $modalInstance, $timeout, dialogs, apiProject, apiUser, elzoidoMessages, elzoidoAuthUser, FileUploader) ->
# initialize
  $scope.user = elzoidoAuthUser.get()
  $scope.sequence = {name: '', project: '', author: $scope.user, description: '', file: undefined, fps: ''}
  $scope.framerates = [24, 25, 29.97, 30]
  $scope.uploader = new FileUploader()

  $scope.uploader.onAfterAddingFile = (file) ->
    type = file._file.name.split('.')[1]

    # check type
    if _.isEqual(type, 'edl')
      $scope.sequence.type = 'edl'
    else if _.isEqual(type, 'xml')
      $scope.sequence.type = 'xml'

    # save file
    $scope.sequence.file = file._file
    $scope.sequence.name = file._file.name.split('.')[0]
    $scope.second = true

  apiProject.all (data) ->
    $scope.projects = data.projects
  apiUser.all (data) ->
    $scope.users = data.users

  $scope.select = (type) ->
    $scope.sequence.type = type
    $scope.second = true

  $scope.close = ->
    $modalInstance.dismiss('canceled')

  # back action
  $scope.back = ->
# back to the first slide
    $scope.second = false

  # save action
  $scope.new = ->
# create form data object
    data = new FormData()

    # set up
    data.append('title', $scope.sequence.name)
    data.append('type', $scope.sequence.type)
    data.append('fps', $scope.sequence.fps)
    data.append('author', $scope.sequence.author.username)
    data.append('description', $scope.sequence.description)

    # push file only if imported
    if !_.isUndefined($scope.sequence.file)
      data.append('file', $scope.sequence.file)

    # open waiting
    wait = dialogs.wait('Please Wait', 'Registering new sequence ...')

    # close dialog
    $modalInstance.close(wait)

    apiProject.sequencesNew({name: $scope.sequence.project.name}, data, (data) ->
      # workaround to get sequence processed
      $timeout(->
        # close wait dialog
        wait.close()
        # fire message
        elzoidoMessages.send('success', 'Success!', 'Sequence ' + $scope.sequence.name + ' was successfully created.')
      , 1000)
    )