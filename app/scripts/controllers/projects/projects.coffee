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

angular.module('narra.ui').controller 'ProjectsCtrl', ($scope, $rootScope, $location, $filter, $q, dialogs, apiProject, apiUser, elzoidoPromises, elzoidoAuthUser, elzoidoMessages) ->
  # initialization
  $scope.tabs = { myProjects: { }, contribProjects: { } }

  elzoidoPromises.promise('authentication').then ->
    $scope.refresh = ->
      # get current user
      $scope.user = elzoidoAuthUser.get()
      # get deffered
      projects = $q.defer()

      apiProject.all (data) ->
        $scope.projects = _.filter(data.projects, (project) ->
          _.isEqual(project.author.username, $scope.user.username))
        $scope.contributions = _.filter(data.projects, (project) ->
          _.contains(_.pluck(project.contributors, 'username'), $scope.user.username))
        if  $scope.projects.length == 0
          $scope.tabs.contribProjects = { active: true }
        else
          $scope.tabs.myProjects = { active: true }
        projects.resolve true

      # register promises into one queue
      elzoidoPromises.register('dashboard', [projects.promise])

    # click functionfor detail view
    $scope.detailProject = (project) ->
      $location.path('/projects/' + project.name)

    # refresh when new project is added
    $rootScope.$on 'event:narra-project-created', (event, status) ->
      $scope.refresh()

    # click function for detail view
    $scope.detail = (project) ->
      $location.path('/projects/' + project.name)

    # initial data
    $scope.refresh()