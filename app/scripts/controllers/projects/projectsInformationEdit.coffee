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

angular.module('narra.ui').controller 'ProjectsInformationEditCtrl', ($scope, $filter, $modalInstance, dialogs, apiProject, apiLibrary, apiUser, apiSynthesizers, apiVisualization, elzoidoMessages, elzoidoAuthUser, data) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.project = data.project
  $scope.initial = angular.copy(data.project)
  $scope.contributor = {}
  $scope.library = {}

  apiProject.all (data) ->
    $scope.projects = data.projects
  apiLibrary.all (data) ->
    $scope.allLibraries = data.libraries
    $scope.filterLibraries()
  apiUser.all (data) ->
    $scope.users = data.users
    $scope.filterUsers()
  apiSynthesizers.all (data) ->
    # select first synthesizer and activate
    if !_.isEmpty($scope.project.synthesizers)
      # assign first as a selected
      $scope.synthesizer = $scope.project.synthesizers[0]
      # activate
      _.forEach(data.synthesizers, (synthesizer) ->
        synthesizer.active = _.include(_.pluck($scope.project.synthesizers, 'identifier'), synthesizer.identifier)
      )
    # prepare data for session
    $scope.synthesizers = data.synthesizers
  apiVisualization.all (data) ->
    # select first visualization and activate
    if !_.isEmpty($scope.project.visualizations)
      # assign first as a selected
      $scope.visualization = $scope.project.visualizations[0]
      # activate
      _.forEach(data.visualizations, (visualization) ->
        visualization.active = _.include(_.pluck($scope.project.visualizations, 'id'), visualization.id)
      )
    # prepare data for session
    $scope.visualizations = data.visualizations

  $scope.selectSynthesizer = (synthesizer) ->
    if synthesizer.active
      $scope.synthesizer = synthesizer

  $scope.activateSynthesizer = (synthesizer) ->
    if synthesizer.active
      $scope.synthesizer = synthesizer
    else
      $scope.synthesizer = null

  $scope.isSelectedSynthesizer = (synthesizer) ->
    if $scope.synthesizer
      $scope.synthesizer.identifier == synthesizer.identifier

  $scope.selectVisualization = (visualization) ->
    if visualization.active
      $scope.visualization = visualization

  $scope.activateVisualization = (visualization) ->
    if visualization.active
      $scope.visualization = visualization
    else
      $scope.visualization = null

  $scope.isSelectedVisualization = (visualization) ->
    if $scope.visualization
      $scope.visualization.identifier == visualization.identifier

  $scope.addContribution = (user) ->
    $scope.project.contributors.push(user)
    $scope.contributor.selected = undefined
    # refresh
    $scope.filterUsers()

  $scope.removeContribution = (user) ->
    _.pull($scope.project.contributors, user)
    # refresh
    $scope.filterUsers()

  $scope.addLibrary = (library) ->
    $scope.project.libraries.push(library)
    $scope.library.selected = undefined
    # refresh
    $scope.filterLibraries()

  $scope.removeLibrary = (library) ->
    _.pull($scope.project.libraries, library)
    # refresh
    $scope.filterLibraries()

  $scope.isAuthor = ->
    !_.isUndefined($scope.project) && _.isEqual($scope.project.author.username, $scope.user.username) || $scope.user.isAdmin()

  $scope.filterUsers = ->
    $scope.contributors = _.filter($scope.users, (user) ->
      !_.isEqual($scope.project.author.username, user.username) && !_.include(_.pluck($scope.project.contributors,
        'username'), user.username)
    )

  $scope.filterLibraries = ->
    $scope.libraries = _.filter($scope.allLibraries, (library) ->
      !_.include(_.pluck($scope.project.libraries, 'id'), library.id)
    )

  $scope.close = ->
    $modalInstance.dismiss('canceled')

  # save action
  $scope.edit = ->
# open waiting
    wait = dialogs.wait('Please Wait', 'Saving project ...')

    # close dialog
    $modalInstance.close(wait)

    # append date suffix
    project_name = $filter('projectname')($scope.project.name)

    # process synthesizers
    $scope.project.synthesizers = _.filter($scope.synthesizers, (synthesizer) ->
      synthesizer.active
    )

    # process visualizations
    $scope.project.visualizations = _.filter($scope.visualizations, (visualization) ->
      visualization.active
    )

    apiProject.update({
        name: $scope.initial.name
        new_name: project_name
        title: $scope.project.title
        author: $scope.project.author.username
        description: $scope.project.description
        synthesizers: _.collect($scope.project.synthesizers, (s) ->
          {identifier: s.identifier, options: s.options})
        visualizations: _.collect($scope.project.visualizations, (v) ->
          { id: v.id, type: v.type, options: v.options})
        contributors: _.pluck($scope.project.contributors, 'username')
        libraries: _.pluck($scope.project.libraries, 'id')
        public: $scope.project.public
      }, (data) ->
        # close wait dialog
        wait.close(data.project)
        # fire message
        elzoidoMessages.send('success', 'Success!', 'Project ' + data.project.title + ' was successfully saved.')
    )

  $scope.validateName = (value) ->
    !(_.contains(_.pluck($scope.projects, 'name'), $filter('projectname')(value)) && !_.isEqual(value,
      $scope.initial.name))

  $scope.validateTitle = (value) ->
    !(_.contains(_.pluck($scope.projects, 'title'), value) && !_.isEqual(value, $scope.initial.title))