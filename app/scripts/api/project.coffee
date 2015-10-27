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


angular.module('narra.ui').factory "apiProject", ($resource, serviceServer, serviceToken) ->
  $resource serviceServer.url + "/v1/projects/:action0/:name/:action1/:param/:action2",
    token: serviceToken.get()
  ,
    all:
      method: 'GET'

    get:
      method: 'GET'

    new:
      method: 'POST'
      params:
        action1: 'new'

    delete:
      method: 'GET'
      params:
        action1: 'delete'

    validate:
      method: 'POST'
      params:
        action0: 'validate'

    update:
      method: 'POST'
      params:
        name: '@name'
        action1: 'update'

    items:
      method: 'GET'
      params:
        action1: 'items'

    junctions:
      method: 'GET'
      params:
        action1: 'junctions'

    junctionsItems:
      method: 'GET'
      params:
       action1: 'junctions'
       action2: 'items'

    sequences:
      method: 'GET'
      params:
        action1: 'sequences'

    sequencesNew:
      method: 'POST'
      headers: {'Content-Type': undefined}
      params:
        name: '@name'
        action1: 'sequences'
        action2: 'new'

    sequencesDelete:
      method: 'GET'
      params:
        action1: 'sequences'
        action2: 'delete'

    sequencesUpdate:
      method: 'POST'
      params:
        name: '@name'
        param: '@sequence'
        action1: 'sequences'
        action2: 'update'

    metadataNew:
      method: 'POST'
      params:
        name: '@name'
        action1: 'metadata'
        action2: 'new'

    metadataUpdate:
      method: 'POST'
      params:
        name: '@name'
        param: '@meta'
        action1: 'metadata'
        action2: 'update'

    metadataDelete:
      method: 'GET'
      params:
        action1: 'metadata'
        action2: 'delete'

    visualizationsAction:
      method: 'POST'
      params:
        name: '@name'
        action1: 'visualizations'
        action2: '@action'