#
# Copyright (C) 2014 CAS / FAMU
#
# This file is part of narra-ui.
#
# narra-ui is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# narra-ui is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with narra-ui. If not, see <http://www.gnu.org/licenses/>.
#
# Authors: Michal Mocnak <michal@marigan.net>
#

angular.module('narra.ui').config ($routeProvider, $locationProvider) ->
  # set up of the html5 mode
  $locationProvider.html5Mode true

  # routing defaults
  $routeProvider
  .when '/',
    templateUrl: 'partials/dashboard.html'
    controller: 'DashboardCtrl'
  .when '/viewer/:project',
    templateUrl: 'partials/viewer.html'
    controller: 'ViewerCtrl'
  .when '/projects',
    templateUrl: 'partials/projects.html'
    controller: 'ProjectsCtrl'
  .when '/projects/:project',
    templateUrl: 'partials/projectsDetail.html'
    controller: 'ProjectsDetailCtrl'
  .when '/sequences/:sequence',
    templateUrl: 'partials/sequencesDetail.html'
    controller: 'SequencesDetailCtrl'
  .when '/visualizations',
    templateUrl: 'partials/visualizations.html'
    controller: 'VisualizationsCtrl'
  .when '/visualizations/:visualization',
    templateUrl: 'partials/visualizationsDetail.html'
    controller: 'VisualizationsDetailCtrl'
  .when '/libraries',
    templateUrl: 'partials/libraries.html'
    controller: 'LibrariesCtrl'
  .when '/libraries/:library',
    templateUrl: 'partials/librariesDetail.html'
    controller: 'LibrariesDetailCtrl'
  .when '/items/:item',
    templateUrl: 'partials/itemsDetail.html'
    controller: 'ItemsDetailCtrl'
  .when '/users',
    templateUrl: 'partials/users.html'
    controller: 'UsersCtrl'
  .when '/system/info',
    templateUrl: 'partials/info.html'
    controller: 'InfoCtrl'
  .when '/system/settings',
    templateUrl: 'partials/settings.html'
    controller: 'SettingsCtrl'
  .otherwise
      redirectTo: '/'