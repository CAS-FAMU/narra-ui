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

angular.module('narra.ui').controller 'VisualizationsInformationEditCtrl', ($scope, $filter, $modalInstance, $timeout, dialogs, apiVisualization, apiUser, apiGenerator, elzoidoMessages, elzoidoAuthUser, FileUploader, data) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.visualization = data.visualization
  $scope.initial = angular.copy(data.visualization)
  $scope.uploader = new FileUploader()

  apiVisualization.all (data) ->
    $scope.visualizations = data.visualizations
  apiUser.all (data) ->
    $scope.users = data.users
    $scope.filter()

  $scope.uploader.onAfterAddingFile = (file) ->
    type = file._file.name.split('.')[1]
    # check type
    if _.isEqual(type, 'pde')
      # save file
      console.log($scope.visualization.file)
      $scope.visualization.file = file._file
      console.log($scope.visualization.file)

  $scope.filter = ->
    $scope.contributors = _.filter($scope.users, (user) ->
      !_.isEqual($scope.visualization.author.username, user.username)
    )

  $scope.close = ->
    $modalInstance.dismiss('canceled')

  # save action
  $scope.edit = ->
# create form data object
    data = new FormData()

    # set up
    data.append('name', $scope.visualization.name)
    data.append('author', $scope.visualization.author.username)
    data.append('description', $scope.visualization.description)
    data.append('public', $scope.visualization.public)
    data.append('file', $scope.visualization.file) if $scope.visualization.file

    # open waiting
    wait = dialogs.wait('Please Wait', 'Saving visualization ...')

    # close dialog
    $modalInstance.close(wait)

    apiVisualization.update({id: $scope.visualization.id}, data, (data) ->
      # workaround to get sequence processed
      $timeout( ->
        # close wait dialog
        wait.close($scope.visualization.name)
        # fire message
        elzoidoMessages.send('success', 'Success!', 'Visualization ' + $scope.visualization.name + ' was successfully updated.')
      , 1000)
    )

  $scope.validateName = (value) ->
    !(_.contains(_.pluck($scope.visualizations, 'name'),  value))