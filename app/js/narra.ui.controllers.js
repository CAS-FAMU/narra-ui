'use strict';

/*
 #
 # Copyright (C) 2013 CAS / FAMU
 #
 # This file is part of Narra UI.
 #
 # Narra UI is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # Narra UI is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with Narra UI. If not, see <http://www.gnu.org/licenses/>.
 #
 # Authors: Michal Mocnak <michal@marigan.net>, Krystof Pesek <krystof.pesek@gmail.com>
 #
 */

// controllers
function DashboardCtrl($scope, api_Project) {
    // refresh function
    $scope.refresh = function () {
        // get all projects
        api_Project.all(function(data) {
            $scope.projects = data.projects;
        });
    }

    // initial data
    $scope.refresh();
}

function SystemSettingsCtrl($scope, service_Messages, api_Settings) {
    // refresh function
    $scope.refresh = function () {
        // get all settings and get back to view
        api_Settings.all(function (data) {
            $scope.settings = data.settings;
        });

        // get default values
        api_Settings.defaults(function (data) {
            $scope.defaults = data.defaults;
        });

        // default values
        $scope.cancel();
    }

    // set up editable flag for the single field
    $scope.edit = function (item) {
        $scope.editable = { name: item.name, value: item.value };
        $scope.resetable = !_.isEqual($scope.defaults[item.name], item.value);
    }

    $scope.$watch('editable.value', function (item) {
        if (!_.isNull(item)) {
            $scope.changed = !_.isEqual(_.find($scope.settings, {name: $scope.editable.name}).value, $scope.editable.value);
            $scope.resetable = !_.isEqual($scope.defaults[$scope.editable.name], $scope.editable.value);
        }
    });

    // reset editable flag
    $scope.cancel = function () {
        $scope.editable = null;
        $scope.changed = false;
        $scope.resetable = false;
    }

    $scope.default = function () {
        $scope.editable.value = $scope.defaults[$scope.editable.name];
    }

    // update values
    $scope.update = function () {
        api_Settings.update({name: String($scope.editable.name), value: String($scope.editable.value)}, function () {
            // update collection just for view
            $.grep($scope.settings, function (item) {
                if (_.isEqual(item.name, $scope.editable.name)) {
                    item.value = $scope.editable.value;
                }
            });

            // fire message
            service_Messages.send('success', 'Success!', 'Property ' + $scope.editable.name + ' was successfully updated.');

            // end up edit mode
            $scope.cancel();
        });
    }

    // initial data
    $scope.refresh();
}

function UsersCtrl($scope, $location, api_User) {
    // initial value
    $scope.empty = true;

    // refresh function
    $scope.refresh = function () {
        // get all projects and get back to view
        api_User.all(function (data) {
            $scope.users = data.users;
            $scope.empty = (data.users.length < 1);
        });
    }

    // detail user
    $scope.detail = function (user) {
        $location.path('/users/' + user.id);
    }

    // initial data
    $scope.refresh();
}

