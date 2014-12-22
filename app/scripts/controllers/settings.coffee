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

angular.module('narra.ui').controller 'SettingsCtrl', ($scope, $q, apiSettings, elzoidoMessages, elzoidoPromises) ->
  # setup grid
  $scope.gridOptions = {
    data: 'settings'
  }

  $scope.gridOptions.enableCellEditOnFocus = true;

  $scope.gridOptions.columnDefs = [
    { name: 'name', displayName: 'Name', enableCellEdit: false},
    { name: 'value', displayName: 'Value', enableCellEdit: true},
  ]

  $scope.gridOptions.onRegisterApi = (gridApi) ->
    gridApi.edit.on.afterCellEdit $scope, (rowEntity, colDef, newValue, oldValue) ->
      apiSettings.update (rowEntity), ->
        # fire message
        elzoidoMessages.send("success", "Success!", "Property " + rowEntity.name + " was successfully updated.")

  # refresh function
  $scope.refresh = ->
    # get deffered
    all = $q.defer()
    defaults = $q.defer()
    # get all settings and get back to view
    apiSettings.all (data) ->
      $scope.settings = data.settings
      # resize grid
      angular.element(document.getElementsByClassName('grid')[0]).css('width', '100%');
      angular.element(document.getElementsByClassName('grid')[0]).css('height', Math.floor($scope.settings.length*33) + 'px');
      # resolve defer
      all.resolve true
    apiSettings.defaults (data) ->
      $scope.defaults = data.defaults
      # resolve defer
      defaults.resolve true
    # register promises into one queue
    elzoidoPromises.register('settings', [all.promise, defaults.promise])
    # show wait dialog when the loading is taking long
    elzoidoPromises.wait('settings', 'Loading settings ...')

  # initial data
  $scope.refresh()