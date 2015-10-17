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

angular.module('narra.ui').controller 'VisualizationsAddCtrl', ($scope, $modalInstance, $timeout, dialogs, apiVisualization, apiUser, elzoidoMessages, elzoidoAuthUser, FileUploader) ->
  # initialize
  $scope.user = elzoidoAuthUser.get()
  $scope.visualization = { name: '', author: $scope.user, description: '', file: undefined}
  $scope.uploader = new FileUploader()

  $scope.uploader.onAfterAddingFile = (file) ->
    type = file._file.name.split('.')[1]

    # check type
    if _.isEqual(type, 'pde')
      $scope.visualization.type = 'processing'
    else if _.isEqual(type, 'js')
      $scope.visualization.type = 'p5js'

    # save file
    $scope.visualization.file = file._file
    $scope.visualization.name = file._file.name.split('.')[0]
    $scope.second = true

  apiUser.all (data) ->
    $scope.users = data.users
  apiVisualization.all (data) ->
    $scope.visualizations = data.visualizations

  $scope.select = (type) ->
    $scope.visualization.type = type
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
    data.append('name', $scope.visualization.name)
    data.append('type', $scope.visualization.type)
    data.append('author', $scope.visualization.author.username)
    data.append('description', $scope.visualization.description)

    # push file only if imported
    if !_.isUndefined($scope.visualization.file)
      data.append('file', $scope.visualization.file)

    # open waiting
    wait = dialogs.wait('Please Wait', 'Registering new visualization ...')

    # close dialog
    $modalInstance.close(wait)

    apiVisualization.new({}, data, (data) ->
      # workaround to get sequence processed
      $timeout( ->
        # close wait dialog
        wait.close($scope.visualization.name)
        # fire message
        elzoidoMessages.send('success', 'Success!', 'Visualization ' + $scope.visualization.name + ' was successfully created.')
      , 1000)
    )

  $scope.validateName = (value) ->
    !(_.contains(_.pluck($scope.visualizations, 'name'),  value))