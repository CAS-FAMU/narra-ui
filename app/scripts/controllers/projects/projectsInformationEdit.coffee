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

angular.module('narra.ui').controller 'ProjectsInformationEditCtrl', ($scope, $filter, $modalInstance, dialogs, apiProject, apiUser, apiSynthesizers, elzoidoMessages, elzoidoAuthUser, data) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.project = data.project
  $scope.initial = angular.copy(data.project)

  apiProject.all (data) ->
    $scope.projects = data.projects
  apiUser.all (data) ->
    $scope.users = data.users
    $scope.filter()
  apiSynthesizers.all (data) ->
    $scope.synthesizers = data.synthesizers

  $scope.filter = ->
    $scope.contributors = _.filter($scope.users, (user) ->
      !_.isEqual($scope.project.author.username, user.username)
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

    apiProject.update({
      name: $scope.initial.name
      new_name: project_name
      title: $scope.project.title
      author: $scope.project.author.username
      description: $scope.project.description
      synthesizers: _.pluck($scope.project.synthesizers, 'identifier')
      contributors: _.pluck($scope.project.contributors, 'username')
    }, (data) ->
      # update public metadata tag
      apiProject.metadataUpdate { name: data.project.name, meta: 'public', value: $scope.project.public.toString() }, ->
        # close wait dialog
        wait.close(data.project)
        # fire message
        elzoidoMessages.send('success', 'Success!', 'Project ' + data.project.title + ' was successfully saved.')
    )

  $scope.validateName = (value) ->
    !(_.contains(_.pluck($scope.projects, 'name'),  $filter('projectname')(value)) && !_.isEqual(value, $scope.initial.name))

  $scope.validateTitle = (value) ->
    !(_.contains(_.pluck($scope.projects, 'title'),  value) && !_.isEqual(value, $scope.initial.title))