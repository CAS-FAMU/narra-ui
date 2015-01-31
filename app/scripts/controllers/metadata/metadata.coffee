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

angular.module('narra.ui').controller 'MetadataCtrl', ($scope, $rootScope, $routeParams, dialogs, constantMetadata, elzoidoMessages, apiItem, apiLibrary, apiProject) ->
  # prepare data
  $scope.refresh = ->
    # init api
    $scope.api = $scope.api || {}

    # init data
    switch($scope.type)
      when 'item'
        # assign data
        $scope.item = $scope.data
        # temporary meta container
        meta = {}
        generators = []
        # prepare metadata
        _.forEach(_.filter(_.uniq(_.pluck($scope.item.metadata, 'generator')), (generator) ->
            !_.isEqual(generator, 'thumbnail') && !_.isEqual(generator, 'transcoder')
          ), (generator) ->
          # assign generator
          generators.push(generator)
          # check
          if generator.indexOf('user') > -1
            # init
            meta['user'] = {name: 'user', data: []} if _.isUndefined(meta['user'])
            # push into
            meta['user'].data = meta['user'].data.concat(_.where($scope.item.metadata, {'generator': generator}))
          else
            meta[generator] = {name: generator, data: _.where($scope.item.metadata, {'generator': generator})}
        )
        # assign meta
        $scope.meta = meta
        # assign used generators
        $scope.generators = generators
        # local methods
        $scope.edit = (meta) ->
          # get relevant provider
          provider = _.find(constantMetadata.providers, { id: meta.generator })
          # switch to custom if there is no appropriate
          if _.isUndefined(provider)
            provider = _.find(constantMetadata.providers, { id: 'user_custom' })
          # get mark object
          mark =
            use: !_.isEmpty(meta.marks)
            in: if _.isEmpty(meta.marks) then Math.floor(($scope.player.currentTime.getTime() / 1000) + 3600) else meta.marks[0].in
            out: if _.isEmpty(meta.marks) then undefined else meta.marks[0].out
            max: Math.floor(($scope.player.totalTime.getTime() / 1000) + 3600)
          # open confirmation dialog
          confirm = dialogs.create(provider.templateEdit, provider.controller, { meta: meta, seek: $scope.seek, mark: mark },
            {size: 'lg', keyboard: false})
          # result
          confirm.result.then (data) ->
            switch(data.action)
              when 'update'
                # open waiting
                waiting = dialogs.wait('Please Wait', 'Updating metadata ...')
                # check for array
                if _.isArray(data.meta.value)
                  data.meta.value = data.meta.value.join(', ')
                # update
                apiItem.metadataUpdate {id: $scope.item.id, meta: data.meta.name, value: data.meta.value, marks: data.meta.marks, generator: meta.generator}, ->
                  # close dialog
                  waiting.close()
                  # send message
                  elzoidoMessages.send('success', 'Success!', 'Metadata was successfully updated.')
                  # broadcast event
                  $rootScope.$broadcast 'event:narra-item-updated', $scope.item.id
              when 'delete'
              # open waiting
                waiting = dialogs.wait('Please Wait', 'Deleting metadata ...')
                # update
                apiItem.metadataDelete {id: $scope.item.id, param: data.meta.name, generator: meta.generator}, ->
                  # close dialog
                  waiting.close()
                  # send message
                  elzoidoMessages.send('success', 'Success!', 'Metadata was successfully deleted.')
                  # broadcast event
                  $rootScope.$broadcast 'event:narra-item-updated', $scope.item.id
        # API Methods
        # define methods
        $scope.api.regenerate = (generator) ->
          # open confirmation dialog
          confirm = dialogs.confirm('Please Confirm',
            'You are about to regenerate the item ' + $scope.item.name + ', this will erase all metadata by the generator. Do you want to continue ?')

          # result
          confirm.result.then ->
            # regenerate item for the selected generator
            apiItem.regenerate {id: $scope.item.id, param: generator}, ->
              # send message
              elzoidoMessages.send('success', 'Success!', 'Item ' + $scope.item.name + ' was successfully deleted.')
              # brodcast event
              $rootScope.$broadcast 'event:narra-item-updated', $scope.item.id

        $scope.api.add = (provider) ->
          # open confirmation dialog
          confirm = dialogs.create(provider.templateAdd, provider.controller, { all: _.pluck($scope.item.metadata, 'name'), seek: $scope.seek, mark: { use: false, in: Math.floor(($scope.player.currentTime.getTime() / 1000) + 3600), max: Math.floor(($scope.player.totalTime.getTime() / 1000) + 3600)}, out: undefined },
            {size: 'lg', keyboard: false})
          # result
          confirm.result.then (meta) ->
            # open waiting
            waiting = dialogs.wait('Please Wait', 'Adding new metadata ...')
            # check for array
            if _.isArray(meta.value)
              meta.value = meta.value.join(', ')
            # add
            apiItem.metadataNew {id: $scope.item.id, meta: meta.name, value: meta.value, marks: meta.marks, generator: provider.id}, ->
              # close dialog
              waiting.close()
              # send message
              elzoidoMessages.send('success', 'Success!', 'New metadata was successfully created.')
              # broadcast event
              $rootScope.$broadcast 'event:narra-item-updated', $scope.item.id
      when 'library'
        # assign data
        $scope.library = $scope.data
        # init metadata
        $scope.meta = $scope.library.metadata
        # local methods
        $scope.edit = (meta) ->
          # get custom provider
          provider = _.find(constantMetadata.providers, { id: 'user_custom' })
          # open confirmation dialog
          confirm = dialogs.create(provider.templateEdit, provider.controller, { meta: meta },
            {size: 'lg', keyboard: false})
          # result
          confirm.result.then (data) ->
            switch(data.action)
              when 'update'
                # open waiting
                waiting = dialogs.wait('Please Wait', 'Updating metadata ...')
                # update
                apiLibrary.metadataUpdate {id: $scope.library.id, meta: data.meta.name, value: data.meta.value}, ->
                  # close dialog
                  waiting.close()
                  # send message
                  elzoidoMessages.send('success', 'Success!', 'Metadata was successfully updated.')
                  # broadcast event
                  $rootScope.$broadcast 'event:narra-library-updated', $scope.library.id
              when 'delete'
              # open waiting
                waiting = dialogs.wait('Please Wait', 'Deleting metadata ...')
                # update
                apiLibrary.metadataDelete {id: $scope.library.id, param: data.meta.name}, ->
                  # close dialog
                  waiting.close()
                  # send message
                  elzoidoMessages.send('success', 'Success!', 'Metadata was successfully deleted.')
                  # broadcast event
                  $rootScope.$broadcast 'event:narra-library-updated', $scope.library.id
        # API Methods
        # define methods
        $scope.api.regenerate = (generator) ->
          # open confirmation dialog
          confirm = dialogs.confirm('Please Confirm',
            'You are about to regenerate the library ' + $scope.library.name + ', this will erase all metadata by the generator. Do you want to continue ?')
          # result
          confirm.result.then ->
            # regenerate item for the selected generator
            apiLibrary.regenerate {id: $scope.library.id, param: generator}, ->
              # send message
              elzoidoMessages.send('success', 'Success!', 'Library ' + $scope.library.name + ' was successfully regenerated.')
              # brodcast event
              $rootScope.$broadcast 'event:narra-library-updated', $scope.library.id
        $scope.api.add = ->
          # get custom provider
          provider = _.find(constantMetadata.providers, { id: 'user_custom' })
          # open confirmation dialog
          confirm = dialogs.create(provider.templateAdd, provider.controller, { all: _.pluck($scope.library.metadata, 'name') },
            {size: 'lg', keyboard: false})
          # result
          confirm.result.then (meta) ->
            # open waiting
            waiting = dialogs.wait('Please Wait', 'Adding new metadata ...')
            # add
            apiLibrary.metadataNew {id: $scope.library.id, meta: meta.name, value: meta.value}, ->
              # close dialog
              waiting.close()
              # send message
              elzoidoMessages.send('success', 'Success!', 'New metadata was successfully created.')
              # broadcast event
              $rootScope.$broadcast 'event:narra-library-updated', $scope.library.id
      when 'project'
        # assign data
        $scope.project = $scope.data
        # init metadata
        $scope.meta = $scope.project.metadata
        # local methods
        $scope.edit = (meta) ->
          # get custom provider
          provider = _.find(constantMetadata.providers, { id: 'user_custom' })
          # open confirmation dialog
          confirm = dialogs.create(provider.templateEdit, provider.controller, { meta: meta },
            {size: 'lg', keyboard: false})
          # result
          confirm.result.then (data) ->
            switch(data.action)
              when 'update'
              # open waiting
                waiting = dialogs.wait('Please Wait', 'Updating metadata ...')
                # update
                apiProject.metadataUpdate {name: $scope.project.name, meta: data.meta.name, value: data.meta.value}, ->
                  # close dialog
                  waiting.close()
                  # send message
                  elzoidoMessages.send('success', 'Success!', 'Metadata was successfully updated.')
                  # broadcast event
                  $rootScope.$broadcast 'event:narra-project-updated', $scope.project.name
              when 'delete'
              # open waiting
                waiting = dialogs.wait('Please Wait', 'Deleting metadata ...')
                # update
                apiProject.metadataDelete {name: $scope.project.name, param: data.meta.name}, ->
                  # close dialog
                  waiting.close()
                  # send message
                  elzoidoMessages.send('success', 'Success!', 'Metadata was successfully deleted.')
                  # broadcast event
                  $rootScope.$broadcast 'event:narra-project-updated', $scope.project.name
        # API Methods
        # define methods
        $scope.api.add = ->
          # get custom provider
          provider = _.find(constantMetadata.providers, { id: 'user_custom' })
          # open confirmation dialog
          confirm = dialogs.create(provider.templateAdd, provider.controller, { all: _.pluck($scope.project.metadata, 'name').concat(['public']) },
            {size: 'lg', keyboard: false})
          # result
          confirm.result.then (meta) ->
            # open waiting
            waiting = dialogs.wait('Please Wait', 'Adding new metadata ...')
            # add
            apiProject.metadataNew {name: $scope.project.name, meta: meta.name, value: meta.value}, ->
              # close dialog
              waiting.close()
              # send message
              elzoidoMessages.send('success', 'Success!', 'New metadata was successfully created.')
              # broadcast event
              $rootScope.$broadcast 'event:narra-project-updated', $scope.project.name

  # check when the data are prepared
  $scope.$watch 'data', (data) ->
    $scope.refresh() if !_.isUndefined(data)

  $scope.seek = (position) ->
    $scope.player.seekTime(position)

  # LISTENERS
  # item listener
  $rootScope.$on 'event:narra-item-updated', (event, item) ->
    if _.isEqual($scope.type, 'item') && _.isEqual($routeParams.item, item)
      $scope.refresh()
  # library listener
  $rootScope.$on 'event:narra-library-updated', (event, library) ->
    if _.isEqual($scope.type, 'library') && _.isEqual($routeParams.library, library)
      $scope.refresh()
  # library listener
  $rootScope.$on 'event:narra-project-updated', (event, project) ->
    if _.isEqual($scope.type, 'project') && _.isEqual($routeParams.project, project)
      $scope.refresh()