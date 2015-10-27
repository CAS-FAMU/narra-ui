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

angular.module('narra.ui').constant 'constantMetadata',
  providers: [
    {id: 'author', name: 'Author', templateAdd: 'partials/metadata/metadataAuthorAdd.html', templateEdit: 'partials/metadata/metadataAuthorEdit.html', controller: 'MetadataAuthorCtrl'}
    {id: 'keywords', name: 'Keywords', templateAdd: 'partials/metadata/metadataKeywordsAdd.html', templateEdit: 'partials/metadata/metadataKeywordsEdit.html', controller: 'MetadataKeywordsCtrl'}
    {id: 'people', name: 'People', templateAdd: 'partials/metadata/metadataPeopleAdd.html', templateEdit: 'partials/metadata/metadataPeopleEdit.html', controller: 'MetadataPeopleCtrl'}
    {id: 'organizations', name: 'Organizations', templateAdd: 'partials/metadata/metadataOrganizationsAdd.html', templateEdit: 'partials/metadata/metadataOrganizationsEdit.html', controller: 'MetadataOrganizationsCtrl'}
    {id: 'language', name: 'Language', templateAdd: 'partials/metadata/metadataLanguageAdd.html', templateEdit: 'partials/metadata/metadataLanguageEdit.html', controller: 'MetadataLanguageCtrl'}
    {id: 'summary', name: 'Summary', templateAdd: 'partials/metadata/metadataSummaryAdd.html', templateEdit: 'partials/metadata/metadataSummaryEdit.html', controller: 'MetadataSummaryCtrl'}
    {id: 'description', name: 'Description', templateAdd: 'partials/metadata/metadataDescriptionAdd.html', templateEdit: 'partials/metadata/metadataDescriptionEdit.html', controller: 'MetadataDescriptionCtrl'}
    {id: 'shot_type', name: 'Shot Type', templateAdd: 'partials/metadata/metadataShotTypeAdd.html', templateEdit: 'partials/metadata/metadataShotTypeEdit.html', controller: 'MetadataShotTypeCtrl'}
    {id: 'custom', name: 'Custom', templateAdd: 'partials/metadata/metadataCustomAdd.html', templateEdit: 'partials/metadata/metadataCustomEdit.html', controller: 'MetadataCustomCtrl'},
    {id: 'location', name: 'Location', templateAdd: 'partials/metadata/metadataLocationAdd.html', templateEdit: 'partials/metadata/metadataLocationEdit.html', controller: 'MetadataLocationCtrl'}
  ]