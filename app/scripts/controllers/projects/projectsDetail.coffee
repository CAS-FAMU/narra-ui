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

angular.module('narra.ui').controller 'ProjectsDetailCtrl', ($scope, $rootScope, $window, $document, $routeParams, $location, $filter, $q, dialogs, apiProject, apiVisualization, apiUser, elzoidoPromises, elzoidoMessages, elzoidoAuthUser) ->
  # initialization
  $scope.tabs = {project: {active: true}, libraries: {}, sequences: {}, visualizations: {}, layouts: {}, metadata: {}}

  elzoidoPromises.promise('authentication').then ->
    $scope.refresh = ->
      # get current user
      $scope.user = elzoidoAuthUser.get()
      # get deffered
      project = $q.defer()
      sequences = $q.defer()
      junctions = $q.defer()
      visualizations = $q.defer()

      $scope.projectMetadata = {}
      $scope.junctions = {}

      if !_.isUndefined($routeParams.tab)
        $scope.tabs[$routeParams.tab].active = true

      apiProject.get {name: $routeParams.project}, (data) ->
        data.project.metadata = _.filter(data.project.metadata, (meta) ->
          !_.isEqual(meta.name, 'public')
        )
        $scope.project = data.project
        project.resolve true

      apiProject.sequences {name: $routeParams.project}, (data) ->
        $scope.sequences = data.sequences
        sequences.resolve true

      project.promise.then () ->
        _.forEach($scope.project.synthesizers, (synthesizer, index) ->
          apiProject.junctions {name: $routeParams.project, param: synthesizer.identifier}, (data) ->
            $scope.junctions[synthesizer.identifier] = data.junctions
            if index + 1 == $scope.project.synthesizers.length
              junctions.resolve true
        )
        if _.isEmpty($scope.project.synthesizers)
          junctions.resolve true
        apiVisualization.all (data) ->
          $scope.visualizations = _.filter(data.visualizations, (visualization) ->
            _.contains(_.pluck($scope.project.visualizations, 'id'), visualization.id)
          )
          visualizations.resolve true

      # register promises into one queue
      elzoidoPromises.register('project',
        [project.promise, sequences.promise, visualizations.promise, junctions.promise])

    $scope.getItem = (item, array) ->
      _.find(array, {id: item})

    $scope.getColor = (weight) ->
      255 - weight * 50

    $scope.isEmpty = (object) ->
      Object.keys(object).length == 0

    $scope.edit = ->
      confirm = dialogs.create('partials/projectsInformationEdit.html', 'ProjectsInformationEditCtrl',
        {
          project: $scope.project
          sequences: $scope.sequences
        },
        {size: 'lg', keyboard: false})
      # result
      confirm.result.then (wait) ->
        wait.result.then (project)->
          # fire event
          $rootScope.$broadcast 'event:narra-project-updated', project.name

    $scope.isAuthor = ->
      !_.isUndefined($scope.project) && _.isEqual($scope.project.author.username,
        $scope.user.username) || $scope.user.isAdmin()

    $scope.delete = ->
      # open confirmation dialog
      confirm = dialogs.confirm('Please Confirm',
        'You are about to delete the project ' + $scope.project.title + ', this procedure is irreversible. Do you want to continue ?')

      # result
      confirm.result.then ->
        # delete storage and its projects
        apiProject.delete {name: $scope.project.name}, ->
          # redirect back to libraries
          $location.url('/projects/')
          # send message
          elzoidoMessages.send('success', 'Success!', 'Project ' + $scope.project.name + ' was successfully deleted.')

    # click function for detail view
    $scope.detailLibrary = (library, index) ->
      $location.url('/libraries/' + library.id + '?project=' + $scope.project.name)

    # click function for detail view
    $scope.detailSequence = (sequence, index) ->
      $location.url('/sequences/' + sequence.id + '?project=' + $scope.project.name)

    $scope.addVisualization = (visualization) ->
      apiProject.visualizationsAction {name: $scope.project.name, action: 'add', visualizations: [visualization.id]}, ->
        # send message
        elzoidoMessages.send('success', 'Success!', 'Visualization ' + visualization.name + ' was successfully added.')
        # refresh
        $scope.refresh()

    $scope.removeVisualization = (visualization) ->
      apiProject.visualizationsAction {
        name: $scope.project.name,
        action: 'remove',
        visualizations: [visualization.id]
      }, ->
        # send message
        elzoidoMessages.send('success', 'Success!',
          'Visualization ' + visualization.name + ' was successfully removed.')
        # refresh
        $scope.refresh()

    $scope.preview = (visualization) ->
      $window.open('/viewer/' + $scope.project.name + '?visualization=' + visualization.id, visualization.id, '_blank')

    # refresh when new library is added
    $scope.$on 'event:narra-library-created', (event) ->
      if !_.isUndefined($routeParams.project)
        $scope.refresh()

    # refresh when new library is added
    $rootScope.$on 'event:narra-library-purged', (event, status) ->
      $scope.refresh()

    # refresh when new sequence is added
    $scope.$on 'event:narra-sequence-created', (event) ->
      if !_.isUndefined($routeParams.project)
        $scope.refresh()

    # refresh when new library is added
    $scope.$on 'event:narra-project-updated', (event, project) ->
      if _.isEqual($routeParams.project, project)
        $scope.refresh()

    # initial data
    $scope.refresh()