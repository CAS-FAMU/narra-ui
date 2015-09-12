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

angular.module('narra.ui').factory 'serviceToken', ($location, $cookies) ->
  # resolve token from cookie
  token = $cookies.get('_narra_ui_token')
  # resolve token from the path or from cookie
  if !_.isUndefined($location.search().token)
    # resolve token from path
    token = $location.search().token
    # put token into cookie store
    $cookies.put('_narra_ui_token', token)
  # return functions
  get: ->
    # get token
    token
  clean: ->
    # clean token
    token = null
