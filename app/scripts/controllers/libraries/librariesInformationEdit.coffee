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

angular.module('narra.ui').controller 'LibrariesInformationEditCtrl', ($scope, $filter, $modalInstance, dialogs, apiProject, apiLibrary, apiUser, apiGenerator, elzoidoMessages, elzoidoAuthUser, data) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.library = data.library
  $scope.initial = angular.copy(data.library)
  $scope.contributor = {}

  apiLibrary.all (data) ->
    $scope.libraries = data.libraries
  apiProject.all (data) ->
    $scope.projects = data.projects
  apiUser.all (data) ->
    $scope.users = data.users
    $scope.filter()
  apiGenerator.all (data) ->
    # select first generator and activate
    if !_.isEmpty($scope.library.generators)
      # activate
      _.forEach(data.generators, (generator) ->
        temp = _.find($scope.library.generators, {identifier: generator.identifier})
        if !_.isUndefined(temp)
          generator.options = temp.options
          generator.active = true
          if _.isUndefined($scope.generator)
            $scope.generator = generator
      )
    # prepare data for session
    $scope.generators = data.generators

  $scope.select = (generator) ->
    if generator.active
      $scope.generator = generator

  $scope.activate = (generator) ->
    if generator.active
      $scope.generator = generator
    else
      $scope.generator = null

  $scope.addContribution = (user) ->
    $scope.library.contributors.push(user)
    $scope.contributor.selected = undefined
    # refresh
    $scope.filter()

  $scope.removeContribution = (user) ->
    _.pull($scope.library.contributors, user)
    # refresh
    $scope.filter()

  $scope.isSelected = (generator) ->
    if $scope.generator
      $scope.generator.identifier == generator.identifier

  $scope.isAuthor = ->
    !_.isUndefined($scope.library) && _.isEqual($scope.library.author.username, $scope.user.username) || $scope.user.isAdmin()

  $scope.filter = ->
    $scope.contributors = _.filter($scope.users, (user) ->
      !_.isEqual($scope.library.author.username, user.username) && !_.include(_.pluck($scope.library.contributors,
        'username'), user.username)
    )

  $scope.close = ->
    $modalInstance.dismiss('canceled')

  # save action
  $scope.edit = ->
    # open waiting
    wait = dialogs.wait('Please Wait', 'Saving library ...')

    # close dialog
    $modalInstance.close(wait)

    # process generators
    $scope.library.generators = _.filter($scope.generators, (generator) ->
      generator.active
    )

    apiLibrary.update({
      id: $scope.library.id
      name: $scope.library.name
      author: $scope.library.author.username
      shared: $scope.library.shared.toString()
      description: $scope.library.description
      generators: _.map($scope.library.generators, (g) ->
        { identifier: g.identifier, options: g.options }
      )
      contributors: _.pluck($scope.library.contributors, 'username')
    }, (data) ->
      # close wait dialog
      wait.close(data.library)
      # fire message
      elzoidoMessages.send('success', 'Success!', 'Library ' + data.library.name + ' was successfully saved.')
    )

  $scope.validateName = (value) ->
    !(_.contains(_.pluck($scope.libraries, 'name'),  value))