function UsersDetailCtrl($scope, $rootScope, $location, $routeParams, service_User, api_User, service_Messages ) {
    // if me
    $scope.me = _.isEqual($routeParams.id, 'me');

    // refresh function
    $scope.refresh = function () {
        // get changed and admin flag
        $scope.changed = false;
        $scope.admin = service_User.admin();

        // get user data
        if (!$scope.me) {
            api_User.get($scope.me ? {id: service_User.current().id} : {id: $routeParams.id}, function (data) {
                $scope.user = data.user;
                $scope.deletable = !_.isEqual(data.user, service_User.current());
                // check for roles
                $scope.check();
            });
        } else {
            $scope.user = service_User.current();
            $scope.deletable = false;
            // check for roles
            $scope.check();
        }
    };

    $scope.check = function () {
        // get roles and check for user ones
        api_User.roles(function (data) {
            // temporary array
            var roles = new Array();
            // mark checked
            _.each(data.roles, function (role) {
                if (_.contains($scope.user.roles, role)) {
                    roles.push({name: role, checked: true});
                } else {
                    roles.push({name: role});
                }
            });

            // push into model
            $scope.roles = roles;
        });
    }

    // change action
    $scope.update = function () {
        $scope.changed = !_.isEqual(_.pluck(_.where($scope.roles, {checked: true}), 'name'), $scope.user.roles);
    };

    // check if last checked
    $scope.last = function (role) {
        return _.isEmpty(_.difference(_.where($scope.roles, {checked: true}), role));
    }

    $scope.open = function () {
        $scope.shouldBeOpen = true;
    };

    $scope.close = function () {
        $scope.shouldBeOpen = false;
    };

    $scope.cancel = function () {
        $scope.refresh();
    };

    $scope.opts = {
        backdropFade: true,
        dialogFade: true
    };

    // save user
    $scope.save = function () {
        api_User.update({id: $scope.user.id, roles: _.pluck(_.where($scope.roles, {checked: true}), 'name')}, function (data) {
            // if updating yourself then fire new user
            if (_.isEqual($scope.user, service_User.current())) {
                $rootScope.$broadcast('event:auth_user', data.user);
            }
            // send message
            service_Messages.send('success', 'Success!', 'User roles were successfully updated for ' + $scope.user.name + '.');

            // refresh
            $scope.refresh();
        });
    };

    // delete user
    $scope.delete = function () {
        // delete storage and its projects
        api_User.delete({id: $scope.user.id}, function() {
            // close dialog
            $scope.close();
            // get back to the overview
            $location.path('/users');
            // fire alert
            service_Messages.send('success', 'Success!', 'User ' + $scope.user.name + ' was successfully deleted.');
        });
    };

    // initial data
    $scope.refresh();
}

function ProjectsCtrl($scope, $location, $filter, service_Messages, api_Project) {
    // initial value
    $scope.empty = true;

    // refresh function
    $scope.refresh = function () {
        // get all projects and get back to view
        api_Project.all(function (data) {
            $scope.empty = (data.projects.length < 1);
            $scope.projects = data.projects;
        });
    };

    // click functionfor detail view
    $scope.detail = function (project) {
        $location.path('/projects/' + project.name);
    };

    $scope.open = function () {
        $scope.shouldBeOpen = true;
    };

    $scope.close = function () {
        $scope.shouldBeOpen = false;
        $scope.project.name = null;
        $scope.project.title = null;
    };

    $scope.opts = {
        backdropFade: true,
        dialogFade: true
    };

    $scope.change = function () {
        $scope.project.name = $filter('filter_LowercaseNoWhite')($scope.project.name);
    };

    // save action
    $scope.new = function () {
        // create a new project
        api_Project.new({name: $scope.project.name, title: $scope.project.title}, function () {
            // redirect
            $location.path('/projects/' + $scope.project.name);
            // fire message
            service_Messages.send('success', 'Success!', 'Project ' + $scope.project.name + ' was successfully created.');
        });
    }

    $scope.validate = function () {
        // check for undefined
        if (_.isUndefined($scope.project)) {
            return false;
        }

        // exists flag
        $scope.exists = false;

        // check if already exists
        _.forEach($scope.projects, function (item) {
            if (_.isEqual(item.name, $scope.project.name)) {
                $scope.exists = true;
            }
        });

        // return validation
        return !_.isUndefined($scope.project.title) && !_.isUndefined($scope.project.name) && !$scope.exists;
    }

    // initial data
    $scope.refresh();
}

