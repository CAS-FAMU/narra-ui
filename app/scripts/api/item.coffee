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


angular.module('narra.ui').factory "apiItem", ($resource, serviceServer, serviceToken) ->
  $resource serviceServer.url + "/v1/items/:id/:action0/:param/:action1",
    token: serviceToken.get()
  ,
    all:
      method: 'GET'

    get:
      method: 'GET'

    check:
      method: 'POST'
      params:
        action0: 'check'

    new:
      method: 'POST'
      params:
        action0: 'new'

    delete:
      method: 'GET'
      params:
        action0: 'delete'

    events:
      method: 'GET'
      params:
        action0: 'events'

    thumbnails:
      method: 'GET'
      params:
        id: 'thumbnails'

    regenerate:
      method: 'GET'
      params:
        action0: 'regenerate'

    metadata:
      method: 'GET'
      params:
        id: '@id'
        action0: 'metadata'

    metadataNew:
      method: 'POST'
      params:
        id: '@id'
        action0: 'metadata'
        action1: 'new'

    metadataUpdate:
      method: 'POST'
      params:
        id: '@id'
        param: '@meta'
        action0: 'metadata'
        action1: 'update'

    metadataDelete:
      method: 'GET'
      params:
        action0: 'metadata'
        action1: 'delete'