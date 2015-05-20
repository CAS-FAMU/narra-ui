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

angular.module('narra.ui').controller 'SequencesDetailCtrl', ($scope, $rootScope, $routeParams, $location, $document, $interval, $filter, $q, dialogs, apiProject, apiUser, elzoidoPromises, elzoidoAuthUser, elzoidoMessages) ->
  # set up context
  $scope.project = $routeParams.project
  $scope.sequence = $routeParams.sequence

  # refresh data
  $scope.refresh = ->
    # get current user
    $scope.user = elzoidoAuthUser.get()
    # get deffered
    sequence = $q.defer()

    apiProject.sequences {name: $scope.project, param: $routeParams.sequence}, (data) ->
      $scope.sequence = data.sequence
      sequence.resolve true

    # register promises into one queue
    elzoidoPromises.register('sequence', [sequence.promise])
    # show wait dialog when the loading is taking long
    elzoidoPromises.wait('sequence', 'Loading sequence ...')

  $scope.delete = ->
    # open confirmation dialog
    confirm = dialogs.confirm('Please Confirm',
      'You are about to delete the sequence ' + $scope.sequence.name + ', this procedure is irreversible. Do you want to continue ?')

    # result
    confirm.result.then ->
      # delete storage and its projects
      apiProject.sequencesDelete {name: $scope.project, param: $scope.sequence.id}, ->
        # send message
        elzoidoMessages.send('success', 'Success!', 'Sequence ' + $scope.sequence.name + ' was successfully deleted.')
        # redirect back to project
        $location.url('/projects/' + $scope.project)

  # initial data
  $scope.refresh()