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

angular.module('narra.ui').controller 'MetadataShotTypeCtrl', ($scope, $modalInstance, dialogs, elzoidoMessages, elzoidoAuthUser) ->
  $scope.user = elzoidoAuthUser.get()
  $scope.meta = {name: 'shot_type', value: '' }

  $scope.shots = [
    'Aerial Shot', 'Arc Shot', 'Bridging Shot', 'Close Up', 'Medium Shot', 'Long Shot', 'Cowboy Shot', 'Deep Focus',
    'Dolly Zoom', 'Dutch Tilt', 'Establishing Shot', 'Handheld Shot', 'Low Angle Shot', 'High Angle Shot',
    'Locked-Down Shot', 'Library Shot', 'Matte Shot', 'Money Shot', 'Over-The-Shoulder Shot', 'Pan', 'POV',
    'The Sequence Shot', 'Steadicam Shot', 'Tilt', 'Top Shot', 'Tracking Shot', 'Two-Shot', 'Whip Pan', 'Zoom',
    'Crane Shot', 'Static Shot'
  ]

  $scope.close = ->
    # cancel dialog
    $modalInstance.dismiss('canceled')

  $scope.add = ->
    # add meta
    $modalInstance.close($scope.meta)