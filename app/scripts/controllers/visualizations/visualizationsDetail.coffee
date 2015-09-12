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

angular.module('narra.ui').controller 'VisualizationsDetailCtrl', ($scope, $sce, $timeout, $rootScope, $http, $routeParams, $location, $document, $interval, $filter, $q, dialogs, apiVisualization, apiUser, elzoidoPromises, elzoidoAuthUser, elzoidoMessages) ->
  $scope.editorOption =
    theme: 'xcode',
    require: ['ace/ext/language_tools', 'ace/ext/static_highlight', 'ace/ext/error_marker', 'ace/ext/searchbox'],
    advanced: {
      enableSnippets: true,
      enableBasicAutocompletion: true,
      enableLiveAutocompletion: true
    },
    onLoad: (editor) ->
      session = editor.getSession()
      # resolve mode
      if _.isEqual($scope.visualization.type, 'processing')
        session.setMode('ace/mode/java')
      else
        session.setMode('ace/mode/javascript')
      # listen for changes
      session.on "change", ->
        $scope.newContent = session.getValue()

  # refresh data
  $scope.refresh = ->
    # get current user
    $scope.user = elzoidoAuthUser.get()
    # get deffered
    visualization = $q.defer()

    apiVisualization.get {id: $routeParams.visualization}, (data) ->
      # get visualization
      $scope.visualization = data.visualization
      $http.get($scope.visualization.script).success (data, status, headers, config) ->
        $scope.content = data
        $scope.ready = true
        visualization.resolve true

    # register promises into one queue
    elzoidoPromises.register('visualization', [visualization.promise])

  $scope.edit = ->
    confirm = dialogs.create('partials/visualizationsInformationEdit.html', 'VisualizationsInformationEditCtrl',
      {visualization: $scope.visualization},
      {size: 'lg', keyboard: false})
    # result
    confirm.result.then (wait) ->
      wait.result.then ->
        # fire event
        $rootScope.$broadcast 'event:narra-visualization-updated', $routeParams.visualization

  $scope.delete = ->
    # open confirmation dialog
    confirm = dialogs.confirm('Please Confirm',
      'You are about to delete the visualization ' + $scope.visualization.name + ', this procedure is irreversible. Do you want to continue ?')

    # result
    confirm.result.then ->
      # delete storage and its projects
      apiVisualization.delete {id: $scope.visualization.id}, ->
        # send message
        elzoidoMessages.send('success', 'Success!', 'Visualization ' + $scope.visualization.name + ' was successfully deleted.')
        # redirect back to project
        $location.url('/visualizations')

  # save action
  $scope.save = ->
    # create form data object
    data = new FormData()

    # get file name
    if _.isEqual($scope.visualization.type, 'processing')
      fileName = $scope.visualization.type + '.pde'
    else
      fileName = $scope.visualization.type + '.js'

    # create file
    file = new File([$scope.newContent], fileName)

    # set up
    data.append('file', file)

    # open waiting
    wait = dialogs.wait('Please Wait', 'Saving visualization ...')

    apiVisualization.update({id: $scope.visualization.id}, data, (data) ->
      # workaround to get sequence processed
      $timeout( ->
        # refresh
        $scope.refresh();
        # close wait dialog
        wait.close($scope.visualization.name)
        # fire message
        elzoidoMessages.send('success', 'Success!', 'Visualization ' + $scope.visualization.name + ' was successfully updated.')
      , 1000)
    )

  # refresh when new library is added
  $scope.$on 'event:narra-visualization-updated', (event, visualization) ->
    if !_.isUndefined($routeParams.visualization) && _.isEqual($routeParams.visualization, visualization)
      $scope.refresh()

  # initial data
  $scope.refresh()