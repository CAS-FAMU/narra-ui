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

angular.module('narra.ui').controller 'SequencesInformationEditCtrl', ($scope, $filter, $modalInstance, $timeout, dialogs, apiProject, apiUser, apiGenerator, elzoidoMessages, elzoidoAuthUser, FileUploader, data) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.sequence = data.sequence
  $scope.project = data.sequence.project
  $scope.initial = angular.copy(data.sequence)
  $scope.contributor = {}

  apiProject.sequences {name: $scope.project.name}, (data) ->
    $scope.sequences = data.sequences
  apiUser.all (data) ->
    $scope.users = data.users
    $scope.filter()

  $scope.addContribution = (user) ->
    $scope.sequence.contributors.push(user)
    $scope.contributor.selected = undefined
    # refresh
    $scope.filter()

  $scope.removeContribution = (user) ->
    _.pull($scope.sequence.contributors, user)
    # refresh
    $scope.filter()

  $scope.filter = ->
    $scope.contributors = _.filter($scope.users, (user) ->
      !_.isEqual($scope.sequence.author.username, user.username) && !_.include(_.pluck($scope.sequence.contributors,
        'username'), user.username)
    )

  $scope.isAuthor = ->
    !_.isUndefined($scope.sequence) && _.isEqual($scope.sequence.author.username, $scope.user.username) || $scope.user.isAdmin()

  $scope.close = ->
    $modalInstance.dismiss('canceled')

  # save action
  $scope.edit = ->
    # open waiting
    wait = dialogs.wait('Please Wait', 'Saving sequence ...')

    # close dialog
    $modalInstance.close(wait)

    apiProject.sequencesUpdate({
        name: $scope.project.name
        sequence: $scope.sequence.id
        title: $scope.sequence.name
        public: $scope.sequence.public.toString()
        author: $scope.sequence.author.username
        description: $scope.sequence.description
        contributors: _.pluck($scope.sequence.contributors, 'username')
      }, (data) ->
        # close wait dialog
        wait.close(data.library)
        # fire message
        elzoidoMessages.send('success', 'Success!', 'Sequence ' + data.sequence.name + ' was successfully saved.')
    )

  $scope.validateName = (value) ->
    !(_.contains(_.pluck($scope.visualizations, 'name'),  value))