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


angular.module('narra.ui').factory "apiLibrary", ($resource, serviceServer, serviceToken) ->
  $resource serviceServer.url + "/v1/libraries/:id/:action",
    token: serviceToken.get()
  ,
    all:
      method: 'GET'

    get:
      method: 'GET'

    new:
      method: 'POST'
      params:
        action: 'new'

    delete:
      method: 'GET'
      params:
        action: 'delete'

    items:
      method: 'GET'
      params:
        action: 'items'

    update:
      method: 'POST'
      params:
        name: '@id'
        action: 'update'