function ProjectsEditorCtrl($scope, $filter, $routeParams, $location, service_Messages, api_Project, api_Collection) {
    // refresh function
    $scope.refresh = function () {
        // get selected project
        api_Project.get({name: $routeParams.name}, function (data_x) {
            $scope.project = data_x.project;
            $scope.editable = {};

            // get all collections
            api_Collection.all(function(data_y) {
                // all collections
                $scope.collections = data_y.collections;
                $scope.collections_selected = _.reject($scope.collections, function(collection) {
                    return !_.isEmpty(_.where($scope.project.collections, {name: collection.name}))
                });
            });
        });
    };

    $scope.edit = function (type) {
        // cancel other edits
        $scope.cancel();
        // prepare new one
        $scope.editable[type] = true;
        $scope.editable['model'] = angular.copy($scope.project);
    };

    $scope.cancel = function () {
        $scope.editable = {};
    };

    $scope.open = function (type) {
        switch (type) {
            case 'new':
                $scope.new_modal = true;
                break;
            case 'delete':
                $scope.delete_modal = true;
                break;
            case 'add':
                $scope.add_modal = true;
                break;
        }
    };

    $scope.close = function (type) {
        switch (type) {
            case 'new':
                $scope.new_modal = false;
                break;
            case 'delete':
                $scope.delete_modal = false;
                break;
            case 'add':
                $scope.add_modal = false;
                break;
        }
    };

    $scope.opts = {
        backdropFade: true,
        dialogFade: true
    };

    $scope.change = function () {
        $scope.collection.name = $filter('filter_LowercaseNoWhite')($scope.collection.name);
    };

    // add new collection
    $scope.new = function () {
        // create a new project
        api_Collection.new({name: $scope.collection.name, title: $scope.collection.title, project: $scope.project.name}, function () {
            // close dialog
            $scope.close('new');
            // redirect
            $scope.refresh();
            // fire message
            service_Messages.send('success', 'Success!', 'Collection ' + $scope.collection.name + ' was successfully created.');
        });
    }

    // add existing collection
    $scope.add = function () {
        // create a new project
        api_Project.add({name: $scope.project.name, collections:[$scope.collection.name]}, function () {
            // close dialog
            $scope.close('add');
            // refresh
            $scope.refresh();
            // fire message
            service_Messages.send('success', 'Success!', 'Collection ' + $scope.collection.name + ' was successfully added.');
        });
    }

    // add existing collection
    $scope.remove = function (collection) {
        // create a new project
        api_Project.remove({name: $scope.project.name, collections:[collection]}, function () {
            // refresh
            $scope.refresh();
            // fire message
            service_Messages.send('success', 'Success!', 'Collection ' + collection + ' was successfully removed.');
        });
    }

    $scope.validate = function () {
        // check for undefined
        if (_.isUndefined($scope.collection)) {
            return false;
        }

        // exists flag
        $scope.exists = false;

        // check if already exists
        _.forEach($scope.collections, function (item) {
            if (_.isEqual(item.name, $scope.collection.name)) {
                $scope.exists = true;
            }
        });

        // return validation
        return !_.isUndefined($scope.collection.title) && !_.isUndefined($scope.collection.name) && !$scope.exists;
    }

    $scope.delete = function () {
        // delete project
        api_Project.delete({name: $scope.project.name}, function() {
            // close dialog
            $scope.close();
            // fire alert
            service_Messages.send('success', 'Success!', 'Project ' + $scope.project.name + ' was successfully deleted.');
            // get back to the overview
            $location.path('/projects');
        });
    }

    $scope.update = function () {
        api_Project.update({name: $scope.project.name, title: $scope.editable['model'].title}, function (data) {
            // refresh
            $scope.refresh();
            // fire message
            service_Messages.send('success', 'Success!', 'Project ' + data.project.name + ' was successfully updated.');
        });
    };

    // initial data
    $scope.refresh();
}

function CollectionsCtrl($scope, $location, $filter, service_Messages, api_Collection) {
    // initial value
    $scope.empty = true;

    // refresh function
    $scope.refresh = function () {
        // get all projects and get back to view
        api_Collection.all(function (data) {
            $scope.empty = (data.collections.length < 1);
            $scope.collections = data.collections;
        });
    };

    // click functionfor detail view
    $scope.detail = function (collection) {
        $location.path('/collections/' + collection.name);
    };

    $scope.open = function () {
        $scope.shouldBeOpen = true;
    };

    $scope.close = function () {
        $scope.shouldBeOpen = false;
        $scope.collection.name = null;
        $scope.collection.title = null;
    };

    $scope.opts = {
        backdropFade: true,
        dialogFade: true
    };

    $scope.change = function () {
        $scope.collection.name = $filter('filter_LowercaseNoWhite')($scope.collection.name);
    };

    // save action
    $scope.new = function () {
        // create a new project
        api_Collection.new({name: $scope.collection.name, title: $scope.collection.title}, function () {
            // redirect
            $location.path('/collections/' + $scope.collection.name);
            // fire message
            service_Messages.send('success', 'Success!', 'Collection ' + $scope.collection.name + ' was successfully created.');
        });
    }

    $scope.validate = function () {
        // check for undefined
        if (_.isUndefined($scope.collection)) {
            return false;
        }

        // exists flag
        $scope.exists = false;

        // check if already exists
        _.forEach($scope.collections, function (item) {
            if (_.isEqual(item.name, $scope.collection.name)) {
                $scope.exists = true;
            }
        });

        // return validation
        return !_.isUndefined($scope.collection.title) && !_.isUndefined($scope.collection.name) && !$scope.exists;
    }

    // initial data
    $scope.refresh();
}

