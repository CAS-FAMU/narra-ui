#
# Copyright (C) 2015 CAS / FAMU
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

angular.module('narra.ui').directive 'narraMetadata', ->
  restrict: 'A'
  transclude: true
  scope:
    api: '=narraMetadataApi'
    data: '=narraMetadataData'
    player: '=narraMetadataPlayer'
    search: '=narraMetadataSearch'
    type: '@narraMetadataType'
    ui: '@narraMetadataUi'
  controller: 'MetadataCtrl'
  templateUrl: 'partials/metadata/metadata.html'
  replace: false