function CollectionsDetailCtrl($scope, $routeParams, $location, service_Messages, api_Collection) {
    // refresh function
    $scope.refresh = function () {
        // get selected project
        api_Collection.get({name: $routeParams.name}, function (data) {
            $scope.collection = data.collection;
            $scope.editable = {};
        });
    };

    $scope.edit = function (type) {
        // cancel other edits
        $scope.cancel();
        // prepare new one
        $scope.editable[type] = true;
        $scope.editable['model'] = angular.copy($scope.collection);
    };

    $scope.cancel = function () {
        $scope.editable = {};
    };

    $scope.open = function () {
        $scope.shouldBeOpen = true;
    };

    $scope.close = function () {
        $scope.shouldBeOpen = false;
    };

    $scope.opts = {
        backdropFade: true,
        dialogFade: true
    };

    $scope.delete = function () {
        // delete project
        api_Collection.delete({name: $scope.collection.name}, function() {
            // close dialog
            $scope.close();
            // fire alert
            service_Messages.send('success', 'Success!', 'Collection ' + $scope.collection.name + ' was successfully deleted.');
            // get back to the overview
            $location.path('/collections');
        });
    }

    $scope.update = function () {
        api_Collection.update({name: $scope.collection.name, title: $scope.editable['model'].title}, function (data) {
            // refresh
            $scope.refresh();
            // fire message
            service_Messages.send('success', 'Success!', 'Collection ' + data.collection.name + ' was successfully updated.');
        });
    };

    // initial data
    $scope.refresh();
}

function ComponentsNavigationCtrl($scope, $location) {
    // Help function for selection identification
    $scope.selected = function (item) {
        return (_.isEqual($location.path(), item.url)) ? true : (_.isEqual(item.url, "/") ? false : $location.path().indexOf(item.url) > -1);
    }

    // navigation initial array
    $scope.navigation = [
        {name: "projects", title: "Projects", url: "/projects", items: []},
        {name: "collections", title: "Collections", url: "/collections", access: ['author'], items: []},
        {name: "users", title: "Users", url: "/users", access: ['admin'], items: []},
        {name: "system", title: "System", url: "/system", access: ['admin'], items: [
            {name: "settings", title: "Settings", url: "/system/settings", access: ['admin']}
        ]}
    ];
}

function ComponentsUserCtrl($scope, $rootScope, $window, api_User, service_User) {
    // default user
    $scope.guest = true;

    // refresh function
    $scope.refresh = function () {
        api_User.me(function (data) {
            if (data != null) {
                $scope.user = data.user;
                // fire user_auth
                $rootScope.$broadcast('event:auth_user', data.user);
                // user logged in
                $scope.guest = false;
            }
        });
    }

    // signin method
    $scope.signin = function () {
        // fire signin
        $rootScope.$broadcast('event:auth_signin');
    }

    // signout method
    $scope.signout = function () {
        // signout
        api_User.signout(function () {
            // redirect
            $window.location.href = '/';
        });
    }

    // initial data
    $scope.refresh();
}

function ComponentsLoginCtrl($scope, $window, service_Server) {
    $scope.opts = {
        backdrop: true,
        backdropFade: false,
        dialogFade: true,
        keyboard: false,
        backdropClick: false
    };

    $scope.open = function () {
        $scope.shouldBeOpen = true;
    };

    $scope.close = function() {
        $scope.shouldBeOpen = false;
    }

    $scope.signin = function(provider) {
        $window.location.href = service_Server.url() + '/auth/' + provider;
    }

    $scope.$on('event:auth_signin', function () {
        $scope.open();
    });
}

function ComponentsMessagesCtrl($scope, $timeout) {
    // initial alerts array
    $scope.alerts = [];

    $scope.close = function (index) {
        $scope.alerts.splice(index, 1);
    }

    $scope.push = function (alert) {
        $scope.alerts.push(alert);
    };

    $scope.$on('event:alert', function (event, alert) {
        // show alert
        $scope.push(alert);
        // set timer on close
        $timeout(function () {
            $scope.close($scope.alerts.indexOf(alert));
        }, 5000);
    });
}
